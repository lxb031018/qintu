import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_colors.dart';

/// ============================================
/// SnackBar 辅助类
///
/// 统一封装 SnackBar 显示逻辑，消除重复代码
/// 提供成功、错误、信息三种类型的快捷方法
/// ============================================

class AppSnackbar {
  /// 显示成功提示（绿色）
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppColors.successColor);
  }

  /// 显示错误提示（红色）
  static void showError(BuildContext context, String message) {
    _show(context, message, AppColors.errorColor);
  }

  /// 显示信息提示（蓝色）
  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppColors.infoColor);
  }

  /// 显示警告提示（橙色）
  static void showWarning(BuildContext context, String message) {
    _show(context, message, AppColors.warningColor);
  }

  /// 显示主题色提示（使用 Theme 的 primaryContainer）
  static void showPrimary(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.caption),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
      ),
    );
  }

  /// 显示错误主题（使用 Theme 的 errorContainer）
  static void showErrorTheme(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.caption),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
      ),
    );
  }

  /// 内部统一实现
  static void _show(BuildContext context, String message, Color backgroundColor) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.whiteText,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
