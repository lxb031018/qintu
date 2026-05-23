/**
 * 绑定关系 MySQL Repository
 *
 * 单表设计：user_bindings 表同时存储 pending 和 active 状态的绑定
 * 存储规则：userA < userB（字符串比较，小的在前）
 */

const { query } = require('../../db/mysql');

class BindingMysqlRepository {
  /**
   * 确保 userA < userB
   */
  _orderUsers(userId_1, userId_2) {
    return userId_1 < userId_2
      ? { userA: userId_1, userB: userId_2 }
      : { userA: userId_2, userB: userId_1 };
  }

  /**
   * 创建待确认的绑定请求（pending 状态）
   * @param {string} senderUserID - 发送者 userId
   * @param {string} receiverUserID - 接收者 userId
   * @param {string} senderName - 发送者对接收者的称呼
   * @param {string} receiverName - 接收者对发送者的称呼
   * @param {Date} expiresAt - 过期时间
   */
  async createPendingBinding(senderUserID, receiverUserID, senderName, receiverName, expiresAt) {
    const { userA, userB } = this._orderUsers(senderUserID, receiverUserID);

    // 确定谁是 A 谁是 B
    const isUserAIsSender = userA === senderUserID;
    const name_A_to_B = isUserAIsSender ? senderName : receiverName;
    const name_B_to_A = isUserAIsSender ? receiverName : senderName;

    try {
      const result = await query(
        `INSERT INTO user_bindings (userA, userB, sender_userId, name_A_to_B, name_B_to_A, status, expires_at)
         VALUES (?, ?, ?, ?, ?, 'pending', ?)`,
        [userA, userB, senderUserID, name_A_to_B, name_B_to_A, expiresAt]
      );
      return { id: result.insertId, userA, userB, name_A_to_B, name_B_to_A, status: 'pending' };
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        return { userA, userB, name_A_to_B, name_B_to_A, status: 'pending', alreadyExists: true };
      }
      throw error;
    }
  }

  /**
   * 确认绑定（将 pending 变为 active）
   * @param {string} myUserID - 我的 userId
   * @param {string} partnerUserID - 对方的 userId
   */
  async activateBinding(myUserID, partnerUserID) {
    const { userA, userB } = this._orderUsers(myUserID, partnerUserID);

    const result = await query(
      `UPDATE user_bindings SET status = 'active', bound_at = NOW()
       WHERE userA = ? AND userB = ? AND status = 'pending'`,
      [userA, userB]
    );

    return result.affectedRows > 0;
  }

  /**
   * 拒绝/取消绑定（删除 pending 记录）
   * @param {string} userId_1 - 用户1的 userId
   * @param {string} userId_2 - 用户2的 userId
   */
  async deletePending(userId_1, userId_2) {
    const { userA, userB } = this._orderUsers(userId_1, userId_2);

    const result = await query(
      `DELETE FROM user_bindings
       WHERE userA = ? AND userB = ? AND status = 'pending'`,
      [userA, userB]
    );

    return result.affectedRows > 0;
  }

  /**
   * 删除绑定关系（解绑）
   * @param {string} userId_1 - 用户1的 userId
   * @param {string} userId_2 - 用户2的 userId
   */
  async delete(userId_1, userId_2) {
    const { userA, userB } = this._orderUsers(userId_1, userId_2);

    const result = await query(
      'DELETE FROM user_bindings WHERE userA = ? AND userB = ?',
      [userA, userB]
    );

    return result.affectedRows > 0;
  }

  /**
   * 检查是否存在指定状态的绑定
   * @param {string} userId_1 - 用户1的 userId
   * @param {string} userId_2 - 用户2的 userId
   * @param {string} status - 状态
   */
  async existsWithStatus(userId_1, userId_2, status) {
    const { userA, userB } = this._orderUsers(userId_1, userId_2);

    const rows = await query(
      'SELECT 1 FROM user_bindings WHERE userA = ? AND userB = ? AND status = ?',
      [userA, userB, status]
    );

    return rows.length > 0;
  }

  /**
   * 检查两个用户是否已绑定（active 状态）
   * @param {string} userId_1 - 用户1的 userId
   * @param {string} userId_2 - 用户2的 userId
   */
  async exists(userId_1, userId_2) {
    return this.existsWithStatus(userId_1, userId_2, 'active');
  }

  /**
   * 检查是否存在待处理的绑定请求（pending 状态）
   * @param {string} senderUserID - 发送者 userId
   * @param {string} receiverUserID - 接收者 userId
   */
  async hasPendingRequest(senderUserID, receiverUserID) {
    return this.existsWithStatus(senderUserID, receiverUserID, 'pending');
  }

  /**
   * 获取接收者的待确认请求
   * @param {string} receiverUserID - 接收者 userId
   */
  async findPendingForReceiver(receiverUserID) {
    // 找出所有 receiver 是 receiverUserID 且 status=pending 的记录
    // 由于 userA < userB，receiver 可能是 userA 或 userB
    const rows = await query(
      `SELECT * FROM user_bindings
       WHERE ((userA = ? OR userB = ?) AND status = 'pending' AND expires_at > NOW())
       ORDER BY created_at DESC`,
      [receiverUserID, receiverUserID]
    );
    return rows;
  }

  /**
   * 获取发送者的已发请求
   * @param {string} senderUserID - 发送者 userId
   */
  async findSentBySender(senderUserID) {
    const rows = await query(
      `SELECT * FROM user_bindings
       WHERE sender_userId = ? AND status = 'pending' AND expires_at > NOW()
       ORDER BY created_at DESC`,
      [senderUserID]
    );
    return rows;
  }

  /**
   * 获取用户的活跃绑定
   * @param {string} userId - 用户ID
   */
  async findActiveForUser(userId) {
    const rows = await query(
      'SELECT * FROM user_bindings WHERE (userA = ? OR userB = ?) AND status = ?',
      [userId, userId, 'active']
    );
    return rows;
  }

  /**
   * 获取用户的所有绑定（含 pending）
   * @param {string} userId - 用户ID
   */
  async findAllForUser(userId) {
    const rows = await query(
      'SELECT * FROM user_bindings WHERE userA = ? OR userB = ?',
      [userId, userId]
    );

    return rows.map(row => ({
      id: row.id,
      userA: row.userA,
      userB: row.userB,
      partner_userId: row.userA === userId ? row.userB : row.userA,
      sender_userId: row.senderUserId,
      name_A_to_B: row.name_A_to_B,
      name_B_to_A: row.name_B_to_A,
      status: row.status,
      created_at: row.created_at,
      expires_at: row.expires_at,
      bound_at: row.bound_at
    }));
  }

  /**
   * 获取绑定数量
   * @param {string} userId - 用户ID
   */
  async countForUser(userId) {
    const rows = await query(
      `SELECT COUNT(*) as count FROM user_bindings
       WHERE (userA = ? OR userB = ?) AND status = 'active'`,
      [userId, userId]
    );
    return rows[0].count;
  }

  /**
   * 修改我对对方的称呼
   * @param {string} myUserID - 我的 userId
   * @param {string} partnerUserID - 对方的 userId
   * @param {string} newName - 新的称呼
   */
  async modifyName(myUserID, partnerUserID, newName) {
    const { userA, userB } = this._orderUsers(myUserID, partnerUserID);

    // 根据我的身份决定更新哪个字段
    const field = myUserID === userA ? 'name_A_to_B' : 'name_B_to_A';

    const result = await query(
      `UPDATE user_bindings SET ${field} = ? WHERE userA = ? AND userB = ?`,
      [newName, userA, userB]
    );

    return result.affectedRows > 0;
  }

  /**
   * 清理过期的 pending 请求
   * @returns {Promise<number>} 删除的行数
   */
  async expireOldRequests() {
    const result = await query(
      `DELETE FROM user_bindings WHERE status = 'pending' AND expires_at <= NOW()`
    );
    return result.affectedRows || 0;
  }
}

module.exports = BindingMysqlRepository;