import 'cloudbase_config.dart';
import 'auth_config.dart';
import 'ui_config.dart';

/// 应用配置常量 - 统一定义应用的配置信息
///
/// 注意：此类现在作为向后兼容的聚合类
/// 新代码应该直接使用专用的配置类：
/// - [CloudBaseConfig] - CloudBase 环境配置
/// - [AuthConfig] - 认证相关配置
/// - [UIConfig] - UI 相关配置

class AppConfig {
  // ==================== CloudBase 环境配置 ====================

  /// CloudBase 环境 ID
  static String get envId => CloudBaseConfig.envId;

  /// CloudBase 网关地址
  static String get gatewayUrl => CloudBaseConfig.gatewayUrl;

  /// CloudBase 服务地址
  static String get serviceUrl => CloudBaseConfig.serviceUrl;

  /// CloudBase API 基础 URL（用于认证等 API 调用）
  static String get cloudBaseApiUrl => '${CloudBaseConfig.serviceUrl}/auth';

  /// 认证 API 基础地址（向后兼容）
  static String get authBaseUrl => CloudBaseConfig.authBaseUrl;

  /// Publishable Key（从环境变量读取）
  static String get publishableKey => CloudBaseConfig.publishableKey;

  // ==================== 认证配置 ====================

  /// Access Token 有效期（秒）
  static int get accessTokenExpiresIn => AuthConfig.accessTokenExpiresIn;

  /// Refresh Token 有效期（秒）
  static int get refreshTokenExpiresIn => AuthConfig.refreshTokenExpiresIn;

  /// 接收者端 Access Token 有效期
  static int get receiverAccessTokenExpiresIn => AuthConfig.receiverAccessTokenExpiresIn;

  /// 接收者端 Refresh Token 有效期
  static int get receiverRefreshTokenExpiresIn => AuthConfig.receiverRefreshTokenExpiresIn;

  /// 发送者端 Access Token 有效期
  static int get senderAccessTokenExpiresIn => AuthConfig.senderAccessTokenExpiresIn;

  /// 发送者端 Refresh Token 有效期
  static int get senderRefreshTokenExpiresIn => AuthConfig.senderRefreshTokenExpiresIn;

  /// 根据角色获取 Access Token 有效期
  static int getAccessTokenExpiresIn(String? role) => AuthConfig.getAccessTokenExpiresIn(role);

  /// 根据角色获取 Refresh Token 有效期
  static int getRefreshTokenExpiresIn(String? role) => AuthConfig.getRefreshTokenExpiresIn(role);

  /// 短信验证码有效期（秒）
  static int get verificationCodeExpiresIn => AuthConfig.verificationCodeExpiresIn;

  /// 每日短信发送限制
  static int get smsDailyLimit => AuthConfig.smsDailyLimit;

  /// 短信发送间隔（秒）
  static int get smsSendInterval => AuthConfig.smsSendInterval;

  /// 验证码倒计时（秒）
  static int get countdownDuration => AuthConfig.countdownDuration;

  // ==================== UI 配置 ====================

  /// 应用名称
  static String get appName => UIConfig.appName;

  /// 应用版本
  static String get appVersion => UIConfig.appVersion;

  /// 页面内边距
  static double get pagePadding => UIConfig.pagePadding;

  /// 卡片内边距
  static double get cardPadding => UIConfig.cardPadding;

  /// 按钮高度
  static double get buttonHeight => UIConfig.buttonHeight;

  /// 输入框高度
  static double get textFieldHeight => UIConfig.textFieldHeight;

  /// 圆角大小
  static double get borderRadius => UIConfig.borderRadius;

  /// 图标大小
  static double get iconSize => UIConfig.iconSize;

  /// 大图标大小
  static double get largeIconSize => UIConfig.largeIconSize;

  /// 字体家族
  static String get fontFamily => UIConfig.fontFamily;

  /// 标题字体大小
  static double get titleFontSize => UIConfig.titleFontSize;

  /// 副标题字体大小
  static double get subtitleFontSize => UIConfig.subtitleFontSize;

  /// 正文字体大小
  static double get bodyFontSize => UIConfig.bodyFontSize;

  /// 按钮字体大小
  static double get buttonFontSize => UIConfig.buttonFontSize;

  /// 默认动画时长（毫秒）
  static int get animationDuration => UIConfig.animationDuration;

  /// 启动页延迟（毫秒）
  static int get splashDuration => UIConfig.splashDuration;

  /// 网络请求超时（毫秒）
  static int get networkTimeout => UIConfig.networkTimeout;

  /// 重试次数
  static int get maxRetryCount => UIConfig.maxRetryCount;

  // ==================== 存储键名 ====================

  static String get accessTokenKey => AuthConfig.accessTokenKey;
  static String get refreshTokenKey => AuthConfig.refreshTokenKey;
  static String get accessTokenSaveTimeKey => AuthConfig.accessTokenSaveTimeKey;
  static String get refreshTokenSaveTimeKey => AuthConfig.refreshTokenSaveTimeKey;
  static String get phoneNumberKey => AuthConfig.phoneNumberKey;
  static String get userRoleKey => AuthConfig.userRoleKey;
  static String get expiresInKey => AuthConfig.expiresInKey;
  static String get userIdKey => AuthConfig.userIdKey;
}