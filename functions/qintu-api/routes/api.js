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

// 导入各模块路由
const authRoutes = require('../routes/auth');
const userRoutes = require('../routes/users');
const bindingRoutes = require('../routes/bindings');
const taskRoutes = require('../routes/tasks');
const locationRoutes = require('../routes/locations');

// 挂载路由
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/bindings', bindingRoutes);
router.use('/tasks', taskRoutes);
router.use('/locations', locationRoutes);

module.exports = router;
