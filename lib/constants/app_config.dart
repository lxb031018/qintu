/// ============================================
/// 应用配置常量
///
/// 统一定义应用的配置信息
/// ============================================

class AppConfig {
  // ==================== CloudBase 环境配置 ====================

  /// CloudBase 环境 ID
  static const String envId = 'qintu-cloudebase-5f5bpuj13bc6467';

  /// CloudBase 网关地址
  static const String gatewayUrl = 'https://$envId.api.tcloudbasegateway.com';

  /// CloudBase 服务地址
  static const String serviceUrl = 'https://$envId.service.tcloudbase.com';

  // ==================== 认证配置 ====================

  /// Access Token 有效期（秒）
  static const int accessTokenExpiresIn = 7200; // 2 小时

  /// Refresh Token 有效期（秒）
  static const int refreshTokenExpiresIn = 2592000; // 30 天

  /// 短信验证码有效期（秒）
  static const int verificationCodeExpiresIn = 600; // 10 分钟

  /// 每日短信发送限制
  static const int smsDailyLimit = 5;

  /// 短信发送间隔（秒）
  static const int smsSendInterval = 60;

  // ==================== UI 配置 ====================

  /// 应用名称
  static const String appName = '亲途';

  /// 应用版本
  static const String appVersion = '0.1.0';

  /// 页面内边距
  static const double pagePadding = 32.0;

  /// 卡片内边距
  static const double cardPadding = 24.0;

  /// 按钮高度
  static const double buttonHeight = 60.0;

  /// 输入框高度
  static const double textFieldHeight = 60.0;

  /// 圆角大小
  static const double borderRadius = 16.0;

  /// 图标大小
  static const double iconSize = 28.0;

  /// 大图标大小
  static const double largeIconSize = 64.0;

  // ==================== 字体配置 ====================

  /// 字体家族
  static const String fontFamily = 'PingFang SC';

  /// 标题字体大小
  static const double titleFontSize = 36.0;

  /// 副标题字体大小
  static const double subtitleFontSize = 24.0;

  /// 正文字体大小
  static const double bodyFontSize = 18.0;

  /// 按钮字体大小
  static const double buttonFontSize = 24.0;

  // ==================== 动画配置 ====================

  /// 默认动画时长（毫秒）
  static const int animationDuration = 300;

  /// 启动页延迟（毫秒）
  static const int splashDuration = 800;

  // ==================== 倒计时配置 ====================

  /// 验证码倒计时（秒）
  static const int countdownDuration = 60;

  // ==================== 网络配置 ====================

  /// 网络请求超时（毫秒）
  static const int networkTimeout = 30000; // 30 秒

  /// 重试次数
  static const int maxRetryCount = 3;

  // ==================== 存储键名 ====================

  /// Access Token 存储键
  static const String accessTokenKey = 'access_token';

  /// Refresh Token 存储键
  static const String refreshTokenKey = 'refresh_token';

  /// 用户手机号存储键
  static const String phoneNumberKey = 'phone_number';

  /// 用户角色存储键
  static const String userRoleKey = 'user_role';

  /// Token 保存时间存储键
  static const String saveTimeKey = 'save_time';

  /// Token 过期时间存储键
  static const String expiresInKey = 'expires_in';
}