import 'package:flutter/material.dart';

/// ============================================
/// 应用颜色常量
///
/// 统一定义应用中使用的所有颜色
/// 便于维护和修改
/// ============================================

class AppColors {
  // ==================== 主题色 ====================

  /// 珊瑚橙（主色调）
  static const Color primaryColor = Color(0xFFFF8C69);

  /// 品牌绿（辅助主色调，用于 Logo、图标等）
  static const Color brandGreen = Color(0xFF4CAF50);

  /// 天空蓝（辅助色）
  static const Color secondaryColor = Color(0xFF87CEEB);

  /// 浅珊瑚橙（渐变色）
  static const Color primaryLight = Color(0xFFFF9F7F);

  /// 深珊瑚橙
  static const Color primaryDark = Color(0xFFFF7B5F);

  // ==================== 背景色 ====================

  /// 奶油白（背景色）
  static const Color backgroundColor = Color(0xFFFFF8F0);

  /// 纯白（卡片背景）
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ==================== 文字颜色 ====================

  /// 深灰蓝（主文字）
  static const Color textColor = Color(0xFF4A5568);

  /// 浅灰（辅助文字）
  static const Color lightTextColor = Color(0xFF718096);

  /// 白色文字
  static const Color whiteText = Color(0xFFFFFFFF);

  // ==================== 状态颜色 ====================

  /// 成功绿色
  static const Color successColor = Color(0xFF48BB78);

  /// 错误红色
  static const Color errorColor = Color(0xFFE53E3E);

  /// 警告橙色
  static const Color warningColor = Color(0xFFED8936);

  /// 信息蓝色
  static const Color infoColor = Color(0xFF4299E1);

  // ==================== 透明度颜色 ====================

  /// 半透明白色（用于遮罩）
  static const Color whiteOpacity10 = Color(0x1AFFFFFF);

  /// 半透明黑色（用于遮罩）
  static const Color blackOpacity10 = Color(0x1A000000);

  /// 半透明主色
  static Color primaryOpacity10 = primaryColor.withValues(alpha: 0.1);
  static Color primaryOpacity15 = primaryColor.withValues(alpha: 0.15);
  static Color primaryOpacity30 = primaryColor.withValues(alpha: 0.3);
  static Color primaryOpacity40 = primaryColor.withValues(alpha: 0.4);

  /// 半透明错误色
  static Color errorOpacity10 = errorColor.withValues(alpha: 0.1);
  static Color errorOpacity30 = errorColor.withValues(alpha: 0.3);

  /// 半透明成功色
  static Color successOpacity10 = successColor.withValues(alpha: 0.1);

  // ==================== 特殊用途颜色 ====================

  /// 分割线颜色
  static const Color dividerColor = Color(0xFFE2E8F0);

  /// 禁用状态颜色
  static const Color disabledColor = Color(0xFFCBD5E0);

  /// 输入框边框颜色
  static const Color borderColor = Color(0xFFE2E8F0);

  /// 输入框焦点边框颜色
  static Color focusBorderColor = primaryColor.withValues(alpha: 0.5);

  // ==================== 深色主题颜色 ====================

  /// 深色背景（深蓝灰，与珊瑚橙形成良好对比）
  static const Color darkBackgroundColor = Color(0xFF121212);

  /// 深色表面（卡片、对话框等）
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);

  /// 深色卡片背景（稍微亮一些，形成层次感）
  static const Color darkCardBackground = Color(0xFF242424);

  /// 深色主文字（浅灰白，确保对比度）
  static const Color darkTextColor = Color(0xFFE8E8E8);

  /// 深色辅助文字（中等灰度）
  static const Color darkLightTextColor = Color(0xFF9E9E9E);

  /// 深色分割线
  static const Color darkDividerColor = Color(0xFF2C2C2C);

  /// 深色输入框背景
  static const Color darkInputBackground = Color(0xFF2A2A2A);

  /// 深色边框
  static const Color darkBorderColor = Color(0xFF333333);

  /// 深色禁用状态
  static const Color darkDisabledColor = Color(0xFF4A4A4A);

  /// 深色错误提示背景
  static const Color darkErrorBackground = Color(0xFF3D1F1F);

  /// 深色成功提示背景
  static const Color darkSuccessBackground = Color(0xFF1F3D2A);

  /// 深色警告提示背景
  static const Color darkWarningBackground = Color(0xFF3D2F1F);

  /// 深色信息提示背景
  static const Color darkInfoBackground = Color(0xFF1F2D3D);

  /// 深色输入框文字
  static const Color darkInputTextColor = Color(0xFFE0E0E0);

  /// 深色输入框提示文字
  static const Color darkInputHintColor = Color(0xFF757575);

  /// 深色图标（未选中状态）
  static const Color darkIconColor = Color(0xFF9E9E9E);

  /// 深色悬浮图标
  static const Color darkOnPrimaryColor = Color(0xFFFFFFFF);
}