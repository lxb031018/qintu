/**
 * 位置路由
 */

const express = require('express');
const router = express.Router();
const LocationController = require('../../location/controllers/location.controller');
const { requireAuth } = require('../../shared/middleware/auth.middleware');

/**
 * 创建位置路由
 * @param {LocationService} locationService - 位置服务实例
 */
function createLocationRoutes(locationService) {
  const locationController = new LocationController(locationService);

  // 需要认证
  router.use(requireAuth);

  // 更新位置
  router.post('/update', (req, res) => locationController.updateLocation(req, res));

  // 查询位置
  router.get('/:receiverOpenid', (req, res) => locationController.getLocation(req, res));

  // 共享开关（兼容旧逻辑）
  router.post('/sharing/toggle', (req, res) => locationController.toggleSharing(req, res));

  // 删除位置
  router.delete('/', (req, res) => locationController.deleteLocation(req, res));

  return router;
}

module.exports = createLocationRoutes;
