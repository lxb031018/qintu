/**
 * 绑定服务
 *
 * 完整流程：发送请求 -> 对方确认 -> 建立绑定关系
 */

const { normalizePhone } = require('../../shared/lib/phone');
const config = require('../../config');

class BindingService {
  constructor(bindingRepository, userRepository) {
    this.bindingRepo = bindingRepository;
    this.userRepo = userRepository;
  }

  /**
   * 发送绑定请求
   * @param {string} myUserID - 我的 user_ID
   * @param {string} partnerPhone - 对方的手机号
   * @param {string} senderName - 我对对方的称呼
   * @param {string} receiverName - 对方对我的称呼
   */
  async requestBinding(myUserID, partnerPhone, senderName, receiverName) {
    // 1. Normalize phone number
    const normalizedPhone = normalizePhone(partnerPhone);

    // 2. 查找对方用户
    const partnerUser = await this.userRepo.findByPhone(normalizedPhone);
    if (!partnerUser) {
      throw Object.assign(new Error('该手机号尚未注册亲途'), { code: 'USER_NOT_FOUND', status: 404 });
    }

    const partnerUserID = partnerUser.user_ID;

    // 3. 检查自环
    if (myUserID === partnerUserID) {
      throw Object.assign(new Error('不能绑定自己'), { code: 'SELF_BINDING', status: 400 });
    }

    // 4. 检查是否已经绑定
    const isAlreadyBound = await this.bindingRepo.exists(myUserID, partnerUserID);
    if (isAlreadyBound) {
      throw Object.assign(new Error('你们已经是绑定关系'), { code: 'ALREADY_BINDING', status: 409 });
    }

    // 5. 检查是否已有待处理的绑定请求
    const hasPending = await this.bindingRepo.hasPendingRequest(myUserID, partnerUserID);
    if (hasPending) {
      throw Object.assign(new Error('您已发送过绑定请求，请等待对方确认'), { code: 'REQUEST_EXISTS', status: 409 });
    }

    // 6. 创建绑定请求（7天过期）
    const expiresAt = new Date(Date.now() + config.BINDING.EXPIRES_MS);
    const request = await this.bindingRepo.createRequest(
      myUserID,
      partnerUserID,
      senderName,
      receiverName,
      expiresAt
    );

    return {
      message: '绑定请求已发送',
      request_id: request.id,
      partner_nickname: partnerUser.nickname || '未命名用户'
    };
  }

  /**
   * 获取我收到的待确认请求（作为接收者）
   * @param {string} myUserID - 我的 user_ID
   */
  async getPendingRequests(myUserID) {
    // 先过期旧请求
    await this.bindingRepo.expireOldRequests();

    const requests = await this.bindingRepo.findPendingForReceiver(myUserID);

    const result = [];
    for (const req of requests) {
      const sender = await this.userRepo.findByUserID(req.sender_user_ID);
      result.push({
        id: req.id,
        sender_name: req.sender_name,
        sender_phone: sender?.phone ? sender.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2') : '未知',
        sender_nickname: sender?.nickname || '未命名用户',
        created_at: req.created_at,
        expires_at: req.expires_at
      });
    }

    return result;
  }

  /**
   * 获取我发出的请求（作为发送者）
   * @param {string} myUserID - 我的 user_ID
   */
  async getSentRequests(myUserID) {
    // 先过期旧请求
    await this.bindingRepo.expireOldRequests();

    const requests = await this.bindingRepo.findSentBySender(myUserID);

    const result = [];
    for (const req of requests) {
      const receiver = await this.userRepo.findByUserID(req.receiver_user_ID);

      // 计算状态
      let status = req.status;
      if (req.status === 'pending' && new Date(req.expires_at) < new Date()) {
        status = 'expired';
      }

      result.push({
        id: req.id,
        receiver_name: req.receiver_name,
        receiver_nickname: receiver?.nickname || '未命名用户',
        receiver_phone: receiver?.phone ? receiver.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2') : '未知',
        status: status,
        created_at: req.created_at,
        expires_at: req.expires_at
      });
    }

    return result;
  }

  /**
   * 确认绑定请求（接收者接受）
   * @param {string} myUserID - 我的 user_ID
   * @param {number} requestId - 请求 ID
   */
  async confirmRequest(myUserID, requestId) {
    // 1. 查找请求
    const request = await this.bindingRepo.findRequestById(requestId);
    if (!request) {
      throw Object.assign(new Error('绑定请求不存在'), { code: 'REQUEST_NOT_FOUND', status: 404 });
    }

    // 2. 检查是否是接收者
    if (request.receiver_user_ID !== myUserID) {
      throw Object.assign(new Error('无权操作此请求'), { code: 'UNAUTHORIZED', status: 403 });
    }

    // 3. 检查请求状态
    if (request.status !== 'pending') {
      throw Object.assign(new Error('请求已处理'), { code: 'REQUEST_ALREADY_PROCESSED', status: 409 });
    }

    // 4. 检查是否已过期
    if (new Date(request.expires_at) < new Date()) {
      throw Object.assign(new Error('请求已过期'), { code: 'REQUEST_EXPIRED', status: 409 });
    }

    // 5. 创建绑定关系
    // sender 是 A（发起方），receiver 是 B（接收方）
    // 但存储时 user_A < user_B
    const { user_A, user_B } = myUserID < request.sender_user_ID
      ? { user_A: myUserID, user_B: request.sender_user_ID }
      : { user_A: request.sender_user_ID, user_B: myUserID };

    // sender_name = 发送者对接收者的称呼（A对B的称呼）
    // receiver_name = 接收者对发送者的称呼（B对A的称呼）
    // 如果 myUserID 是 user_A（即我是发送者），那么：
    //   - 我的称呼（receiver_name）应该存到 name_B_to_A
    //   - 对方的称呼（sender_name）应该存到 name_A_to_B
    // 如果 myUserID 是 user_B（即我是接收者），那么：
    //   - 我的称呼（receiver_name）应该存到 name_A_to_B
    //   - 对方的称呼（sender_name）应该存到 name_B_to_A
    const name_A_to_B = myUserID === user_A ? request.receiver_name : request.sender_name;
    const name_B_to_A = myUserID === user_A ? request.sender_name : request.receiver_name;

    const bindResult = await this.bindingRepo.createWithNames(user_A, user_B, name_A_to_B, name_B_to_A);

    if (bindResult.alreadyExists) {
      throw Object.assign(new Error('你们已经是绑定关系'), { code: 'ALREADY_BINDING', status: 409 });
    }

    // 6. 更新请求状态为已接受
    await this.bindingRepo.updateRequestStatus(requestId, 'accepted');

    return {
      message: '绑定成功',
      partner_user_ID: request.sender_user_ID,
      partner_nickname: (await this.userRepo.findByUserID(request.sender_user_ID))?.nickname || '未命名用户'
    };
  }

  /**
   * 拒绝绑定请求
   * @param {string} myUserID - 我的 user_ID
   * @param {number} requestId - 请求 ID
   */
  async rejectRequest(myUserID, requestId) {
    const request = await this.bindingRepo.findRequestById(requestId);
    if (!request) {
      throw Object.assign(new Error('绑定请求不存在'), { code: 'REQUEST_NOT_FOUND', status: 404 });
    }

    if (request.receiver_user_ID !== myUserID) {
      throw Object.assign(new Error('无权操作此请求'), { code: 'UNAUTHORIZED', status: 403 });
    }

    if (request.status !== 'pending') {
      throw Object.assign(new Error('请求已处理'), { code: 'REQUEST_ALREADY_PROCESSED', status: 409 });
    }

    await this.bindingRepo.updateRequestStatus(requestId, 'rejected');
    return { message: '已拒绝绑定请求' };
  }

  /**
   * 取消发出的请求
   * @param {string} myUserID - 我的 user_ID
   * @param {number} requestId - 请求 ID
   */
  async cancelRequest(myUserID, requestId) {
    const request = await this.bindingRepo.findRequestById(requestId);
    if (!request) {
      throw Object.assign(new Error('绑定请求不存在'), { code: 'REQUEST_NOT_FOUND', status: 404 });
    }

    if (request.sender_user_ID !== myUserID) {
      throw Object.assign(new Error('无权操作此请求'), { code: 'UNAUTHORIZED', status: 403 });
    }

    if (request.status !== 'pending') {
      throw Object.assign(new Error('请求已处理'), { code: 'REQUEST_ALREADY_PROCESSED', status: 409 });
    }

    await this.bindingRepo.updateRequestStatus(requestId, 'rejected');
    return { message: '已取消绑定请求' };
  }

  /**
   * 解绑用户
   * @param {string} myUserID - 我的 user_ID
   * @param {string} partnerUserID - 对方的 user_ID
   */
  async unbind(myUserID, partnerUserID) {
    const exists = await this.bindingRepo.exists(myUserID, partnerUserID);
    if (!exists) {
      throw Object.assign(new Error('绑定关系不存在'), { code: 'BINDING_NOT_FOUND', status: 404 });
    }

    await this.bindingRepo.delete(myUserID, partnerUserID);
    return { message: '已解除绑定' };
  }

  /**
   * 获取我的所有绑定
   * @param {string} myUserID - 我的 user_ID
   */
  async getMyBindings(myUserID) {
    const bindings = await this.bindingRepo.findAllForUser(myUserID);

    const result = [];
    for (const binding of bindings) {
      const partner = await this.userRepo.findByUserID(binding.partner_user_ID);

      const isUserA = binding.user_A === myUserID;
      const myNameForPartner = isUserA ? binding.name_A_to_B : binding.name_B_to_A;
      const partnerNameForMe = isUserA ? binding.name_B_to_A : binding.name_A_to_B;

      result.push({
        partner_user_ID: binding.partner_user_ID,
        partner_nickname: partner?.nickname || '未命名用户',
        partner_phone: partner?.phone
          ? partner.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
          : '未知',
        my_name_for_partner: myNameForPartner,
        partner_name_for_me: partnerNameForMe
      });
    }

    return {
      total: result.length,
      bindings: result
    };
  }

  /**
   * 修改我对对方的称呼
   * @param {string} myUserID - 我的 user_ID
   * @param {string} partnerUserID - 对方的 user_ID
   * @param {string} newName - 新的称呼
   */
  async modifyName(myUserID, partnerUserID, newName) {
    const exists = await this.bindingRepo.exists(myUserID, partnerUserID);
    if (!exists) {
      throw Object.assign(new Error('绑定关系不存在'), { code: 'BINDING_NOT_FOUND', status: 404 });
    }

    await this.bindingRepo.modifyName(myUserID, partnerUserID, newName);
    return { message: '称呼已修改' };
  }

  /**
   * 检查是否已绑定
   */
  async isBound(user_ID_1, user_ID_2) {
    return await this.bindingRepo.exists(user_ID_1, user_ID_2);
  }
}

module.exports = BindingService;