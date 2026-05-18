/**
 * 路由分享 Repository（内存版）
 *
 * 存储待接收的路由分享数据
 */

class RouteShareRepository {
  constructor() {
    // 待接收的路由分享列表
    // 结构: Map<receiverUserID, RouteShareItem[]>
    this._shares = new Map();
  }

  /**
   * 添加路由分享
   * @param {string} receiverUserID - 接收者user_ID
   * @param {Object} share - 路由分享数据
   * @param {string} share.senderUserID - 发送者user_ID
   * @param {string} share.senderNickname - 发送者昵称
   */
  addShare(receiverUserID, share) {
    if (!this._shares.has(receiverUserID)) {
      this._shares.set(receiverUserID, []);
    }
    this._shares.get(receiverUserID).push({
      ...share,
      id: Date.now().toString(),
      createdAt: new Date().toISOString()
    });
  }

  /**
   * 获取接收者的所有待处理路由分享
   * @param {string} receiverUserID - 接收者user_ID
   * @returns {RouteShareItem[]}
   */
  getShares(receiverUserID) {
    return this._shares.get(receiverUserID) || [];
  }

  /**
   * 移除路由分享
   * @param {string} receiverUserID - 接收者user_ID
   * @param {string} shareId - 分享ID
   */
  removeShare(receiverUserID, shareId) {
    const shares = this._shares.get(receiverUserID);
    if (!shares) return false;

    const index = shares.findIndex(s => s.id === shareId);
    if (index === -1) return false;

    shares.splice(index, 1);
    return true;
  }

  /**
   * 清除接收者的所有路由分享
   * @param {string} receiverUserID - 接收者user_ID
   */
  clearShares(receiverUserID) {
    this._shares.delete(receiverUserID);
  }
}

module.exports = RouteShareRepository;