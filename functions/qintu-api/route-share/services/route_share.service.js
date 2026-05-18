/**
 * 路由分享 Service
 *
 * 处理路由分享的业务逻辑
 */

class RouteShareService {
  constructor(routeShareRepo, bindingService) {
    this._repo = routeShareRepo;
    this._bindingService = bindingService;
  }

  /**
   * 发送路由分享
   * @param {Object} params
   * @param {string} params.senderOpenid - 发送者user_ID
   * @param {string} params.receiverOpenid - 接收者user_ID
   * @param {Object} params.origin - 起点信息 { latitude, longitude, name, address }
   * @param {Object} params.destination - 终点信息 { latitude, longitude, name, address }
   * @param {string} params.routeType - 出行方式 (driving/walking/riding)
   */
  async sendRouteShare({ senderOpenid, receiverOpenid, origin, destination, routeType, routeId }) {
    // 校验必填参数
    if (!senderOpenid || !receiverOpenid) {
      throw new Error('发送者和接收者user_ID不能为空');
    }
    if (!origin || !origin.latitude || !origin.longitude) {
      throw new Error('起点坐标不能为空');
    }
    if (!destination || !destination.latitude || !destination.longitude) {
      throw new Error('终点坐标不能为空');
    }
    if (!routeType || !['driving', 'walking', 'riding', 'transit'].includes(routeType)) {
      throw new Error('出行方式不正确');
    }

    // 校验接收者是否是有效的绑定关系，并获取发送者昵称
    const bindingsData = await this._bindingService.getMyBindings(senderOpenid);
    const bindings = bindingsData.bindings || [];
    const binding = bindings.find(b => b.partner_user_ID === receiverOpenid);
    if (!binding) {
      throw new Error('接收者不是有效的绑定对象');
    }
    const senderNickname = binding.sender_nickname || '好友';

    // 存储路由分享
    const share = {
      senderOpenid,
      senderNickname,
      receiverOpenid,
      origin,
      destination,
      routeType,
      routeId,
      status: 'pending'
    };

    this._repo.addShare(receiverOpenid, share);

    return { success: true, message: '路由分享已发送' };
  }

  /**
   * 获取待接收的路由分享
   * @param {string} receiverOpenid - 接收者user_ID
   */
  getPendingShares(receiverOpenid) {
    return this._repo.getShares(receiverOpenid);
  }

  /**
   * 标记路由分享已处理
   * @param {string} receiverOpenid - 接收者user_ID
   * @param {string} shareId - 分享ID
   */
  markAsRead(receiverOpenid, shareId) {
    return this._repo.removeShare(receiverOpenid, shareId);
  }
}

module.exports = RouteShareService;