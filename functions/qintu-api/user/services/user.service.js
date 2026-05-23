/**
 * 用户服务
 */

class UserService {
  constructor(userRepository) {
    this.userRepo = userRepository;
  }

  /**
   * 根据 userId 获取用户
   * @param {string} userId
   */
  async getUserById(userId) {
    return await this.userRepo.findByUserID(userId);
  }

  /**
   * 更新用户信息
   * @param {string} userId
   * @param {Object} userData - { nickname, avatar_url }
   */
  async updateUser(userId, userData) {
    await this.userRepo.upsert(userId, userData);
  }

  /**
   * 同步用户信息
   * @param {string} phone_number
   * @param {string} userId
   * @param {string} nickname
   */
  async syncUser(phone_number, userId, nickname) {
    // 注册或更新用户
    await this.userRepo.registerByPhone(phone_number, userId);

    const updateData = { phone: phone_number };
    if (nickname) {
      updateData.nickname = nickname;
    }

    if (Object.keys(updateData).length > 0) {
      await this.userRepo.upsert(userId, updateData);
    }

    return { userId };
  }

  /**
   * 更新最后登录时间
   * @param {string} userId
   */
  async updateLastLogin(userId) {
    await this.userRepo.updateLastLogin(userId);
  }
}

module.exports = UserService;