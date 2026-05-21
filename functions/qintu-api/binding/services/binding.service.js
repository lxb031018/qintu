/**
 * 绑定服务（简化版）
 *
 * 直接绑定，关系平等，解绑即删除记录
 */

const { normalizePhone } = require('../../shared/lib/phone');
const config = require('../../config');

class BindingService {
  constructor(bindingRepository, userRepository) {
    this.bindingRepo = bindingRepository;
    this.userRepo = userRepository;
  }

  /**
   * 绑定用户（通过手机号）
   * @param {string} myUserID - 我的 user_ID
   * @param {string} partnerPhone - 对方的手机号
   * @param {string} senderName - 对方对我的称呼
   * @param {string} receiverName - 我对对方的称呼
   */
  async bindByPhone(myUserID, partnerPhone, senderName, receiverName) {
    // Debug: log the actual phone received
    console.log(`[BIND] partnerPhone="${partnerPhone}" senderName="${senderName}" receiverName="${receiverName}"`);

    // 1. Normalize phone number - use shared function to handle +86 prefix
    const normalizedPhone = normalizePhone(partnerPhone);
    console.log(`[BIND] normalizedPhone="${normalizedPhone}"`);

    // 2. 查找对方用户
    const partnerUser = await this.userRepo.findByPhone(normalizedPhone);
    if (!partnerUser) {
      throw Object.assign(new Error('该手机号尚未注册亲途'), { code: 'USER_NOT_FOUND', status: 404 });
    }

    const partnerUserID = partnerUser.user_ID;

    // 2. 检查自环
    if (myUserID === partnerUserID) {
      throw Object.assign(new Error('不能绑定自己'), { code: 'SELF_BINDING', status: 400 });
    }

    // 3. 检查绑定数量上限
    const myCount = await this.bindingRepo.countForUser(myUserID);
    if (myCount >= config.LIMITS.MAX_BINDINGS_PER_USER) {
      throw Object.assign(new Error('您的绑定人数已达上限'), { code: 'BINDING_LIMIT_EXCEEDED', status: 409 });
    }

    const partnerCount = await this.bindingRepo.countForUser(partnerUserID);
    if (partnerCount >= config.LIMITS.MAX_BINDINGS_PER_USER) {
      throw Object.assign(new Error('对方绑定人数已达上限'), { code: 'PARTNER_BINDING_FULL', status: 409 });
    }

    // 4. 确定 user_A 和 user_B 并存储对应的称呼
    const { user_A, user_B } = myUserID < partnerUserID
      ? { user_A: myUserID, user_B: partnerUserID }
      : { user_A: partnerUserID, user_B: myUserID };

    // senderName = 对方对我的称呼，receiverName = 我对对方的称呼
    // 如果 myUserID 是 user_A，则 receiverName 存到 name_A_to_B，senderName 存到 name_B_to_A
    const name_A_to_B = myUserID === user_A ? receiverName : senderName;
    const name_B_to_A = myUserID === user_A ? senderName : receiverName;

    const result = await this.bindingRepo.createWithNames(user_A, user_B, name_A_to_B, name_B_to_A);

    if (result.alreadyExists) {
      throw Object.assign(new Error('你们已经是绑定关系'), { code: 'ALREADY_BINDING', status: 409 });
    }

    return {
      message: '绑定成功',
      partner_user_ID: partnerUserID,
      partner_nickname: partnerUser.nickname || '未命名用户'
    };
  }

  /**
   * 解绑用户
   * @param {string} myUserID - 我的 user_ID
   * @param {string} partnerUserID - 对方的 user_ID
   */
  async unbind(myUserID, partnerUserID) {
    // 1. 检查绑定关系是否存在
    const exists = await this.bindingRepo.exists(myUserID, partnerUserID);
    if (!exists) {
      throw Object.assign(new Error('绑定关系不存在'), { code: 'BINDING_NOT_FOUND', status: 404 });
    }

    // 2. 删除绑定
    await this.bindingRepo.delete(myUserID, partnerUserID);

    return { message: '已解除绑定' };
  }

  /**
   * 获取我的所有绑定
   * @param {string} myUserID - 我的 user_ID
   */
  async getMyBindings(myUserID) {
    const bindings = await this.bindingRepo.findAllForUser(myUserID);

    // 补充对方用户信息
    const result = [];
    for (const binding of bindings) {
      const partner = await this.userRepo.findByUserID(binding.partner_user_ID);

      // 根据请求方是 user_A 还是 user_B 返回对应的称呼
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
   * 检查是否已绑定
   * @param {string} user_ID_1 - 用户1
   * @param {string} user_ID_2 - 用户2
   */
  async isBound(user_ID_1, user_ID_2) {
    return await this.bindingRepo.exists(user_ID_1, user_ID_2);
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
}

module.exports = BindingService;