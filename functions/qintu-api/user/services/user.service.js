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
   * 根据 user_ID 获取用户信息
   * @param {string} user_ID
   * @returns {Object|null}
   */
  async getUserByUserID(user_ID) {
    return this.userRepo.findByUserID(user_ID);
  }

  /**
   * 创建或更新用户
   * @param {string} user_ID
   * @param {Object} userData
   * @returns {Object}
   */
  async upsertUser(user_ID, userData) {
    await this.userRepo.upsert(user_ID, userData);
    return this.userRepo.findByUserID(user_ID);
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
