import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// ============================================
/// 主题适配工具类
///
/// 统一封装亮色/暗色主题的颜色适配逻辑
/// 消除 17+ 处重复的 isDark 判断代码
/// ============================================

class ThemeUtils {
  /// 判断当前是否为深色主题
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// 根据主题返回颜色
  static Color adaptiveColor({
    required BuildContext context,
    required Color light,
    required Color dark,
  }) {
    return isDark(context) ? dark : light;
  }

  /// 获取背景色
  static Color getBackgroundColor(BuildContext context) {
    return isDark(context) ? AppColors.darkBackgroundColor : AppColors.backgroundColor;
  }

  /// 获取卡片背景色
  static Color getCardBackground(BuildContext context) {
    return isDark(context) ? AppColors.darkCardBackground : AppColors.cardBackground;
  }

  /// 获取主文字颜色
  static Color getTextColor(BuildContext context) {
    return isDark(context) ? AppColors.darkTextColor : AppColors.textColor;
  }

  /// 获取次要文字颜色
  static Color getLightTextColor(BuildContext context) {
    return isDark(context) ? AppColors.darkLightTextColor : AppColors.lightTextColor;
  }

  /// 获取输入框背景色
  static Color getInputBackground(BuildContext context) {
    return isDark(context) ? AppColors.darkInputBackground : Colors.white;
  }

  /// 获取输入框边框颜色
  static Color getBorderColor(BuildContext context) {
    return isDark(context) ? AppColors.darkBorderColor : AppColors.borderColor;
  }

  /// 获取图标颜色
  static Color getIconColor(BuildContext context) {
    return isDark(context) ? AppColors.darkIconColor : AppColors.textColor;
  }

  /// 获取分割线颜色
  static Color getDividerColor(BuildContext context) {
    return isDark(context) ? AppColors.darkDividerColor : AppColors.dividerColor;
  }
}
