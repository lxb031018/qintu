/**
 * 用户 MySQL Repository
 *
 * 管理用户数据的持久化存储
 */

const { query, transaction } = require('../../db/mysql');

class UserMysqlRepository {
  /**
   * 根据手机号查找 user_ID
   * @param {string} phone - 11位手机号
   * @returns {Promise<string|null>}
   */
  async findUserIDByPhone(phone) {
    const rows = await query(
      'SELECT user_ID FROM users WHERE phone = ?',
      [phone]
    );
    return rows.length > 0 ? rows[0].user_ID : null;
  }

  /**
   * 注册用户（手机号 -> user_ID 映射）
   * 使用 INSERT IGNORE 避免重复插入
   * @param {string} phone - 手机号
   * @param {string} user_ID - 用户 user_ID
   */
  async registerByPhone(phone, user_ID) {
    await query(
      `INSERT IGNORE INTO users (user_ID, phone, created_at)
       VALUES (?, ?, NOW())`,
      [user_ID, phone]
    );
  }

  /**
   * 根据 user_ID 查找用户
   * @param {string} user_ID
   * @returns {Promise<Object|null>}
   */
  async findByUserID(user_ID) {
    const rows = await query(
      'SELECT * FROM users WHERE user_ID = ?',
      [user_ID]
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
   * @param {string} user_ID
   * @param {Object} userData - 用户数据
   */
  async upsert(user_ID, userData) {
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
    if (userData.last_login_at !== undefined) {
      fields.push('last_login_at = ?');
      values.push(userData.last_login_at);
    }

    if (fields.length === 0) return;

    values.push(user_ID);
    await query(
      `UPDATE users SET ${fields.join(', ')} WHERE user_ID = ?`,
      values
    );
  }

  /**
   * 更新最后登录时间
   * @param {string} user_ID
   */
  async updateLastLogin(user_ID) {
    await query(
      'UPDATE users SET last_login_at = NOW() WHERE user_ID = ?',
      [user_ID]
    );
  }

  /**
   * 根据 user_ID 反查脱敏手机号
   * @param {string} user_ID
   * @returns {Promise<string|null>}
   */
  async findPhoneByUserID(user_ID) {
    const rows = await query(
      'SELECT phone FROM users WHERE user_ID = ?',
      [user_ID]
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
}

module.exports = UserMysqlRepository;