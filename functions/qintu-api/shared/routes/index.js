/**
 * 路由总入口
 */

const express = require('express');
const router = express.Router();

// 导入各模块路由（接收 services）
const authRoutes = require('./auth.routes');
const bindingRoutes = require('./binding.routes');
const avatarRoutes = require('./avatar.routes');
const userRoutes = require('./user.routes');
const locationRoutes = require('./location.routes');

/**
 * 配置路由
 * @param {Object} services - 包含所有 service 实例的对象
 */
function configureRoutes(services) {
  // 挂载路由
  // 认证路由：/auth/v1/* 和 /auth/api/auth/*
  router.use('/auth', authRoutes(services.authService));

  // 绑定路由：/api/bindings/*
  router.use('/api/bindings', bindingRoutes(services.bindingService));

  // 位置路由：/api/locations/*
  router.use('/api/locations', locationRoutes(services.locationService));

  // 头像上传路由：/api/avatar/*
  router.use('/api/avatar', avatarRoutes(services));

  // 用户路由：/api/users/*
  router.use('/api/users', userRoutes(services.userService));

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
