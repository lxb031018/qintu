/**
 * 用户路由
 */

const express = require('express');
const router = express.Router();
const UserController = require('../../user/controllers/user.controller');
const { requireAuth } = require('../../shared/middleware/auth.middleware');

/**
 * 创建用户路由
 * @param {UserService} userService - 用户服务实例
 */
function createUserRoutes(userService) {
  const userController = new UserController(userService);

  // 需要认证
  router.use(requireAuth);

  // 获取当前用户信息
  router.get('/me', (req, res) => userController.getMe(req, res));

  // 更新当前用户信息
  router.put('/me', (req, res) => userController.updateMe(req, res));

  // 同步用户信息
  router.post('/sync', (req, res) => userController.syncUser(req, res));

  // 获取指定用户信息
  router.get('/:openid', (req, res) => userController.getUser(req, res));

  return router;
}

module.exports = createUserRoutes;
