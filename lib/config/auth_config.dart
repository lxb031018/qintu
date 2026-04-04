/// 认证配置
/// 负责管理 Token 有效期、验证码等认证相关配置

class AuthConfig {
  // ==================== 基础配置 ====================

  /// Access Token 有效期（秒）- 基础配置
  static const int accessTokenExpiresIn = 7200; // 2 小时

  /// Refresh Token 有效期（秒）- 基础配置
  static const int refreshTokenExpiresIn = 2592000; // 30 天

  // ==================== 角色专属配置 ====================

  /// 接收者端（老人）Token 有效期配置
  /// 设计理念：一次登录，长期有效，减少老人操作
  static const int receiverAccessTokenExpiresIn = 86400; // 24 小时
  static const int receiverRefreshTokenExpiresIn = 31536000; // 1 年

  /// 发送者端（家属）Token 有效期配置
  /// 设计理念：正常安全级别，定期重新认证
  static const int senderAccessTokenExpiresIn = 7200; // 2 小时
  static const int senderRefreshTokenExpiresIn = 2592000; // 30 天

  /// 根据角色获取 Access Token 有效期
  static int getAccessTokenExpiresIn(String? role) {
    switch (role) {
      case 'receiver':
        return receiverAccessTokenExpiresIn;
      case 'sender':
        return senderAccessTokenExpiresIn;
      default:
        return accessTokenExpiresIn;
    }
  }

  /// 根据角色获取 Refresh Token 有效期
  static int getRefreshTokenExpiresIn(String? role) {
    switch (role) {
      case 'receiver':
        return receiverRefreshTokenExpiresIn;
      case 'sender':
        return senderRefreshTokenExpiresIn;
      default:
        return refreshTokenExpiresIn;
    }
  }

  // ==================== 验证码配置 ====================

  /// 短信验证码有效期（秒）
  static const int verificationCodeExpiresIn = 600; // 10 分钟

  /// 每日短信发送限制
  static const int smsDailyLimit = 5;

  /// 短信发送间隔（秒）
  static const int smsSendInterval = 60;

  /// 验证码倒计时（秒）
  static const int countdownDuration = 60;

  // ==================== 存储键名 ====================

  /// Access Token 存储键
  static const String accessTokenKey = 'access_token';

  /// Refresh Token 存储键
  static const String refreshTokenKey = 'refresh_token';

  /// Access Token 保存时间存储键
  static const String accessTokenSaveTimeKey = 'access_token_save_time';

  /// Refresh Token 保存时间存储键
  static const String refreshTokenSaveTimeKey = 'refresh_token_save_time';

  /// 用户手机号存储键
  static const String phoneNumberKey = 'phone_number';

  /// 用户角色存储键
  static const String userRoleKey = 'user_role';

  /// Token 过期时间存储键
  static const String expiresInKey = 'expires_in';

  /// 用户 ID 存储键
  static const String userIdKey = 'user_id';
}
