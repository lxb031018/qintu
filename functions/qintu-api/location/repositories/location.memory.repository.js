/**
 * 位置内存 Repository
 *
 * 管理用户实时位置数据（userLocations）
 */

class LocationMemoryRepository {
  constructor() {
    // user_ID -> locationData
    this.locations = new Map();
    // user_ID -> 'enabled' | 'disabled'（定位开关状态）
    this.locationStatusMap = new Map();
  }

  /**
   * 更新用户位置
   * @param {string} user_ID
   * @param {Object} locationData
   * @returns {Object}
   */
  async upsertLocation(user_ID, locationData) {
    const data = {
      latitude: locationData.latitude,
      longitude: locationData.longitude,
      accuracy: locationData.accuracy || null,
      speed: locationData.speed || null,
      bearing: locationData.bearing || null,
      altitude: locationData.altitude || null,
      updatedAt: new Date().toISOString()
    };
    this.locations.set(user_ID, data);
    return data;
  }

  /**
   * 获取用户位置
   * @param {string} user_ID
   * @returns {Object|null}
   */
  async getLocation(user_ID) {
    return this.locations.get(user_ID) || null;
  }

  /**
   * 删除用户位置
   * @param {string} user_ID
   * @returns {boolean}
   */
  async deleteLocation(user_ID) {
    this.locationStatusMap.delete(user_ID);
    return this.locations.delete(user_ID);
  }

  /**
   * 设置用户定位状态
   * @param {string} user_ID
   * @param {string} status - 'enabled' | 'disabled'
   */
  setLocationStatus(user_ID, status) {
    this.locationStatusMap.set(user_ID, status);
  }

  /**
   * 获取用户定位状态
   * @param {string} user_ID
   * @returns {boolean} - true: enabled, false: disabled/null
   */
  isLocationEnabled(user_ID) {
    return this.locationStatusMap.get(user_ID) === 'enabled';
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
