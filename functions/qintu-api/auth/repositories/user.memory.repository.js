/**
 * 用户内存 Repository
 *
 * 管理用户手机号映射（userPhoneMap）
 */

class UserMemoryRepository {
  constructor() {
    // 手机号 -> user_ID 的映射
    this.userPhoneMap = new Map();
    // user_ID -> 用户信息
    this.users = new Map();
  }

  /**
   * 根据手机号查找 user_ID
   * @param {string} phone - 11位手机号
   * @returns {string|null}
   */
  async findUserIDByPhone(phone) {
    return this.userPhoneMap.get(phone) || null;
  }

  /**
   * 注册用户（手机号 -> user_ID 映射）
   * @param {string} phone - 11位手机号
   * @param {string} user_ID - 用户 user_ID
   */
  async registerByPhone(phone, user_ID) {
    this.userPhoneMap.set(phone, user_ID);
  }

  /**
   * 根据 user_ID 查找用户
   * @param {string} user_ID
   * @returns {Object|null}
   */
  async findByUserID(user_ID) {
    return this.users.get(user_ID) || null;
  }

  /**
   * 根据 user_ID 反查手机号（用于日志脱敏显示）
   * @param {string} user_ID
   * @returns {string|null} - 脱敏手机号或 null
   */
  async findPhoneByUserID(user_ID) {
    // 遍历 userPhoneMap 找到该 user_ID 对应的手机号
    for (const [phone, oid] of this.userPhoneMap.entries()) {
      if (oid === user_ID) {
        return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
      }
    }
    return null;
  }

  /**
   * 创建或更新用户
   * @param {string} user_ID
   * @param {Object} userData
   */
  async upsert(user_ID, userData) {
    const existing = this.users.get(user_ID) || {};
    this.users.set(user_ID, { ...existing, ...userData, user_ID });
  }

  /**
   * 获取所有用户
   * @returns {Array}
   */
  async findAll() {
    return Array.from(this.users.values());
  }
}

module.exports = UserMemoryRepository;
