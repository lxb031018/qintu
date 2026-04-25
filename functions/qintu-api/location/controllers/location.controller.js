/**
 * 位置控制器
 */

const { success, validationError, error, notFound } = require('../../shared/lib/response');

class LocationController {
  constructor(locationService) {
    this.locationService = locationService;
  }

  /**
   * 更新位置
   * POST /api/locations/update
   */
  async updateLocation(req, res) {
    try {
      const openid = req.user.openid;
      const { latitude, longitude, accuracy, speed, bearing, altitude } = req.body;

      // 参数验证
      if (latitude === undefined || longitude === undefined) {
        return validationError(res, 'latitude 和 longitude 是必需参数');
      }

      const result = await this.locationService.updateLocation(openid, {
        latitude,
        longitude,
        accuracy,
        speed,
        bearing,
        altitude
      });

      if (process.env.NODE_ENV !== 'production') {
        console.log(`[Locations] 位置更新: ${openid} → lat=${latitude.toFixed(6)}, lng=${longitude.toFixed(6)}`);
      }

      return success(res, result);
    } catch (err) {
      console.error('更新位置失败:', err);
      return error(res, err.message, err.code || 'UPDATE_LOCATION_FAILED', err.status || 500);
    }
  }

  /**
   * 查询位置
   * GET /api/locations/:receiverOpenid
   */
  async getLocation(req, res) {
    try {
      const senderOpenid = req.user.openid;
      const receiverOpenid = req.params.receiverOpenid;

      if (process.env.NODE_ENV !== 'production') {
        console.log(`[Locations] 查询位置: sender=${senderOpenid}, receiver=${receiverOpenid}`);
      }

      const result = await this.locationService.getLocation(senderOpenid, receiverOpenid);

      return success(res, result);
    } catch (err) {
      console.error('查询位置失败:', err);
      if (err.code === 'NO_BINDING') {
        return error(res, err.message, 'NO_BINDING', 403);
      }
      if (err.code === 'LOCATION_NOT_FOUND') {
        return notFound(res, '该用户暂无位置信息');
      }
      return error(res, err.message, err.code || 'GET_LOCATION_FAILED', err.status || 500);
    }
  }

  /**
   * 共享开关（兼容旧逻辑）
   * POST /api/locations/sharing/toggle
   */
  async toggleSharing(req, res) {
    try {
      const result = this.locationService.toggleSharing();
      return success(res, result);
    } catch (err) {
      console.error('切换共享失败:', err);
      return error(res, err.message, 'TOGGLE_SHARING_FAILED', 500);
    }
  }
}

module.exports = LocationController;
