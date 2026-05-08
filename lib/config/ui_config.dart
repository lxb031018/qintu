// UI 配置
// 负责管理 UI 相关的全局配置参数

class UIConfig {
  UIConfig._();

  /// 圆角半径
  static const double borderRadius = 8.0;

  /// 字体家族（null 使用系统默认字体）
  static const String? fontFamily = null;

  /// 按钮高度
  static const double buttonHeight = 48.0;

  /// 图标尺寸
  static const double iconSize = 24.0;

  /// 大图标尺寸
  static const double largeIconSize = 32.0;
}