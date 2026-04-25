/**
 * 绑定服务
 *
 * 单向+确认模式：sender发请求，receiver确认后绑定生效
 */

const config = require('../../config');
const { normalizePhone, isValidChinesePhone } = require('../../shared/lib/phone');
const { logOperation } = require('../../shared/lib/logger');

class BindingService {
  constructor(bindingRepository, userRepository) {
    this.bindingRepo = bindingRepository;
    this.userRepo = userRepository;
  }

  /**
   * 发送绑定请求（通过手机号）
   */
  async requestByPhone(senderOpenid, receiverPhone, senderName, receiverName, extra = {}) {
    // 1. 规范化手机号
    const cleanPhone = normalizePhone(receiverPhone);

    if (!isValidChinesePhone(cleanPhone)) {
      throw Object.assign(new Error('手机号格式不正确（应为 11 位中国手机号）'), { code: 'INVALID_PHONE', status: 400 });
    }

    // 2. 查找接收者
    const receiverOpenid = await this.userRepo.findOpenidByPhone(cleanPhone);
    if (!receiverOpenid) {
      throw Object.assign(new Error('该手机号尚未注册亲途'), { code: 'USER_NOT_FOUND', status: 404 });
    }

    // 3. 检查自环
    if (senderOpenid === receiverOpenid) {
      throw Object.assign(new Error('不能绑定自己'), { code: 'SELF_BINDING', status: 400 });
    }

    // 4. 获取发送者手机号
    const allUsers = await this.userRepo.findAll();
    let senderPhone = null;
    for (const user of allUsers) {
      if (user.openid === senderOpenid) {
        senderPhone = user.phone;
        break;
      }
    }

    // 5. 检查绑定上限
    const senderActiveCount = await this.bindingRepo.countActiveAsSender(senderOpenid);
    if (senderActiveCount >= config.LIMITS.MAX_BINDINGS_PER_USER) {
      throw Object.assign(new Error('您的绑定人数已达上限'), { code: 'BINDING_LIMIT_EXCEEDED', status: 409 });
    }

    const receiverPendingCount = await this.bindingRepo.countPendingAsReceiver(receiverOpenid);
    if (receiverPendingCount >= config.LIMITS.MAX_BINDINGS_PER_USER) {
      throw Object.assign(new Error('对方绑定人数已达上限'), { code: 'RECEIVER_BINDING_FULL', status: 409 });
    }

    // 6. 检查是否已存在绑定
    const existing = await this.bindingRepo.findActiveBetween(senderOpenid, receiverOpenid);
    if (existing) {
      throw Object.assign(new Error('与该用户的绑定关系已生效'), { code: 'BINDING_EXISTS', status: 409 });
    }

    // 检查是否有 pending 请求
    const pendingForReceiver = await this.bindingRepo.findPendingForReceiver(receiverOpenid);
    const hasPending = pendingForReceiver.some(b => b.sender_openid === senderOpenid);
    if (hasPending) {
      throw Object.assign(new Error('已发送过绑定请求，请等待对方确认'), { code: 'PENDING_EXISTS', status: 409 });
    }

    // 7. 创建 pending 绑定
    const expiredAt = new Date(Date.now() + config.BINDING.EXPIRES_MS);
    const binding = await this.bindingRepo.createPending({
      senderOpenid,
      receiverOpenid,
      senderName,
      receiverName,
      senderPhone,
      receiverPhone: cleanPhone,
      expiredAt
    });

    // 8. 记录日志
    logOperation({
      userOpenid: senderOpenid,
      action: 'REQUEST_BINDING',
      targetType: 'binding',
      targetId: String(binding.id),
      details: { receiver_openid: receiverOpenid, sender_name: senderName || '未命名发送者' },
      ipAddress: extra.ipAddress
    }).catch(() => {});

    return { binding_id: binding.id, message: '绑定请求已发送' };
  }

  /**
   * 确认绑定请求
   */
  async confirmRequest(requestId, receiverOpenid, extra = {}) {
    const binding = await this.bindingRepo.findById(requestId);

    if (!binding || binding.receiver_openid !== receiverOpenid || binding.status !== 'pending') {
      throw Object.assign(new Error('请求不存在或状态异常'), { code: 'REQUEST_INVALID', status: 404 });
    }

    await this.bindingRepo.updateStatus(requestId, 'active');

    logOperation({
      userOpenid: receiverOpenid,
      action: 'CONFIRM_BINDING',
      targetType: 'binding',
      targetId: String(requestId),
      details: { sender_openid: binding.sender_openid },
      ipAddress: extra.ipAddress
    }).catch(() => {});

    return { message: '绑定成功' };
  }

  /**
   * 拒绝绑定请求
   */
  async rejectRequest(requestId, receiverOpenid, extra = {}) {
    const binding = await this.bindingRepo.findById(requestId);

    if (!binding || binding.receiver_openid !== receiverOpenid || binding.status !== 'pending') {
      throw Object.assign(new Error('请求不存在'), { code: 'REQUEST_INVALID', status: 404 });
    }

    await this.bindingRepo.updateStatus(requestId, 'revoked', {
      rejected_at: new Date().toISOString()
    });

    logOperation({
      userOpenid: receiverOpenid,
      action: 'REJECT_BINDING',
      targetType: 'binding',
      targetId: String(requestId),
      details: { sender_openid: binding.sender_openid },
      ipAddress: extra.ipAddress
    }).catch(() => {});

    return { message: '已拒绝' };
  }

  /**
   * 获取我的所有有效绑定
   */
  async getMyBindings(openid) {
    const bindings = await this.bindingRepo.findAllActiveForUser(openid);

    const result = bindings.map(binding => {
      const isSender = binding.sender_openid === openid;
      return {
        id: binding.id,
        status: binding.status,
        remark: binding.remark,
        created_at: binding.created_at,
        updated_at: binding.updated_at,
        my_role: isSender ? 'sender' : 'receiver',
        partner_openid: isSender ? binding.receiver_openid : binding.sender_openid,
        partner_nickname: isSender ? binding.receiver_nickname : binding.sender_nickname,
        partner_phone: isSender ? binding.receiver_phone : binding.sender_phone,
        partner_type: isSender ? binding.receiver_type : binding.sender_type,
        sender_openid: binding.sender_openid,
        receiver_openid: binding.receiver_openid
      };
    });

    const asSender = result.filter(b => b.my_role === 'sender').length;
    const asReceiver = result.filter(b => b.my_role === 'receiver').length;

    return {
      total: result.length,
      as_sender: asSender,
      as_receiver: asReceiver,
      bindings: result
    };
  }

  /**
   * 获取待确认的绑定请求（作为接收者）
   */
  async getPendingRequests(openid) {
    // 先清理过期记录
    await this.bindingRepo.cleanupOldRecords();

    const pending = await this.bindingRepo.findPendingForReceiver(openid);

    return pending.map(binding => ({
      id: binding.id,
      sender_name: binding.sender_nickname,
      sender_phone: binding.sender_phone
        ? binding.sender_phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
        : '未知',
      created_at: binding.created_at,
      expired_at: binding.expired_at
    }));
  }

  /**
   * 获取我发出的绑定请求
   */
  async getSentRequests(openid) {
    // 先清理过期记录
    await this.bindingRepo.cleanupOldRecords();

    const sent = await this.bindingRepo.findAllBySender(openid);

    return sent.map(binding => ({
      id: binding.id,
      status: binding.status,
      receiver_nickname: binding.receiver_nickname,
      created_at: binding.created_at,
      expired_at: binding.expired_at,
      rejected_at: binding.rejected_at || null,
      receiver_phone: binding.receiver_phone
        ? binding.receiver_phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
        : '未知'
    }));
  }

  /**
   * 解除绑定 / 取消请求
   */
  async revoke(bindingId, openid, extra = {}) {
    const binding = await this.bindingRepo.findById(bindingId);

    if (!binding) {
      throw Object.assign(new Error('绑定关系不存在'), { code: 'NOT_FOUND', status: 404 });
    }

    if (binding.sender_openid !== openid && binding.receiver_openid !== openid) {
      throw Object.assign(new Error('无权操作此绑定关系'), { code: 'PERMISSION_DENIED', status: 403 });
    }

    // pending 状态：直接删除
    if (binding.status === 'pending') {
      await this.bindingRepo.delete(bindingId);

      logOperation({
        userOpenid: openid,
        action: 'CANCEL_BINDING_REQUEST',
        targetType: 'binding',
        targetId: String(bindingId),
        details: { receiver_openid: binding.receiver_openid },
        ipAddress: extra.ipAddress
      }).catch(() => {});

      return { message: '绑定请求已取消' };
    }

    // 其他状态：更新为 revoked
    await this.bindingRepo.updateStatus(bindingId, 'revoked');

    logOperation({
      userOpenid: openid,
      action: 'REVOKE_BINDING',
      targetType: 'binding',
      targetId: String(bindingId),
      details: {
        role: binding.sender_openid === openid ? 'sender' : 'receiver',
        partner_openid: binding.sender_openid === openid ? binding.receiver_openid : binding.sender_openid
      },
      ipAddress: extra.ipAddress
    }).catch(() => {});

    return { message: '绑定关系已解除' };
  }
}

module.exports = BindingService;
