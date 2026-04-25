/**
 * 路由总入口
 */

const express = require('express');
const router = express.Router();

// 导入各模块路由
const authRoutes = require('./auth.routes');
const bindingRoutes = require('./binding.routes');
const userRoutes = require('./user.routes');
const taskRoutes = require('./task.routes');
const locationRoutes = require('./location.routes');

// 挂载路由
// 认证路由：/auth/v1/* 和 /auth/api/auth/*
router.use('/auth', authRoutes);

// API 业务路由：/api/bindings/*, /api/users/*, /api/tasks/*, /api/locations/*
router.use('/api/bindings', bindingRoutes);
router.use('/api/users', userRoutes);
router.use('/api/tasks', taskRoutes);
router.use('/api/locations', locationRoutes);

// 简单测试路由
router.get('/test', (req, res) => {
  res.json({
    status: 'ok',
    message: 'API router loaded successfully',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;
