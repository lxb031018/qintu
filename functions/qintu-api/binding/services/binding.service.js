/**
 * 绑定服务
 *
 * 单表设计：user_bindings 表同时存储 pending 和 active 状态的绑定
 * 流程：发送请求 -> 对方确认/拒绝 -> 建立绑定或删除记录
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
   * @param {string} myUserID - 我的 userId
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

    const partnerUserID = partnerUser.userId;

    // 3. 检查自环
    if (myUserID === partnerUserID) {
      throw Object.assign(new Error('不能绑定自己'), { code: 'SELF_BINDING', status: 400 });
    }

    // 4. 检查是否已经绑定（active 状态）
    const isAlreadyBound = await this.bindingRepo.exists(myUserID, partnerUserID);
    if (isAlreadyBound) {
      throw Object.assign(new Error('你们已经是绑定关系'), { code: 'ALREADY_BINDING', status: 409 });
    }

    // 5. 检查是否已有待处理的绑定请求（pending 状态）
    const hasPending = await this.bindingRepo.hasPendingRequest(myUserID, partnerUserID);
    if (hasPending) {
      throw Object.assign(new Error('您已发送过绑定请求，请等待对方确认'), { code: 'REQUEST_EXISTS', status: 409 });
    }

    // 6. 创建 pending 状态的绑定记录（7天过期）
    const expiresAt = new Date(Date.now() + config.BINDING.EXPIRES_MS);
    const result = await this.bindingRepo.createPendingBinding(
      myUserID,
      partnerUserID,
      senderName,
      receiverName,
      expiresAt
    );

    if (result.alreadyExists) {
      throw Object.assign(new Error('您已发送过绑定请求，请等待对方确认'), { code: 'REQUEST_EXISTS', status: 409 });
    }

    return {
      message: '绑定请求已发送',
      partner_userId: partnerUserID,
      partner_nickname: partnerUser.nickname || '未命名用户'
    };
  }

  /**
   * 获取我收到的待确认请求（作为接收者）
   * @param {string} myUserID - 我的 userId
   */
  async getPendingRequests(myUserID) {
    // 先过期旧请求
    await this.bindingRepo.expireOldRequests();

    const bindings = await this.bindingRepo.findPendingForReceiver(myUserID);

    const result = [];
    for (const binding of bindings) {
      // 找出对方用户（发送者）
      const partnerUserID = binding.sender_userId;
      const partner = await this.userRepo.findByUserID(partnerUserID);

      // sender_name 是发送者对接收者的称呼
      // 由于 userA < userB，sender_userId 可能是 userA 或 userB
      const isUserA = binding.userA === myUserID;
      const senderName = isUserA ? binding.name_B_to_A : binding.name_A_to_B;

      result.push({
        id: binding.id,
        sender_userId: partnerUserID,
        sender_name: senderName,
        sender_phone: partner?.phone ? partner.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2') : '未知',
        sender_nickname: partner?.nickname || '未命名用户',
        created_at: binding.created_at,
        expires_at: binding.expires_at
      });
    }

    return result;
  }

  /**
   * 获取我发出的请求（作为发送者）
   * @param {string} myUserID - 我的 userId
   */
  async getSentRequests(myUserID) {
    // 先过期旧请求
    await this.bindingRepo.expireOldRequests();

    const bindings = await this.bindingRepo.findSentBySender(myUserID);

    const result = [];
    for (const binding of bindings) {
      const partnerUserID = binding.userA === myUserID ? binding.userB : binding.userA;
      const partner = await this.userRepo.findByUserID(partnerUserID);

      // 判断状态
      let status = binding.status;
      if (binding.status === 'pending' && new Date(binding.expires_at) < new Date()) {
        status = 'expired';
      }

      // receiver_name 是对方对我的称呼
      const isUserA = binding.userA === myUserID;
      const receiverName = isUserA ? binding.name_A_to_B : binding.name_B_to_A;

      result.push({
        id: binding.id,
        receiver_userId: partnerUserID,
        receiver_name: receiverName,
        receiver_nickname: partner?.nickname || '未命名用户',
        receiver_phone: partner?.phone ? partner.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2') : '未知',
        status: status,
        created_at: binding.created_at,
        expires_at: binding.expires_at
      });
    }

    return result;
  }

  /**
   * 确认绑定请求（接收者接受）
   * @param {string} myUserID - 我的 userId
   * @param {string} partnerUserID - 发送者的 userId
   */
  async confirmRequest(myUserID, partnerUserID) {
    // 1. 检查绑定是否存在且为 pending
    const binding = await this.bindingRepo.findPendingForReceiver(myUserID);
    const pendingBinding = binding.find(b =>
      (b.userA === myUserID && b.userB === partnerUserID) ||
      (b.userA === partnerUserID && b.userB === myUserID)
    );

    if (!pendingBinding) {
      throw Object.assign(new Error('绑定请求不存在'), { code: 'REQUEST_NOT_FOUND', status: 404 });
    }

    // 2. 检查请求是否已过期
    if (new Date(pendingBinding.expires_at) < new Date()) {
      throw Object.assign(new Error('请求已过期'), { code: 'REQUEST_EXPIRED', status: 409 });
    }

    // 3. 激活绑定（pending -> active）
    await this.bindingRepo.activateBinding(myUserID, partnerUserID);

    return {
      message: '绑定成功',
      partner_userId: partnerUserID
    };
  }

  /**
   * 拒绝绑定请求
   * @param {string} myUserID - 我的 userId
   * @param {string} partnerUserID - 发送者的 userId
   */
  async rejectRequest(myUserID, partnerUserID) {
    // 删除 pending 状态的记录
    const deleted = await this.bindingRepo.deletePending(myUserID, partnerUserID);

    if (!deleted) {
      throw Object.assign(new Error('绑定请求不存在'), { code: 'REQUEST_NOT_FOUND', status: 404 });
    }

    return { message: '已拒绝绑定请求' };
  }

  /**
   * 取消发出的请求
   * @param {string} myUserID - 我的 userId
   * @param {string} partnerUserID - 接收者的 userId
   */
  async cancelRequest(myUserID, partnerUserID) {
    const deleted = await this.bindingRepo.deletePending(myUserID, partnerUserID);

    if (!deleted) {
      throw Object.assign(new Error('绑定请求不存在'), { code: 'REQUEST_NOT_FOUND', status: 404 });
    }

    return { message: '已取消绑定请求' };
  }

  /**
   * 解绑用户
   * @param {string} myUserID - 我的 userId
   * @param {string} partnerUserID - 对方的 userId
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
   * @param {string} myUserID - 我的 userId
   */
  async getMyBindings(myUserID) {
    const bindings = await this.bindingRepo.findAllForUser(myUserID);

    const result = [];
    for (const binding of bindings) {
      // 跳过非 active 状态的绑定（pending 在列表中不显示）
      if (binding.status !== 'active') {
        continue;
      }

      const partner = await this.userRepo.findByUserID(binding.partner_userId);

      const isUserA = binding.userA === myUserID;
      const myNameForPartner = isUserA ? binding.name_B_to_A : binding.name_A_to_B;
      const partnerNameForMe = isUserA ? binding.name_A_to_B : binding.name_B_to_A;

      result.push({
        partner_userId: binding.partner_userId,
        partner_nickname: partner?.nickname || '未命名用户',
        partner_phone: partner?.phone
          ? partner.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
          : '未知',
        my_name_for_partner: myNameForPartner,
        partner_name_for_me: partnerNameForMe,
        status: binding.status,
        created_at: binding.created_at,
        bound_at: binding.bound_at
      });
    }

    return {
      total: result.length,
      bindings: result
    };
  }

  /**
   * 修改我对对方的称呼
   * @param {string} myUserID - 我的 userId
   * @param {string} partnerUserID - 对方的 userId
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
}

module.exports = BindingService;