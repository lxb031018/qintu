/**
 * 认证服务
 *
 * 职责：
 * 1. 管理验证码（mockCodes）
 * 2. 管理用户电话本映射（userPhoneMap）
 * 3. 生成 token
 */

const crypto = require('crypto');
const config = require('../../config');
const { normalizePhone, isValidChinesePhone } = require('../../shared/lib/phone');

class AuthService {
  constructor(userRepository) {
    this.userRepo = userRepository;
    // 验证码存储：verification_id -> { code, phone, expiresAt }
    this.mockCodes = new Map();
    // 会话存储：openid -> Map<deviceId, { accessToken, refreshToken, expiresAt }>
    this.userSessions = new Map();
  }

  /**
   * 从 accessToken 反推 openid
   */
  _extractOpenidFromToken(accessToken) {
    if (!accessToken || !accessToken.includes(config.PREFIX.OPENID)) {
      return null;
    }
    const parts = accessToken.split(config.PREFIX.OPENID);
    if (parts.length < 2) return null;
    return config.PREFIX.OPENID + parts[1].split(/[\s"]/)[0];
  }

  /**
   * 校验 accessToken 是否属于指定 openid 的有效会话
   */
  isTokenValidForSession(openid, accessToken) {
    if (!this.userSessions.has(openid)) return false;
    const sessions = this.userSessions.get(openid);
    for (const session of sessions.values()) {
      if (session.accessToken === accessToken) {
        if (Date.now() < session.expiresAt) return true;
      }
    }
    return false;
  }

  /**
   * 清除用户所有旧会话（同一手机号新设备登录时调用）
   */
  _revokeAllSessionsForUser(openid) {
    this.userSessions.delete(openid);
  }

  /**
   * 注册或更新会话（绑定 deviceId -> Token 映射）
   */
  _upsertSession(openid, deviceId, accessToken, refreshToken) {
    if (!this.userSessions.has(openid)) {
      this.userSessions.set(openid, new Map());
    }
    const sessions = this.userSessions.get(openid);
    sessions.set(deviceId, {
      accessToken,
      refreshToken,
      expiresAt: Date.now() + config.SESSION.EXPIRES_S * 1000,
    });
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
   * @returns {Object} - { openid, access_token, refresh_token, verification_token }
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

    // 生成 openid
    const openid = config.PREFIX.OPENID + crypto.createHash('md5').update(data.phone).digest('hex').substring(0, 16);

    // 注册用户（存入电话本）
    await this.userRepo.registerByPhone(data.phone, openid);

    // 生成 token
    const accessToken = config.PREFIX.ACCESS_TOKEN + openid;
    const refreshToken = config.PREFIX.REFRESH_TOKEN + openid;
    const verificationToken = config.PREFIX.V_TOKEN + openid;

    return {
      openid,
      access_token: accessToken,
      refresh_token: refreshToken,
      verification_token: verificationToken
    };
  }

  /**
   * 登录（通过 verification_token）
   * @param {string} verificationToken
   * @param {string} deviceId - 设备唯一标识，用于多设备互斥
   * @returns {Object} - { openid, access_token, refresh_token, user_type }
   */
  async signin(verificationToken, deviceId) {
    const openid = verificationToken
      ? verificationToken.replace(config.PREFIX.V_TOKEN, '')
      : 'mock_user';

    // 新设备登录时，废弃旧会话，实现互斥登录
    if (deviceId) {
      this._revokeAllSessionsForUser(openid);
    }

    const accessToken = config.PREFIX.ACCESS_TOKEN + openid + '_' + (deviceId || 'default');
    const refreshToken = config.PREFIX.REFRESH_TOKEN + openid + '_' + (deviceId || 'default');

    if (deviceId) {
      this._upsertSession(openid, deviceId, accessToken, refreshToken);
    }

    return {
      openid,
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
    const openid = verificationToken
      ? verificationToken.replace(config.PREFIX.V_TOKEN, '')
      : 'mock_user';

    if (deviceId) {
      this._revokeAllSessionsForUser(openid);
    }

    const accessToken = config.PREFIX.ACCESS_TOKEN + openid + '_' + (deviceId || 'default');
    const refreshToken = config.PREFIX.REFRESH_TOKEN + openid + '_' + (deviceId || 'default');

    if (deviceId) {
      this._upsertSession(openid, deviceId, accessToken, refreshToken);
    }

    return {
      openid,
      access_token: accessToken,
      refresh_token: refreshToken,
      user_type: 'sender'
    };
  }

  /**
   * 登出
   * @param {string} openid
   * @param {string} deviceId
   */
  async signout(openid, deviceId) {
    if (!this.userSessions.has(openid)) return;
    const sessions = this.userSessions.get(openid);
    sessions.delete(deviceId);
    if (sessions.size === 0) {
      this.userSessions.delete(openid);
    }
  }

  /**
   * 刷新 token
   * @param {string} refreshToken
   * @returns {Object}
   */
  async refreshToken(refreshToken) {
    let openid = 'unknown_user';
    let deviceId = null;

    if (refreshToken && refreshToken.includes(config.PREFIX.OPENID)) {
      const parts = refreshToken.split(config.PREFIX.OPENID);
      if (parts.length > 1) {
        const openidPart = parts[1].split(/[\s"_]/)[0];
        openid = config.PREFIX.OPENID + openidPart;
        deviceId = parts[1].split(/[\s"_]/)[1] || null;
      }
    }

    const accessToken = config.PREFIX.ACCESS_TOKEN + openid + (deviceId ? '_' + deviceId : '');
    const refreshTokenNew = config.PREFIX.REFRESH_TOKEN + openid + (deviceId ? '_' + deviceId : '');

    if (openid && deviceId) {
      this._upsertSession(openid, deviceId, accessToken, refreshTokenNew);
    }

    return {
      openid,
      access_token: accessToken,
      refresh_token: refreshTokenNew,
      expires_in: config.AUTH.TOKEN_EXPIRES_S,
      user_type: 'sender',
      token_type: 'Bearer'
    };
  }
}

module.exports = AuthService;
