import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../constants/app_colors.dart';

/// 应用文字样式 - 统一定义应用中使用的所有文字样式

class AppTextStyles {
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
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.2,
  );

  /// 大标题
  static TextStyle get titleMedium => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.3,
  );

  /// 标题
  static TextStyle get titleSmall => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.4,
  );

  // ==================== 正文样式 ====================

  /// 大正文
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.5,
  );

  /// 正文
  static TextStyle get bodyMedium => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.5,
  );

  /// 小正文
  static TextStyle get bodySmall => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.5,
  );

  // ==================== 辅助文字样式 ====================

  /// 辅助文字（提示文字）
  static TextStyle get caption => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.4,
  );

  /// 小提示文字
  static TextStyle get captionSmall => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.4,
  );

  // ==================== 按钮样式 ====================

  /// 按钮文字
  static TextStyle get button => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteText,
    height: 1.2,
  );

  /// 小按钮文字
  static TextStyle get buttonSmall => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteText,
    height: 1.2,
  );

  // ==================== 输入框样式 ====================

  /// 输入框文字
  static TextStyle get input => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.2,
  );

  /// 输入框提示文字
  static TextStyle get inputHint => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.2,
  );

  /// 输入框标签
  static TextStyle get inputLabel => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryColor,
    height: 1.2,
  );

  // ==================== 特殊样式 ====================

  /// AppBar 标题
  static TextStyle get appBarTitle => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteText,
    height: 1.2,
  );

  /// 错误提示
  static TextStyle get error => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.errorColor,
    height: 1.4,
  );

  /// 成功提示
  static TextStyle get success => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.successColor,
    height: 1.4,
  );

  /// 数字（验证码输入）
  static TextStyle get number => TextStyle(
    fontFamily: AppConfig.fontFamily,
    fontSize: 32,
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