/**
 * 认证服务
 *
 * 职责：
 * 1. 管理验证码（mockCodes）
 * 2. 管理用户映射（userRepo）
 * 3. 生成 token
 */

const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');
const config = require('../../config');
const { normalizePhone, isValidChinesePhone } = require('../../shared/lib/phone');

class AuthService {
  constructor(userRepository) {
    this.userRepo = userRepository;
    // 验证码存储：verification_id -> { code, phone, expiresAt }
    this.mockCodes = new Map();
  }

  /**
   * 从 accessToken 反推 userId
   */
  _extractUserIDFromToken(accessToken) {
    if (!accessToken || !accessToken.includes(config.PREFIX.USERID)) {
      return null;
    }
    const parts = accessToken.split(config.PREFIX.USERID);
    if (parts.length < 2) return null;
    return config.PREFIX.USERID + parts[1].split(/[\s"]/)[0];
  }

  /**
   * 校验 accessToken 是否属于指定 userId 的有效会话
   */
  async isTokenValidForSession(userId, accessToken) {
    try {
      // 从数据库查询用户
      const user = await this.userRepo.findByUserID(userId);
      if (!user) return false;

      // 检查 access_token 是否匹配
      if (user.access_token !== accessToken) return false;

      // 检查是否过期
      if (user.token_expires_at && new Date(user.token_expires_at) < new Date()) {
        return false;
      }

      return true;
    } catch (e) {
      console.error('[Auth] 会话验证失败:', e);
      return false;
    }
  }

  /**
   * 清除用户所有旧会话（同一手机号新设备登录时调用）
   */
  async _revokeAllSessionsForUser(userId) {
    await this.userRepo.clearSession(userId);
  }

  /**
   * 注册或更新会话（绑定 deviceId -> Token 映射）
   */
  async _upsertSession(userId, deviceId, accessToken, refreshToken) {
    const expiresAt = new Date(Date.now() + config.SESSION.EXPIRES_S * 1000).toISOString().replace('T', ' ').slice(0, 19);
    await this.userRepo.upsertSession(userId, accessToken, refreshToken, expiresAt, deviceId);
  }

  /**
   * 发送验证码
   * @param {string} phoneNumber - 原始手机号
   * @returns {Object} - { verification_id, code }
   */
  async sendVerificationCode(phoneNumber) {
    const phone = normalizePhone(phoneNumber);

    if (!isValidChinesePhone(phone)) {
      throw Object.assign(new Error('手机号格式不正确（应为 11 位中国手机号）'), { code: 'INVALID_PHONE', status: 400 });
    }

    // 生成6位验证码
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const verificationId = config.PREFIX.MOCK_CODE_VID + Date.now();

    this.mockCodes.set(verificationId, {
      code,
      phone,
      expiresAt: Date.now() + config.AUTH.CODE_EXPIRES_MS
    });

    return { verification_id: verificationId, code };
  }

  /**
   * 验证验证码
   * @param {string} verificationId
   * @param {string} verificationCode
   * @returns {Object} - { userId, access_token, refresh_token, verification_token }
   */
  async verifyCode(verificationId, verificationCode) {
    const data = this.mockCodes.get(verificationId);

    if (!data) {
      throw Object.assign(new Error('验证码不存在或已过期'), { code: 'VERIFICATION_NOT_FOUND', status: 400 });
    }

    if (Date.now() > data.expiresAt) {
      this.mockCodes.delete(verificationId);
      throw Object.assign(new Error('验证码已过期，请重新获取'), { code: 'VERIFICATION_EXPIRED', status: 400 });
    }

    if (data.code !== verificationCode) {
      throw Object.assign(new Error('验证码错误'), { code: 'VERIFICATION_CODE_MISMATCH', status: 400 });
    }

    // 验证成功，删除验证码
    this.mockCodes.delete(verificationId);

    // 检查手机号是否已有用户，有则复用，无则创建
    let userId = await this.userRepo.findUserIDByPhone(data.phone);
    if (!userId) {
      userId = config.PREFIX.USERID + uuidv4().replace(/-/g, '');
      await this.userRepo.registerByPhone(data.phone, userId);
    }

    // 生成 token（不带 deviceId，因为是首次登录，还没有 deviceId）
    const accessToken = config.PREFIX.ACCESS_TOKEN + userId;
    const refreshToken = config.PREFIX.REFRESH_TOKEN + userId;
    const verificationToken = config.PREFIX.V_TOKEN + userId;

    return {
      userId,
      access_token: accessToken,
      refresh_token: refreshToken,
      verification_token: verificationToken
    };
  }

  /**
   * 登录（通过 verification_token）
   * @param {string} verificationToken
   * @param {string} deviceId - 设备唯一标识，用于多设备互斥
   * @returns {Object} - { userId, access_token, refresh_token, user_type }
   */
  async signin(verificationToken, deviceId) {
    const userId = verificationToken
      ? verificationToken.replace(config.PREFIX.V_TOKEN, '')
      : 'mock_user';

    // 新设备登录时，废弃旧会话，实现互斥登录
    if (deviceId) {
      await this._revokeAllSessionsForUser(userId);
    }

    const accessToken = config.PREFIX.ACCESS_TOKEN + userId + '_' + (deviceId || 'default');
    const refreshToken = config.PREFIX.REFRESH_TOKEN + userId + '_' + (deviceId || 'default');

    if (deviceId) {
      await this._upsertSession(userId, deviceId, accessToken, refreshToken);
    }

    return {
      userId,
      access_token: accessToken,
      refresh_token: refreshToken,
      user_type: 'sender'
    };
  }

  /**
   * 注册
   * @param {string} verificationToken
   * @param {string} phoneNumber
   * @param {string} deviceId - 设备唯一标识，用于多设备互斥
   * @returns {Object}
   */
  async signup(verificationToken, phoneNumber, deviceId) {
    const userId = verificationToken
      ? verificationToken.replace(config.PREFIX.V_TOKEN, '')
      : 'mock_user';

    if (deviceId) {
      await this._revokeAllSessionsForUser(userId);
    }

    const accessToken = config.PREFIX.ACCESS_TOKEN + userId + '_' + (deviceId || 'default');
    const refreshToken = config.PREFIX.REFRESH_TOKEN + userId + '_' + (deviceId || 'default');

    if (deviceId) {
      await this._upsertSession(userId, deviceId, accessToken, refreshToken);
    }

    return {
      userId,
      access_token: accessToken,
      refresh_token: refreshToken,
      user_type: 'sender'
    };
  }

  /**
   * 登出
   * @param {string} userId
   * @param {string} deviceId
   */
  async signout(userId, deviceId) {
    await this.userRepo.clearSession(userId);
  }

  /**
   * 刷新 token
   * @param {string} refreshToken
   * @returns {Object}
   */
  async refreshToken(refreshToken) {
    let userId = 'unknown_user';
    let deviceId = null;

    if (refreshToken && refreshToken.includes(config.PREFIX.USERID)) {
      const parts = refreshToken.split(config.PREFIX.USERID);
      if (parts.length > 1) {
        const userIdPart = parts[1].split(/[\s"_]/)[0];
        userId = config.PREFIX.USERID + userIdPart;
        deviceId = parts[1].split(/[\s"_]/)[1] || null;
      }
    }

    const accessToken = config.PREFIX.ACCESS_TOKEN + userId + (deviceId ? '_' + deviceId : '');
    const refreshTokenNew = config.PREFIX.REFRESH_TOKEN + userId + (deviceId ? '_' + deviceId : '');

    if (userId && deviceId) {
      await this._upsertSession(userId, deviceId, accessToken, refreshTokenNew);
    }

    return {
      userId,
      access_token: accessToken,
      refresh_token: refreshTokenNew,
      expires_in: config.AUTH.TOKEN_EXPIRES_S,
      user_type: 'sender',
      token_type: 'Bearer'
    };
  }
}

module.exports = AuthService;
