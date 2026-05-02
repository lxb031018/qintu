/**
 * 认证控制器
 */

const { success, error } = require('../../shared/lib/response');

class AuthController {
  constructor(authService) {
    this.authService = authService;
  }

  /**
   * 发送验证码
   * POST /mock/auth/auth/v1/verification
   */
  async sendVerification(req, res) {
    try {
      const { phone_number } = req.body;

      if (!phone_number) {
        return res.status(400).json({ code: 400, message: 'Missing phone_number' });
      }

      const result = await this.authService.sendVerificationCode(phone_number);

      // 开发环境打印验证码
      if (process.env.NODE_ENV !== 'production') {
        console.log(`[Mock Auth] 📱 发送验证码: ${result.code}`);
      }

      return res.json({ code: 0, message: 'OK', verification_id: result.verification_id });
    } catch (err) {
      console.error('[Mock Auth] 发送验证码失败:', err);
      return res.status(err.status || 500).json({ code: err.status || 500, message: err.message });
    }
  }

  /**
   * 验证验证码
   * POST /mock/auth/auth/v1/verification/verify
   */
  async verifyCode(req, res) {
    try {
      const { verification_id, verification_code } = req.body;

      if (!verification_id || !verification_code) {
        return res.status(400).json({ code: 400, message: 'Missing parameters' });
      }

      const result = await this.authService.verifyCode(verification_id, verification_code);

      return res.json({
        code: 0,
        access_token: result.access_token,
        openid: result.openid,
        verification_token: result.verification_token
      });
    } catch (err) {
      console.error('[Mock Auth] 验证验证码失败:', err);
      const codeMap = {
        'VERIFICATION_NOT_FOUND': 40003,
        'VERIFICATION_EXPIRED': 40004,
        'VERIFICATION_CODE_MISMATCH': 40002
      };
      return res.status(err.status || 500).json({ code: codeMap[err.code] || 500, message: err.message });
    }
  }

  /**
   * 登录
   * POST /mock/auth/auth/v1/signin
   */
  async signin(req, res) {
    try {
      const { verification_token, device_id } = req.body;

      const result = await this.authService.signin(verification_token, device_id);

      return res.json({
        code: 0,
        access_token: result.access_token,
        refresh_token: result.refresh_token,
        openid: result.openid,
        user_type: result.user_type
      });
    } catch (err) {
      console.error('[Mock Auth] 登录失败:', err);
      return res.status(500).json({ code: 500, message: 'Server Error' });
    }
  }

  /**
   * 注册
   * POST /mock/auth/auth/v1/signup
   */
  async signup(req, res) {
    try {
      const { verification_token, phone_number, device_id } = req.body;

      const result = await this.authService.signup(verification_token, phone_number, device_id);

      return res.json({
        code: 0,
        access_token: result.access_token,
        refresh_token: result.refresh_token,
        openid: result.openid,
        user_type: result.user_type
      });
    } catch (err) {
      console.error('[Mock Auth] 注册失败:', err);
      return res.status(500).json({ code: 500, message: 'Server Error' });
    }
  }

  /**
   * 登出
   * POST /api/auth/sign-out
   */
  async signout(req, res) {
    try {
      const { device_id } = req.body;
      const openid = req.user && req.user.openid;

      if (!openid) {
        return res.status(401).json({ code: 401, message: 'Unauthorized' });
      }

      await this.authService.signout(openid, device_id);

      return res.json({ code: 0, message: 'OK' });
    } catch (err) {
      console.error('[Mock Auth] 登出失败:', err);
      return res.status(500).json({ code: 500, message: 'Server Error' });
    }
  }

  /**
   * 刷新 Token
   * POST /mock/auth/api/auth/refresh-token
   */
  async refreshToken(req, res) {
    try {
      const { refresh_token } = req.body;

      const result = await this.authService.refreshToken(refresh_token);

      return res.json({
        code: 0,
        message: '操作成功',
        access_token: result.access_token,
        refresh_token: result.refresh_token,
        expires_in: result.expires_in,
        openid: result.openid,
        user_type: result.user_type,
        token_type: result.token_type
      });
    } catch (err) {
      console.error('[Mock Auth] 刷新 Token 失败:', err);
      return res.status(500).json({ code: 500, message: 'Server Error' });
    }
  }
}

module.exports = AuthController;
