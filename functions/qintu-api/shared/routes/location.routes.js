/**
 * 位置路由
 */

const express = require('express');
const router = express.Router();
const LocationController = require('../../location/controllers/location.controller');
const LocationService = require('../../location/services/location.service');
const { createRepositories } = require('../../repositories');
const { requireAuth } = require('../../shared/middleware/auth.middleware');

// 创建依赖
const { bindingRepo, locationRepo, userRepo } = createRepositories('memory');
const locationService = new LocationService(bindingRepo, locationRepo, userRepo);
const locationController = new LocationController(locationService);

// 需要认证
router.use(requireAuth);

// 更新位置
router.post('/update', (req, res) => locationController.updateLocation(req, res));

// 查询位置
router.get('/:receiverOpenid', (req, res) => locationController.getLocation(req, res));

// 共享开关（兼容旧逻辑）
router.post('/sharing/toggle', (req, res) => locationController.toggleSharing(req, res));

module.exports = router;
