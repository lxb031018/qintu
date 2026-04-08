import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../constants/app_colors.dart';

/// 应用文字样式 - 统一定义应用中使用的所有文字样式

class AppTextStyles {
  /// 字体大小乘数（默认 1.0）
  static double _fontSizeScale = 1.0;

  /// 设置字体大小乘数
  static void setFontSizeScale(double scale) {
    _fontSizeScale = scale;
  }

  /// 获取当前字体大小乘数
  static double get fontSizeScale => _fontSizeScale;

  // ==================== 尺寸配置（统一引用 AppConfig）====================

  /// 圆角大小
  static double get borderRadius => AppConfig.borderRadius;
  static double get buttonRadius => AppConfig.borderRadius;
  static double get cardRadius => AppConfig.borderRadius;
  static double get textFieldRadius => AppConfig.borderRadius;

  /// 图标大小
  static double get iconSize => AppConfig.iconSize;
  static double get largeIconSize => AppConfig.largeIconSize;

  // ==================== 标题样式 ====================

  /// 超大标题（欢迎页）
  static TextStyle get titleLarge => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 40 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.2,
  );

  /// 大标题
  static TextStyle get titleMedium => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 32 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.3,
  );

  /// 标题
  static TextStyle get titleSmall => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 24 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.4,
  );

  // ==================== 正文样式 ====================

  /// 大正文
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 24 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.5,
  );

  /// 正文
  static TextStyle get bodyMedium => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 20 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.5,
  );

  /// 小正文
  static TextStyle get bodySmall => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.5,
  );

  // ==================== 辅助文字样式 ====================

  /// 辅助文字（提示文字）
  static TextStyle get caption => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 16 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.4,
  );

  /// 小提示文字
  static TextStyle get captionSmall => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 14 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.4,
  );

  // ==================== 按钮样式 ====================

  /// 按钮文字
  static TextStyle get button => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 24 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteText,
    height: 1.2,
  );

  /// 小按钮文字
  static TextStyle get buttonSmall => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteText,
    height: 1.2,
  );

  // ==================== 输入框样式 ====================

  /// 输入框文字
  static TextStyle get input => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 24 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.2,
  );

  /// 输入框提示文字
  static TextStyle get inputHint => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.2,
  );

  /// 输入框标签
  static TextStyle get inputLabel => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 20 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryColor,
    height: 1.2,
  );

  // ==================== 特殊样式 ====================

  /// AppBar 标题
  static TextStyle get appBarTitle => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 20 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteText,
    height: 1.2,
  );

  /// 启动页 Logo 文字
  static TextStyle get splashLogo => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 36 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.2,
  );

  /// 启动页副标题
  static TextStyle get splashSubtitle => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 16 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.4,
  );

  /// 角色图标（Emoji）
  static TextStyle get roleIcon => TextStyle(
    fontSize: 40 * _fontSizeScale,
  );

  /// 角色卡片图标
  static TextStyle get roleCardIcon => TextStyle(
    fontSize: 32 * _fontSizeScale,
  );

  /// 角色名称
  static TextStyle get roleName => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.4,
  );

  /// 对话框标题
  static TextStyle get dialogTitle => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 24 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.3,
  );

  /// 对话框内容
  static TextStyle get dialogContent => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.4,
  );

  /// 对话框按钮
  static TextStyle get dialogButton => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
    height: 1.2,
  );

  /// 对话框确认按钮（强调色）
  static TextStyle get dialogConfirmButton => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.errorColor,
    height: 1.2,
  );

  /// 错误详情（等宽字体）
  static TextStyle get errorDetail => TextStyle(
    fontFamily: 'monospace',
    fontSize: 12 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.4,
  );

  /// 统计数值
  static TextStyle get statValue => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 16 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.2,
  );

  /// 统计标签
  static TextStyle get statLabel => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 12 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.4,
  );

  /// 统计单位
  static TextStyle get statUnit => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 10 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.4,
  );

  /// 状态标签（小标签）
  static TextStyle get statusTag => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 12 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  /// 位置信息标题
  static TextStyle get locationTitle => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 14 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.3,
  );

  /// 位置信息详情
  static TextStyle get locationDetail => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 12 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.4,
  );

  /// 底部标签（Tab 等）
  static TextStyle get bottomTab => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 10 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  /// Emoji 图标（通用）
  static TextStyle get emojiIcon => TextStyle(
    fontSize: 28 * _fontSizeScale,
  );

  /// 大 Emoji 图标
  static TextStyle get emojiLarge => TextStyle(
    fontSize: 32 * _fontSizeScale,
  );

  /// 错误提示
  static TextStyle get error => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.errorColor,
    height: 1.4,
  );

  /// 成功提示
  static TextStyle get success => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18 * _fontSizeScale,
    fontWeight: FontWeight.normal,
    color: AppColors.successColor,
    height: 1.4,
  );

  /// 数字（验证码输入）
  static TextStyle get number => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 32 * _fontSizeScale,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    letterSpacing: 8,
    height: 1.0,
  );

  // ==================== TextTheme 配置 ====================

  /// Material TextTheme
  static TextTheme get textTheme => TextTheme(
    displayLarge: titleLarge,
    displayMedium: titleMedium,
    displaySmall: titleSmall,
    headlineLarge: titleLarge,
    headlineMedium: titleMedium,
    headlineSmall: titleSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: button,
    labelMedium: buttonSmall,
    labelSmall: captionSmall,
  );
}