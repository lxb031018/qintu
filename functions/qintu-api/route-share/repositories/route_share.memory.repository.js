/**
 * 路由分享 Repository（内存版）
 *
 * 存储待接收的路由分享数据
 */

class RouteShareRepository {
  constructor() {
    // 待接收的路由分享列表
    // 结构: Map<receiverOpenid, RouteShareItem[]>
    this._shares = new Map();
  }

  /**
   * 添加路由分享
   * @param {string} receiverOpenid - 接收者openid
   * @param {Object} share - 路由分享数据
   */
  addShare(receiverOpenid, share) {
    if (!this._shares.has(receiverOpenid)) {
      this._shares.set(receiverOpenid, []);
    }
    this._shares.get(receiverOpenid).push({
      ...share,
      id: Date.now().toString(),
      createdAt: new Date().toISOString()
    });
  }

  /**
   * 获取接收者的所有待处理路由分享
   * @param {string} receiverOpenid - 接收者openid
   * @returns {RouteShareItem[]}
   */
  getShares(receiverOpenid) {
    return this._shares.get(receiverOpenid) || [];
  }

  /**
   * 移除路由分享
   * @param {string} receiverOpenid - 接收者openid
   * @param {string} shareId - 分享ID
   */
  removeShare(receiverOpenid, shareId) {
    const shares = this._shares.get(receiverOpenid);
    if (!shares) return false;

    const index = shares.findIndex(s => s.id === shareId);
    if (index === -1) return false;

    shares.splice(index, 1);
    return true;
  }

  /**
   * 清除接收者的所有路由分享
   * @param {string} receiverOpenid - 接收者openid
   */
  clearShares(receiverOpenid) {
    this._shares.delete(receiverOpenid);
  }
}

module.exports = RouteShareRepository;