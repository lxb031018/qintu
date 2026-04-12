// 认证配置
// 负责管理 Token 有效期、验证码等认证相关配置

class AuthConfig {
  // ==================== 基础配置 ====================

  /// Access Token 有效期（秒）- 基础配置
  static const int accessTokenExpiresIn = 7200; // 2 小时

  /// Refresh Token 有效期（秒）- 基础配置
  static const int refreshTokenExpiresIn = 315360000; // 10年（一次登录，永久保持）

  // ==================== 验证码配置 ====================

  /// 短信验证码有效期（秒）
  static const int verificationCodeExpiresIn = 600; // 10 分钟

  /// 每日短信发送限制
  static const int smsDailyLimit = 5;

  /// 短信发送间隔（秒）
  static const int smsSendInterval = 60;

  /// 验证码倒计时（秒）
  static const int countdownDuration = 60;
}
