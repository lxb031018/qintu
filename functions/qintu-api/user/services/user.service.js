/**
 * 用户服务
 */

class UserService {
  constructor(userRepository) {
    this.userRepo = userRepository;
  }

  /**
   * 根据 user_ID 获取用户
   * @param {string} user_ID
   */
  async getUserById(user_ID) {
    return await this.userRepo.findByUserID(user_ID);
  }

  /**
   * 更新用户信息
   * @param {string} user_ID
   * @param {Object} userData - { nickname, avatar_url }
   */
  async updateUser(user_ID, userData) {
    await this.userRepo.upsert(user_ID, userData);
  }

  /**
   * 同步用户信息
   * @param {string} phone_number
   * @param {string} user_ID
   * @param {string} nickname
   */
  async syncUser(phone_number, user_ID, nickname) {
    // 注册或更新用户
    await this.userRepo.registerByPhone(phone_number, user_ID);

    const updateData = { phone: phone_number };
    if (nickname) {
      updateData.nickname = nickname;
    }

    if (Object.keys(updateData).length > 0) {
      await this.userRepo.upsert(user_ID, updateData);
    }

    return { user_ID };
  }
}

module.exports = UserService;