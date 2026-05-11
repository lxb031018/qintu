/**
 * 路由分享路由
 */

const express = require('express');
const router = express.Router();
const RouteShareController = require('../../route-share/controllers/route_share.controller');
const { requireAuth } = require('../../shared/middleware/auth.middleware');

/**
 * 创建路由分享路由
 * @param {RouteShareService} routeShareService - 路由分享服务实例
 */
function createRouteShareRoutes(routeShareService) {
  const routeShareController = new RouteShareController(routeShareService);

  // 需要认证
  router.use(requireAuth);

  // 发送路由分享
  router.post('/send', (req, res) => routeShareController.sendRouteShare(req, res));

  // 获取待接收的路由分享
  router.get('/pending', (req, res) => routeShareController.getPendingShares(req, res));

  // 标记路由分享已处理
  router.delete('/:shareId', (req, res) => routeShareController.markAsRead(req, res));

  return router;
}

module.exports = createRouteShareRoutes;