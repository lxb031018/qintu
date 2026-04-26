/**
 * 路由总入口
 */

const express = require('express');
const router = express.Router();

// 导入各模块路由（接收 services）
const authRoutes = require('./auth.routes');
const bindingRoutes = require('./binding.routes');
const userRoutes = require('./user.routes');
const taskRoutes = require('./task.routes');
const locationRoutes = require('./location.routes');

/**
 * 配置路由
 * @param {Object} services - 包含所有 service 实例的对象
 */
function configureRoutes(services) {
  // 挂载路由
  // 认证路由：/auth/v1/* 和 /auth/api/auth/*
  router.use('/auth', authRoutes(services.authService));

  // API 业务路由：/api/bindings/*, /api/users/*, /api/tasks/*, /api/locations/*
  router.use('/api/bindings', bindingRoutes(services.bindingService));
  router.use('/api/users', userRoutes(services.userService));
  router.use('/api/tasks', taskRoutes(services.taskService));
  router.use('/api/locations', locationRoutes(services.locationService));

  // 简单测试路由
  router.get('/test', (req, res) => {
    res.json({
      status: 'ok',
      message: 'API router loaded successfully',
      timestamp: new Date().toISOString()
    });
  });

  return router;
}

module.exports = configureRoutes;
