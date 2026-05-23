/**
 * 绑定路由
 *
 * 完整流程：
 * - POST /request-phone - 发送绑定请求
 * - GET /pending - 获取收到的请求
 * - GET /sent - 获取发出的请求
 * - POST /confirm-request - 接受请求
 * - POST /reject-request - 拒绝请求
 * - DELETE /requests/:id - 取消发出的请求
 * - GET /my - 获取绑定列表
 * - DELETE /:partner_userId - 解绑
 * - PATCH /:partner_userId - 修改称呼
 */

const express = require('express');
const router = express.Router();
const BindingController = require('../../binding/controllers/binding.controller');
const { requireAuth } = require('../../shared/middleware/auth.middleware');

function createBindingRoutes(bindingService) {
  const bindingController = new BindingController(bindingService);

  // 需要认证
  router.use(requireAuth);

  // ===== 绑定请求相关 =====

  // 发送绑定请求
  router.post('/request-phone', (req, res) => bindingController.requestBinding(req, res));

  // 获取我收到的待确认请求
  router.get('/pending', (req, res) => bindingController.getPendingRequests(req, res));

  // 获取我发出的请求
  router.get('/sent', (req, res) => bindingController.getSentRequests(req, res));

  // 确认（接受）绑定请求
  router.post('/confirm-request', (req, res) => bindingController.confirmRequest(req, res));

  // 拒绝绑定请求
  router.post('/reject-request', (req, res) => bindingController.rejectRequest(req, res));

  // 取消发出的请求
  router.delete('/requests/:id', (req, res) => bindingController.cancelRequest(req, res));

  // ===== 绑定关系相关 =====

  // 获取我的所有绑定
  router.get('/my', (req, res) => bindingController.getMyBindings(req, res));

  // 解绑用户
  router.delete('/:partner_userId', (req, res) => bindingController.unbind(req, res));

  // 修改我对对方的称呼
  router.patch('/:partner_userId', (req, res) => bindingController.modifyName(req, res));

  return router;
}

module.exports = createBindingRoutes;