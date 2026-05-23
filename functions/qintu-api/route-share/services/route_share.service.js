/**
 * 路由分享服务（内存存储）
 *
 * 路线数据一次性使用，接收后即销毁，不持久化
 */

class RouteShareService {
  constructor() {
    // 内存存储：Map<receiverUserID, Array<ShareData>>
    this._shares = new Map();
    // 简单的自增ID
    this._idCounter = 1;
  }

  /**
   * 发送路由分享
   * @param {string} senderUserID - 发送者userId
   * @param {string} receiverUserID - 接收者userId（绑定者）
   * @param {Object} origin - 起点 { latitude, longitude, name, address }
   * @param {Object} destination - 终点 { latitude, longitude, name, address }
   * @param {string} routeType - 出行方式
   * @param {number} routeId - 路线ID
   */
  async sendRouteShare(senderUserID, receiverUserID, origin, destination, routeType, routeId) {
    const shareId = `share_${this._idCounter++}`;
    const shareData = {
      id: shareId,
      senderUserID,
      receiverUserID,
      origin,
      destination,
      routeType: routeType || 'driving',
      routeId: routeId || 0,
      createdAt: new Date().toISOString()
    };

    // 存入内存
    if (!this._shares.has(receiverUserID)) {
      this._shares.set(receiverUserID, []);
    }
    this._shares.get(receiverUserID).push(shareData);

    console.log(`[RouteShare] 路线已分享: ${shareId} -> ${receiverUserID}`);

    return {
      id: shareId,
      message: '路线已分享'
    };
  }

  /**
   * 获取待接收的路由分享（接收后即销毁）
   * @param {string} receiverUserID - 接收者userId
   */
  async getPendingShares(receiverUserID) {
    const shares = this._shares.get(receiverUserID) || [];

    if (shares.length === 0) {
      return [];
    }

    // 取第一个并销毁（一次性）
    const [share] = shares.splice(0, 1);

    // 如果空了，删除 key
    if (shares.length === 0) {
      this._shares.delete(receiverUserID);
    }

    console.log(`[RouteShare] 路线已接收并销毁: ${share.id}`);

    // 以嵌套结构返回，匹配 Flutter 端 PendingRouteShare.fromJson 的解析逻辑
    return [{
      id: share.id,
      senderUserID: share.senderUserID,
      senderNickname: '绑定用户',
      receiverUserID: share.receiverUserID,
      origin: {
        latitude: share.origin.latitude,
        longitude: share.origin.longitude,
        name: share.origin.name,
        address: share.origin.address || ''
      },
      destination: {
        latitude: share.destination.latitude,
        longitude: share.destination.longitude,
        name: share.destination.name,
        address: share.destination.address || ''
      },
      routeType: share.routeType,
      routeId: share.routeId,
      createdAt: share.createdAt
    }];
  }

  /**
   * 标记路由分享为已读（内存模式已不需要，实际调用 getPendingShares 时已销毁）
   */
  async markAsRead(shareId, receiverUserID) {
    // 内存模式不需要此操作
    return { message: '已标记为已读' };
  }
}

module.exports = RouteShareService;