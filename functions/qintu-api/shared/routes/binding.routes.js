/**
 * 绑定路由
 */

const express = require('express');
const router = express.Router();
const BindingController = require('../../binding/controllers/binding.controller');
const { requireAuth } = require('../../shared/middleware/auth.middleware');

/**
 * 创建绑定路由
 * @param {BindingService} bindingService - 绑定服务实例
 */
function createBindingRoutes(bindingService) {
  const bindingController = new BindingController(bindingService);

  // 需要认证
  router.use(requireAuth);

  // 获取我的所有绑定
  router.get('/my', (req, res) => bindingController.getMyBindings(req, res));

  // 获取待确认的绑定请求
  router.get('/pending', (req, res) => bindingController.getPending(req, res));

  // 获取我发出的绑定请求
  router.get('/sent', (req, res) => bindingController.getSent(req, res));

  // 发送绑定请求（通过手机号）
  router.post('/request-phone', (req, res) => bindingController.requestByPhone(req, res));

  // 确认绑定请求
  router.post('/confirm-request', (req, res) => bindingController.confirmRequest(req, res));

  // 拒绝绑定请求
  router.post('/reject-request', (req, res) => bindingController.rejectRequest(req, res));

  // 解除绑定 / 取消请求
  router.delete('/:id', (req, res) => bindingController.revoke(req, res));

  return router;
}

module.exports = createBindingRoutes;
