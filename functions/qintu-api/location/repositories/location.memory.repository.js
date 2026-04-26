/**
 * 位置内存 Repository
 *
 * 管理用户实时位置数据（userLocations）
 */

class LocationMemoryRepository {
  constructor() {
    // openid -> locationData
    this.locations = new Map();
    // openid -> 'enabled' | 'disabled'（定位开关状态）
    this.locationStatusMap = new Map();
  }

  /**
   * 更新用户位置
   * @param {string} openid
   * @param {Object} locationData
   * @returns {Object}
   */
  async upsertLocation(openid, locationData) {
    const data = {
      latitude: locationData.latitude,
      longitude: locationData.longitude,
      accuracy: locationData.accuracy || null,
      speed: locationData.speed || null,
      bearing: locationData.bearing || null,
      altitude: locationData.altitude || null,
      updatedAt: new Date().toISOString()
    };
    this.locations.set(openid, data);
    return data;
  }

  /**
   * 获取用户位置
   * @param {string} openid
   * @returns {Object|null}
   */
  async getLocation(openid) {
    return this.locations.get(openid) || null;
  }

  /**
   * 删除用户位置
   * @param {string} openid
   * @returns {boolean}
   */
  async deleteLocation(openid) {
    this.locationStatusMap.delete(openid);
    return this.locations.delete(openid);
  }

  /**
   * 设置用户定位状态
   * @param {string} openid
   * @param {string} status - 'enabled' | 'disabled'
   */
  setLocationStatus(openid, status) {
    this.locationStatusMap.set(openid, status);
  }

  /**
   * 获取用户定位状态
   * @param {string} openid
   * @returns {boolean} - true: enabled, false: disabled/null
   */
  isLocationEnabled(openid) {
    return this.locationStatusMap.get(openid) === 'enabled';
  }

  /**
   * 获取所有位置
   * @returns {Map}
   */
  getAllLocations() {
    return this.locations;
  }
}

module.exports = LocationMemoryRepository;
