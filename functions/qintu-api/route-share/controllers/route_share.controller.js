/**
 * 路由分享 Controller
 *
 * 处理路由分享相关HTTP请求
 */

class RouteShareController {
  constructor(routeShareService) {
    this._service = routeShareService;
  }

  /**
   * 发送路由分享
   * POST /api/route-share/send
   */
  async sendRouteShare(req, res) {
    try {
      const { receiverUserID, origin, destination, routeType, routeId } = req.body;
      const senderUserID = req.user.user_ID;

      console.log('[RouteShare] ===== 收到路由分享请求 =====');
      console.log('[RouteShare] 发送者user_ID:', senderUserID);
      console.log('[RouteShare] 接收者user_ID:', receiverUserID);
      console.log('[RouteShare] 起点:', JSON.stringify(origin));
      console.log('[RouteShare] 终点:', JSON.stringify(destination));
      console.log('[RouteShare] 出行方式:', routeType);
      console.log('[RouteShare] routeId:', routeId);
      console.log('[RouteShare] ==============================');

      const result = await this._service.sendRouteShare({
        senderUserID,
        receiverUserID,
        origin,
        destination,
        routeType,
        routeId
      });

      res.json({
        code: 0,
        message: 'success',
        data: result
      });
    } catch (error) {
      console.error('[RouteShare] 发送路由分享失败:', error.message);
      res.status(400).json({
        code: 400,
        message: error.message
      });
    }
  }

  /**
   * 获取待接收的路由分享
   * GET /api/route-share/pending
   */
  getPendingShares(req, res) {
    try {
      const receiverUserID = req.user.user_ID;
      const shares = this._service.getPendingShares(receiverUserID);

      res.json({
        code: 0,
        message: 'success',
        data: shares
      });
    } catch (error) {
      console.error('[RouteShare] 获取待接收路由分享失败:', error.message);
      res.status(400).json({
        code: 400,
        message: error.message
      });
    }
  }

  /**
   * 标记路由分享已处理
   * DELETE /api/route-share/:shareId
   */
  markAsRead(req, res) {
    try {
      const receiverUserID = req.user.user_ID;
      const { shareId } = req.params;

      const success = this._service.markAsRead(receiverUserID, shareId);

      res.json({
        code: 0,
        message: success ? 'success' : 'share not found',
        data: { success }
      });
    } catch (error) {
      console.error('[RouteShare] 标记路由分享失败:', error.message);
      res.status(400).json({
        code: 400,
        message: error.message
      });
    }
  }
}

module.exports = RouteShareController;