/**
 * 路由分享控制器
 */

const { success, error } = require('../../shared/lib/response');

class RouteShareController {
  constructor(routeShareService) {
    this.routeShareService = routeShareService;
  }

  /**
   * 发送路由分享
   * POST /api/route-share/send
   */
  async sendRouteShare(req, res) {
    try {
      const senderUserID = req.user.userId;
      if (!senderUserID || senderUserID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const { receiverUserID, origin, destination, routeType, routeId } = req.body;

      if (!receiverUserID) {
        return error(res, 'receiverUserID 是必填参数', 'VALIDATION_ERROR', 400);
      }

      if (!origin || !destination) {
        return error(res, 'origin 和 destination 是必填参数', 'VALIDATION_ERROR', 400);
      }

      const result = await this.routeShareService.sendRouteShare(
        senderUserID,
        receiverUserID,
        origin,
        destination,
        routeType || 'driving',
        routeId || 0
      );

      return success(res, result, 201);
    } catch (err) {
      console.error('发送路由分享失败:', err);
      return error(res, err.message, err.code || 'SEND_ROUTE_SHARE_FAILED', err.status || 500);
    }
  }

  /**
   * 获取待接收的路由分享
   * GET /api/route-share/pending
   */
  async getPendingShares(req, res) {
    try {
      const userId = req.user.userId;
      if (!userId || userId === 'unknown_user') {
        return success(res, []);
      }

      const result = await this.routeShareService.getPendingShares(userId);
      return success(res, result);
    } catch (err) {
      console.error('获取待接收路由分享失败:', err);
      return error(res, err.message, err.code || 'GET_PENDING_FAILED', err.status || 500);
    }
  }

  /**
   * 标记路由分享已处理
   * DELETE /api/route-share/:shareId
   */
  async markAsRead(req, res) {
    try {
      const userId = req.user.userId;
      const { shareId } = req.params;

      if (!userId || userId === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      if (!shareId) {
        return error(res, 'shareId 是必填参数', 'VALIDATION_ERROR', 400);
      }

      const result = await this.routeShareService.markAsRead(shareId, userId);
      return success(res, result);
    } catch (err) {
      console.error('标记已读失败:', err);
      return error(res, err.message, err.code || 'MARK_AS_READ_FAILED', err.status || 500);
    }
  }
}

module.exports = RouteShareController;