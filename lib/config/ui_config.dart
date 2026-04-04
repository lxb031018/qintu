/// UI 配置
/// 负责管理界面相关的视觉配置

class UIConfig {
  // ==================== 应用信息 ====================

  /// 应用名称
  static const String appName = '亲途';

  /// 应用版本
  static const String appVersion = '0.1.0';

  // ==================== 布局配置 ====================

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

  // ==================== 网络配置 ====================

  /// 网络请求超时（毫秒）
  static const int networkTimeout = 30000; // 30 秒

  /// 重试次数
  static const int maxRetryCount = 3;
}
