/**
 * 绑定关系 MySQL Repository
 *
 * 简化版：直接绑定，解绑删除记录
 * 存储规则：user_A < user_B（字符串比较，小的在前）
 */

const { query } = require('../../db/mysql');

class BindingMysqlRepository {
  /**
   * 确保 user_A < user_B
   */
  _orderUsers(user_ID_1, user_ID_2) {
    return user_ID_1 < user_ID_2
      ? { user_A: user_ID_1, user_B: user_ID_2 }
      : { user_A: user_ID_2, user_B: user_ID_1 };
  }

  /**
   * 创建绑定关系
   * @param {string} user_ID_1 - 用户1的 user_ID
   * @param {string} user_ID_2 - 用户2的 user_ID
   * @param {string} name_A_to_B - A对B的称呼
   * @param {string} name_B_to_A - B对A的称呼
   */
  async createWithNames(user_ID_1, user_ID_2, name_A_to_B, name_B_to_A) {
    const { user_A, user_B } = this._orderUsers(user_ID_1, user_ID_2);

    try {
      await query(
        'INSERT INTO user_bindings (user_A, user_B, name_A_to_B, name_B_to_A) VALUES (?, ?, ?, ?)',
        [user_A, user_B, name_A_to_B, name_B_to_A]
      );
      return { user_A, user_B, name_A_to_B, name_B_to_A };
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        return { user_A, user_B, name_A_to_B, name_B_to_A, alreadyExists: true };
      }
      throw error;
    }
  }

  /**
   * 删除绑定关系
   * @param {string} user_ID_1 - 用户1的 user_ID
   * @param {string} user_ID_2 - 用户2的 user_ID
   */
  async delete(user_ID_1, user_ID_2) {
    const { user_A, user_B } = this._orderUsers(user_ID_1, user_ID_2);

    const result = await query(
      'DELETE FROM user_bindings WHERE user_A = ? AND user_B = ?',
      [user_A, user_B]
    );

    return result.affectedRows > 0;
  }

  /**
   * 检查两个用户是否已绑定
   * @param {string} user_ID_1 - 用户1的 user_ID
   * @param {string} user_ID_2 - 用户2的 user_ID
   */
  async exists(user_ID_1, user_ID_2) {
    const { user_A, user_B } = this._orderUsers(user_ID_1, user_ID_2);

    const rows = await query(
      'SELECT 1 FROM user_bindings WHERE user_A = ? AND user_B = ?',
      [user_A, user_B]
    );

    return rows.length > 0;
  }

  /**
   * 获取用户的所有绑定关系
   * @param {string} user_ID - 用户ID
   */
  async findAllForUser(user_ID) {
    const rows = await query(
      'SELECT * FROM user_bindings WHERE user_A = ? OR user_B = ?',
      [user_ID, user_ID]
    );

    return rows.map(row => ({
      user_A: row.user_A,
      user_B: row.user_B,
      partner_user_ID: row.user_A === user_ID ? row.user_B : row.user_A,
      name_A_to_B: row.name_A_to_B,
      name_B_to_A: row.name_B_to_A
    }));
  }

  /**
   * 获取绑定数量
   * @param {string} user_ID - 用户ID
   */
  async countForUser(user_ID) {
    const rows = await query(
      'SELECT COUNT(*) as count FROM user_bindings WHERE user_A = ? OR user_B = ?',
      [user_ID, user_ID]
    );
    return rows[0].count;
  }

  /**
   * 修改我对对方的称呼
   * @param {string} myUserID - 我的 user_ID
   * @param {string} partnerUserID - 对方的 user_ID
   * @param {string} newName - 新的称呼
   */
  async modifyName(myUserID, partnerUserID, newName) {
    const { user_A, user_B } = this._orderUsers(myUserID, partnerUserID);

    // 根据我的身份决定更新哪个字段
    const field = myUserID === user_A ? 'name_A_to_B' : 'name_B_to_A';

    const result = await query(
      `UPDATE user_bindings SET ${field} = ? WHERE user_A = ? AND user_B = ?`,
      [newName, user_A, user_B]
    );

    return result.affectedRows > 0;
  }
}

module.exports = BindingMysqlRepository;