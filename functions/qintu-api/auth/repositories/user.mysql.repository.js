/**
 * 用户 MySQL Repository
 *
 * 管理用户数据的持久化存储
 */

const { query, transaction } = require('../../db/mysql');

class UserMysqlRepository {
  /**
   * 根据手机号查找 userId
   * @param {string} phone - 11位手机号
   * @returns {Promise<string|null>}
   */
  async findUserIDByPhone(phone) {
    const rows = await query(
      'SELECT userId FROM users WHERE phone = ?',
      [phone]
    );
    return rows.length > 0 ? rows[0].userId : null;
  }

  /**
   * 注册用户（手机号 -> userId 映射）
   * 使用 INSERT IGNORE 避免重复插入
   * @param {string} phone - 手机号
   * @param {string} userId - 用户 userId
   */
  async registerByPhone(phone, userId) {
    await query(
      `INSERT IGNORE INTO users (userId, phone, created_at)
       VALUES (?, ?, NOW())`,
      [userId, phone]
    );
  }

  /**
   * 根据 userId 查找用户
   * @param {string} userId
   * @returns {Promise<Object|null>}
   */
  async findByUserID(userId) {
    const rows = await query(
      'SELECT * FROM users WHERE userId = ?',
      [userId]
    );
    return rows.length > 0 ? rows[0] : null;
  }

  /**
   * 根据手机号查找用户
   * @param {string} phone
   * @returns {Promise<Object|null>}
   */
  async findByPhone(phone) {
    const rows = await query(
      'SELECT * FROM users WHERE phone = ?',
      [phone]
    );
    return rows.length > 0 ? rows[0] : null;
  }

  /**
   * 创建或更新用户
   * @param {string} userId
   * @param {Object} userData - 用户数据
   */
  async upsert(userId, userData) {
    const fields = [];
    const values = [];

    if (userData.phone !== undefined) {
      fields.push('phone = ?');
      values.push(userData.phone);
    }
    if (userData.nickname !== undefined) {
      fields.push('nickname = ?');
      values.push(userData.nickname);
    }
    if (userData.avatar_url !== undefined) {
      fields.push('avatar_url = ?');
      values.push(userData.avatar_url);
    }
    if (userData.last_active_at !== undefined) {
      fields.push('last_active_at = ?');
      values.push(userData.last_active_at);
    }

    if (fields.length === 0) return;

    values.push(userId);
    await query(
      `UPDATE users SET ${fields.join(', ')} WHERE userId = ?`,
      values
    );
  }

  /**
   * 更新最后登录时间
   * @param {string} userId
   */
  async updateLastLogin(userId) {
    await query(
      'UPDATE users SET last_active_at = NOW() WHERE userId = ?',
      [userId]
    );
  }

  /**
   * 根据 userId 反查脱敏手机号
   * @param {string} userId
   * @returns {Promise<string|null>}
   */
  async findPhoneByUserID(userId) {
    const rows = await query(
      'SELECT phone FROM users WHERE userId = ?',
      [userId]
    );
    if (rows.length === 0) return null;
    const phone = rows[0].phone;
    // 脱敏手机号：138****8000
    return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
  }

  /**
   * 获取所有用户
   * @returns {Promise<Array>}
   */
  async findAll() {
    return await query('SELECT * FROM users ORDER BY created_at DESC');
  }

  /**
   * 保存或更新用户会话
   * @param {string} userId
   * @param {string} accessToken
   * @param {string} refreshToken
   * @param {string} expiresAt - ISO 时间字符串
   * @param {string} deviceId
   */
  async upsertSession(userId, accessToken, refreshToken, expiresAt, deviceId) {
    await query(
      `UPDATE users SET access_token = ?, refresh_token = ?, token_expires_at = ?, device_id = ?
       WHERE userId = ?`,
      [accessToken, refreshToken, expiresAt, deviceId, userId]
    );
  }

  /**
   * 根据 access_token 查找用户
   * @param {string} accessToken
   * @returns {Promise<Object|null>}
   */
  async findByAccessToken(accessToken) {
    const rows = await query(
      'SELECT * FROM users WHERE access_token = ?',
      [accessToken]
    );
    return rows.length > 0 ? rows[0] : null;
  }

  /**
   * 清除用户会话（退出登录时调用）
   * @param {string} userId
   */
  async clearSession(userId) {
    await query(
      'UPDATE users SET access_token = NULL, refresh_token = NULL, token_expires_at = NULL, device_id = NULL WHERE userId = ?',
      [userId]
    );
  }
}

module.exports = UserMysqlRepository;