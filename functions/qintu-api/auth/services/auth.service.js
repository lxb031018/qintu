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
   * @returns {Object} - { openid, access_token, refresh_token, user_type }
   */
  async signin(verificationToken) {
    const openid = verificationToken
      ? verificationToken.replace(config.PREFIX.V_TOKEN, '')
      : 'mock_user';

    const accessToken = config.PREFIX.ACCESS_TOKEN + openid;
    const refreshToken = config.PREFIX.REFRESH_TOKEN + openid;

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
   * @returns {Object}
   */
  async signup(verificationToken, phoneNumber) {
    const openid = verificationToken
      ? verificationToken.replace(config.PREFIX.V_TOKEN, '')
      : 'mock_user';

    const accessToken = config.PREFIX.ACCESS_TOKEN + openid;
    const refreshToken = config.PREFIX.REFRESH_TOKEN + openid;

    return {
      openid,
      access_token: accessToken,
      refresh_token: refreshToken,
      user_type: 'sender'
    };
  }

  /**
   * 刷新 token
   * @param {string} refreshToken
   * @returns {Object}
   */
  async refreshToken(refreshToken) {
    let openid = 'unknown_user';
    if (refreshToken && refreshToken.includes(config.PREFIX.OPENID)) {
      openid = config.PREFIX.OPENID + refreshToken.split(config.PREFIX.OPENID)[1];
    }

    return {
      openid,
      access_token: config.PREFIX.ACCESS_TOKEN + openid,
      refresh_token: config.PREFIX.REFRESH_TOKEN + openid,
      expires_in: config.AUTH.TOKEN_EXPIRES_S,
      user_type: 'sender',
      token_type: 'Bearer'
    };
  }
}

module.exports = AuthService;
