// ============================================
// 存储键常量
//
// 统一定义应用中使用的所有存储键名
// 避免在代码中硬编码字符串
// ============================================

/// SecureStorage 存储键（敏感信息）
class SecureStorageKeys {
  /// 访问令牌
  static const String accessToken = 'access_token';

  /// 刷新令牌
  static const String refreshToken = 'refresh_token';

  /// 用户 ID
  static const String userId = 'user_id';

  /// 用户角色
  static const String userRole = 'user_role';

  /// 手机号
  static const String phoneNumber = 'phone_number';

  /// 令牌过期时间
  static const String tokenExpiresAt = 'token_expires_at';

  /// 刷新令牌过期时间
  static const String refreshTokenExpiresAt = 'refresh_token_expires_at';

  /// 所有键列表
  static const List<String> all = [
    accessToken,
    refreshToken,
    userId,
    userRole,
    phoneNumber,
    tokenExpiresAt,
    refreshTokenExpiresAt,
  ];
}

/// SharedPreferences 存储键（非敏感配置）
class SharedPreferencesKeys {
  /// OpenID
  static const String openid = 'openid';

  /// 用户类型
  static const String userType = 'user_type';

  /// 是否首次登录
  static const String isFirstLogin = 'is_first_login';

  /// 主题模式（light/dark/system）
  static const String themeMode = 'theme_mode';

  /// 是否开启通知
  static const String notificationsEnabled = 'notifications_enabled';

  /// 是否开启位置共享
  static const String locationSharingEnabled = 'location_sharing_enabled';

  /// 所有键列表
  static const List<String> all = [
    openid,
    userType,
    isFirstLogin,
    themeMode,
    notificationsEnabled,
    locationSharingEnabled,
  ];
}

/// 统一存储键访问入口
class StorageKeys {
  /// SecureStorage 键
  static final secure = SecureStorageKeys();

  /// SharedPreferences 键
  static final shared = SharedPreferencesKeys();
}
