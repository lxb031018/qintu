/**
 * API 路由总入口
 *
 * 路由结构：
 * /api/users        - 用户管理
 * /api/bindings     - 绑定关系管理
 * /api/tasks        - 导航任务管理
 * /api/locations    - 实时位置管理
 */

const express = require('express');
const router = express.Router();

// 简单测试路由
router.get('/test', (req, res) => {
  res.json({
    status: 'ok',
    message: 'API router loaded successfully',
    timestamp: new Date().toISOString()
  });
});

// 导入各模块路由
const authRoutes = require('../routes/mock_auth'); // 🌟 使用新的 Mock 认证路由
const bindingRoutes = require('../routes/bindings-memory'); // 🌟 使用内存版绑定路由（本地开发/测试）
const userRoutes = require('../routes/users'); // 🌟 用户管理路由
const taskRoutes = require('../routes/tasks'); // 🌟 导航任务管理路由（RESTful API 版）
const locationRoutes = require('../routes/locations'); // 🌟 实时位置管理路由（RESTful API 版）

// 挂载路由
router.use('/auth', authRoutes);
router.use('/bindings', bindingRoutes);
router.use('/users', userRoutes);
router.use('/tasks', taskRoutes);
router.use('/locations', locationRoutes);

module.exports = router;
