import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_colors.dart';

/// ============================================
/// 通用确认对话框组件
///
/// 统一封装 showDialog 逻辑
/// 消除 15+ 处重复的对话框代码
/// ============================================

class AppConfirmDialog {
  /// 显示确认对话框
  ///
  /// 返回 true 表示用户点击了确认按钮，false 表示取消
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    Color? confirmTextColor,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTextStyles.dialogTitle,
        ),
        content: Text(
          message,
          style: AppTextStyles.dialogContent,
        ),
        actions: [
          // 取消按钮
          TextButton(
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            },
            child: Text(
              cancelText ?? '取消',
              style: AppTextStyles.dialogButton,
            ),
          ),
          // 确认按钮
          ElevatedButton(
            onPressed: () {
              onConfirm?.call();
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              confirmText ?? '确定',
              style: AppTextStyles.dialogButton.copyWith(
                color: confirmTextColor ?? AppColors.whiteText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示危险操作确认对话框（红色主题）
  static Future<bool?> showDanger(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
  }) {
    return show(
      context,
      title: title,
      message: message,
      confirmText: confirmText ?? '确定',
      confirmColor: AppColors.errorColor,
      confirmTextColor: AppColors.whiteText,
    );
  }
}
