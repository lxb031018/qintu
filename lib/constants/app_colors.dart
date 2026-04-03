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
  static Color primaryOpacity10 = primaryColor.withOpacity(0.1);
  static Color primaryOpacity15 = primaryColor.withOpacity(0.15);
  static Color primaryOpacity30 = primaryColor.withOpacity(0.3);
  static Color primaryOpacity40 = primaryColor.withOpacity(0.4);

  /// 半透明错误色
  static Color errorOpacity10 = errorColor.withOpacity(0.1);
  static Color errorOpacity30 = errorColor.withOpacity(0.3);

  /// 半透明成功色
  static Color successOpacity10 = successColor.withOpacity(0.1);

  // ==================== 特殊用途颜色 ====================

  /// 分割线颜色
  static const Color dividerColor = Color(0xFFE2E8F0);

  /// 禁用状态颜色
  static const Color disabledColor = Color(0xFFCBD5E0);

  /// 输入框边框颜色
  static const Color borderColor = Color(0xFFE2E8F0);

  /// 输入框焦点边框颜色
  static Color focusBorderColor = primaryColor.withOpacity(0.5);
}