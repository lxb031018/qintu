/**
 * 绑定服务（简化版）
 *
 * 直接绑定，关系平等，解绑即删除记录
 */

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
   */
  async bindByPhone(myUserID, partnerPhone) {
    // 1. 查找对方用户
    const partnerUser = await this.userRepo.findByPhone(partnerPhone);
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

    // 4. 创建绑定
    const result = await this.bindingRepo.create(myUserID, partnerUserID);

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
      result.push({
        partner_user_ID: binding.partner_user_ID,
        partner_nickname: partner?.nickname || '未命名用户',
        partner_phone: partner?.phone
          ? partner.phone.replace(/(\+\d{1,3}\s)?(\d{3})\d{4}(\d{4})/, '$2****$3')
          : '未知'
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
}

module.exports = BindingService;