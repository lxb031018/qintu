/**
 * 用户内存 Repository
 *
 * 管理用户手机号映射（userPhoneMap）
 */

class UserMemoryRepository {
  constructor() {
    // 手机号 -> openid 的映射
    this.userPhoneMap = new Map();
    // openid -> 用户信息
    this.users = new Map();
  }

  /**
   * 根据手机号查找 openid
   * @param {string} phone - 11位手机号
   * @returns {string|null}
   */
  async findOpenidByPhone(phone) {
    return this.userPhoneMap.get(phone) || null;
  }

  /**
   * 注册用户（手机号 -> openid 映射）
   * @param {string} phone - 11位手机号
   * @param {string} openid - 用户 openid
   */
  async registerByPhone(phone, openid) {
    this.userPhoneMap.set(phone, openid);
  }

  /**
   * 根据 openid 查找用户
   * @param {string} openid
   * @returns {Object|null}
   */
  async findByOpenid(openid) {
    return this.users.get(openid) || null;
  }

  /**
   * 创建或更新用户
   * @param {string} openid
   * @param {Object} userData
   */
  async upsert(openid, userData) {
    const existing = this.users.get(openid) || {};
    this.users.set(openid, { ...existing, ...userData, openid });
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
