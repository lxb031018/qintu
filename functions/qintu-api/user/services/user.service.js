/**
 * 用户服务
 *
 * 职责：
 * 1. 用户信息管理
 * 2. 用户注册/同步
 */

class UserService {
  constructor(userRepository) {
    this.userRepo = userRepository;
  }

  /**
   * 根据 openid 获取用户信息
   * @param {string} openid
   * @returns {Object|null}
   */
  async getUserByOpenid(openid) {
    return this.userRepo.findByOpenid(openid);
  }

  /**
   * 创建或更新用户
   * @param {string} openid
   * @param {Object} userData
   * @returns {Object}
   */
  async upsertUser(openid, userData) {
    await this.userRepo.upsert(openid, userData);
    return this.userRepo.findByOpenid(openid);
  }

  /**
   * 获取所有用户
   * @returns {Array}
   */
  async getAllUsers() {
    return this.userRepo.findAll();
  }
}

module.exports = UserService;
