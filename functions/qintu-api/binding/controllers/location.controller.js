/**
 * 位置 Controller
 */

const { success, error } = require('../../shared/lib/response');

class LocationController {
  constructor(locationService) {
    this.locationService = locationService;
  }

  /**
   * 更新位置
   * POST /api/locations/update
   * Body: { latitude, longitude, accuracy?, address? }
   */
  async updateLocation(req, res) {
    try {
      const user_ID = req.user?.user_ID;
      if (!user_ID || user_ID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const { latitude, longitude, accuracy, address } = req.body;

      if (latitude == null || longitude == null) {
        return error(res, '缺少经纬度信息', 'INVALID_PARAM', 400);
      }

      await this.locationService.updateLocation(
        user_ID,
        parseFloat(latitude),
        parseFloat(longitude),
        accuracy ? parseInt(accuracy) : null,
        address || null
      );

      return success(res, { message: '位置更新成功' });
    } catch (err) {
      console.error('[Location] 更新位置失败:', err);
      return error(res, err.message, err.code || 'UPDATE_FAILED', err.status || 500);
    }
  }

  /**
   * 获取绑定者位置
   * GET /api/locations/:partnerUserID
   */
  async getLocation(req, res) {
    try {
      const myUserID = req.user?.user_ID;
      if (!myUserID || myUserID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const partnerUserID = req.params.receiverUserID || req.params.partnerUserID;
      if (!partnerUserID) {
        return error(res, '缺少绑定者用户 ID', 'INVALID_PARAM', 400);
      }

      const result = await this.locationService.getLocation(myUserID, partnerUserID);

      if (result.status === 'notFound') {
        return success(res, {
          isSharing: false,
          message: '未找到绑定者位置',
        });
      }

      if (result.status === 'notSharing') {
        return success(res, {
          isSharing: false,
          message: '绑定者未开启位置共享',
        });
      }

      return success(res, result.location);
    } catch (err) {
      console.error('[Location] 获取绑定者位置失败:', err);
      return error(res, err.message, err.code || 'GET_LOCATION_FAILED', err.status || 500);
    }
  }

  /**
   * 切换共享状态
   * POST /api/locations/sharing/toggle
   * Body: { isSharing: boolean }
   */
  async toggleSharing(req, res) {
    try {
      const user_ID = req.user?.user_ID;
      if (!user_ID || user_ID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const { isSharing } = req.body;
      if (typeof isSharing !== 'boolean') {
        return error(res, 'isSharing 参数必须是布尔值', 'INVALID_PARAM', 400);
      }

      const result = await this.locationService.toggleSharing(user_ID, isSharing);
      return success(res, result);
    } catch (err) {
      console.error('[Location] 切换共享状态失败:', err);
      return error(res, err.message, err.code || 'TOGGLE_SHARING_FAILED', err.status || 500);
    }
  }

  /**
   * 删除位置
   * DELETE /api/locations/
   */
  async deleteLocation(req, res) {
    try {
      const user_ID = req.user?.user_ID;
      if (!user_ID || user_ID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      await this.locationService.deleteLocation(user_ID);
      return success(res, { message: '位置删除成功' });
    } catch (err) {
      console.error('[Location] 删除位置失败:', err);
      return error(res, err.message, err.code || 'DELETE_FAILED', err.status || 500);
    }
  }
}

module.exports = LocationController;