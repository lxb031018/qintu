/**
 * 绑定路由（简化版）
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

  // 绑定用户（通过手机号）
  router.post('/', (req, res) => bindingController.bindByPhone(req, res));

  // 解绑用户
  router.delete('/:partner_user_id', (req, res) => bindingController.unbind(req, res));

  return router;
}

module.exports = createBindingRoutes;