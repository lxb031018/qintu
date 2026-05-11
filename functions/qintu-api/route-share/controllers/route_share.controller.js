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
      const { receiverOpenid, origin, destination, routeType } = req.body;
      const senderOpenid = req.user.openid;

      console.log('[RouteShare] ===== 收到路由分享请求 =====');
      console.log('[RouteShare] 发送者openid:', senderOpenid);
      console.log('[RouteShare] 接收者openid:', receiverOpenid);
      console.log('[RouteShare] 起点:', JSON.stringify(origin));
      console.log('[RouteShare] 终点:', JSON.stringify(destination));
      console.log('[RouteShare] 出行方式:', routeType);
      console.log('[RouteShare] ==============================');

      const result = await this._service.sendRouteShare({
        senderOpenid,
        receiverOpenid,
        origin,
        destination,
        routeType
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
      const receiverOpenid = req.user.openid;
      const shares = this._service.getPendingShares(receiverOpenid);

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
      const receiverOpenid = req.user.openid;
      const { shareId } = req.params;

      const success = this._service.markAsRead(receiverOpenid, shareId);

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