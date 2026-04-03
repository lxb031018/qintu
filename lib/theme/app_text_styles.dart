import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// ============================================
/// 应用文字样式
///
/// 统一定义应用中使用的所有文字样式
/// ============================================

class AppTextStyles {
  // ==================== 基础配置 ====================

  /// 默认字体
  static const String fontFamily = 'PingFang SC';

  /// 圆角大小
  static const double borderRadius = 16.0;
  static const double buttonRadius = 16.0;
  static const double cardRadius = 16.0;
  static const double textFieldRadius = 16.0;

  /// 图标大小
  static const double iconSize = 28.0;
  static const double largeIconSize = 64.0;

  // ==================== 标题样式 ====================

  /// 超大标题（欢迎页）
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.2,
  );

  /// 大标题
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.3,
  );

  /// 标题
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    height: 1.4,
  );

  // ==================== 正文样式 ====================

  /// 大正文
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.5,
  );

  /// 正文
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.5,
  );

  /// 小正文
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.5,
  );

  // ==================== 辅助文字样式 ====================

  /// 辅助文字（提示文字）
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.4,
  );

  /// 小提示文字
  static const TextStyle captionSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.4,
  );

  // ==================== 按钮样式 ====================

  /// 按钮文字
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteText,
    height: 1.2,
  );

  /// 小按钮文字
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteText,
    height: 1.2,
  );

  // ==================== 输入框样式 ====================

  /// 输入框文字
  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
    height: 1.2,
  );

  /// 输入框提示文字
  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextColor,
    height: 1.2,
  );

  /// 输入框标签
  static const TextStyle inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryColor,
    height: 1.2,
  );

  // ==================== 特殊样式 ====================

  /// AppBar 标题
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteText,
    height: 1.2,
  );

  /// 错误提示
  static const TextStyle error = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.errorColor,
    height: 1.4,
  );

  /// 成功提示
  static const TextStyle success = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.successColor,
    height: 1.4,
  );

  /// 数字（验证码输入）
  static const TextStyle number = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    letterSpacing: 8,
    height: 1.0,
  );

  // ==================== TextTheme 配置 ====================

  /// Material TextTheme
  static const TextTheme textTheme = TextTheme(
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