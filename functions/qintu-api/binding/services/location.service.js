/**
 * 位置 Service
 *
 * 内存缓存方案：
 * - 位置数据不持久化到数据库
 * - 用户关闭共享时主动删除
 * - 用户移动超过一定距离后 App 端主动上传新位置
 */

const { error } = require('../../shared/lib/response');

// 内存缓存：userId -> location data
const _locationCache = new Map();

/**
 * 位置服务
 */
class LocationService {
  constructor(bindingRepo) {
    this.bindingRepo = bindingRepo;
  }

  /**
   * 更新用户位置
   * @param {string} userId - 用户 ID
   * @param {number} latitude - 纬度
   * @param {number} longitude - 经度
   * @param {number} accuracy - 精度（米）
   * @param {string|null} address - 地址（可选）
   */
  async updateLocation(userId, latitude, longitude, accuracy, address = null) {
    if (!userId || latitude == null || longitude == null) {
      throw Object.assign(new Error('缺少必要参数'), { code: 'INVALID_PARAM', status: 400 });
    }

    _locationCache.set(userId, {
      latitude,
      longitude,
      accuracy: accuracy || null,
      address: address || null,
      timestamp: Date.now(),
      isSharing: true,  // 默认开启共享
    });

    return { success: true };
  }

  /**
   * 获取绑定者的位置
   * @param {string} myUserID - 当前用户 ID
   * @param {string} partnerUserID - 绑定者用户 ID
   * @returns {Object} { status, location? }
   */
  async getLocation(myUserID, partnerUserID) {
    if (!myUserID || !partnerUserID) {
      throw Object.assign(new Error('缺少用户 ID'), { code: 'INVALID_PARAM', status: 400 });
    }

    // 验证绑定关系是否存在且生效
    const bindings = await this.bindingRepo.findAllForUser(myUserID);
    const binding = bindings.find(
      b => (b.userA === myUserID && b.userB === partnerUserID) ||
           (b.userA === partnerUserID && b.userB === myUserID)
    );

    if (!binding || binding.status !== 'active') {
      throw Object.assign(new Error('绑定关系不存在或已失效'), { code: 'BINDING_NOT_FOUND', status: 404 });
    }

    const locationData = _locationCache.get(partnerUserID);

    // 位置不存在
    if (!locationData) {
      return { status: 'notFound' };
    }

    // 绑定者未开启共享
    if (!locationData.isSharing) {
      return { status: 'notSharing' };
    }

    return {
      status: 'success',
      location: {
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        accuracy: locationData.accuracy,
        timestamp: locationData.timestamp,
        address: locationData.address,
        isSharing: locationData.isSharing,
      },
    };
  }

  /**
   * 切换位置共享状态
   * @param {string} userId - 用户 ID
   * @param {boolean} isSharing - 是否开启共享
   */
  async toggleSharing(userId, isSharing) {
    if (!userId) {
      throw Object.assign(new Error('缺少用户 ID'), { code: 'INVALID_PARAM', status: 400 });
    }

    const locationData = _locationCache.get(userId);
    if (!locationData) {
      throw Object.assign(new Error('暂无位置数据，请先上传位置'), { code: 'LOCATION_NOT_FOUND', status: 404 });
    }

    locationData.isSharing = isSharing;
    _locationCache.set(userId, locationData);

    return { success: true, isSharing };
  }

  /**
   * 删除用户位置
   * @param {string} userId - 用户 ID
   */
  async deleteLocation(userId) {
    if (!userId) {
      throw Object.assign(new Error('缺少用户 ID'), { code: 'INVALID_PARAM', status: 400 });
    }

    _locationCache.delete(userId);
    return { success: true };
  }
}

module.exports = LocationService;