/**
 * 位置服务
 *
 * 职责：
 * 1. 位置上报
 * 2. 位置查询（需要绑定关系验证）
 * 3. 被动共享模式逻辑
 */

class LocationService {
  constructor(bindingRepository, locationRepository, userRepository) {
    this.bindingRepo = bindingRepository;
    this.locationRepo = locationRepository;
    this.userRepo = userRepository;
  }

  /**
   * 更新位置（接收者调用）
   * @param {string} openid - 接收者 openid
   * @param {Object} locationData
   * @returns {Object}
   */
  async updateLocation(openid, locationData) {
    const { latitude, longitude, accuracy, speed, bearing, altitude } = locationData;

    // 坐标范围验证
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      throw Object.assign(new Error('经纬度坐标超出有效范围'), { code: 'INVALID_COORDS', status: 400 });
    }

    // 调试模式：获取脱敏手机号用于日志
    let maskedPhone = null;
    if (process.env.NODE_ENV !== 'production') {
      maskedPhone = await this.userRepo.findPhoneByOpenid(openid);
    }

    await this.locationRepo.upsertLocation(openid, {
      latitude,
      longitude,
      accuracy,
      speed,
      bearing,
      altitude
    });

    // 调试模式：输出详细日志
    if (process.env.NODE_ENV !== 'production') {
      const debugInfo = [
        maskedPhone ? `手机: ${maskedPhone}` : '手机: 未知',
        `坐标: lat=${latitude.toFixed(6)}, lng=${longitude.toFixed(6)}`,
        accuracy !== undefined ? `精度: ${accuracy}m` : null,
        speed !== undefined ? `速度: ${speed}m/s` : null,
        bearing !== undefined ? `方向: ${bearing}°` : null,
        altitude !== undefined ? `海拔: ${altitude}m` : null,
      ].filter(Boolean).join(', ');
      console.log(`[Locations] ${debugInfo}`);
    }

    return { message: '位置已更新' };
  }

  /**
   * 查询位置（发送者调用，查询接收者位置）
   * @param {string} senderOpenid - 发送者 openid
   * @param {string} receiverOpenid - 接收者 openid
   * @returns {Object}
   */
  async getLocation(senderOpenid, receiverOpenid) {
    // 验证绑定关系（双向：发送者查接收者，接收者也可以查发送者）
    const binding = await this.bindingRepo.findActiveBetween(senderOpenid, receiverOpenid);

    if (!binding) {
      throw Object.assign(new Error('与该用户没有绑定关系'), { code: 'NO_BINDING', status: 403 });
    }

    // 查询位置
    const location = await this.locationRepo.getLocation(receiverOpenid);

    if (!location) {
      throw Object.assign(new Error('该用户暂无位置信息'), { code: 'LOCATION_NOT_FOUND', status: 404 });
    }

    return {
      receiver_openid: receiverOpenid,
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      speed: location.speed,
      bearing: location.bearing,
      altitude: location.altitude,
      updated_at: location.updatedAt
    };
  }

  /**
   * 共享开关（兼容旧逻辑，被动共享模式恒返回开启）
   * @returns {Object}
   */
  toggleSharing() {
    return {
      message: '位置共享已开启',
      is_sharing: true
    };
  }
}

module.exports = LocationService;
