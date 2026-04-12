import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/secure_storage.dart';
import '../../utils/logger.dart';
import '../../theme/app_text_styles.dart';

/// 退出登录确认对话框
///
/// 公共组件,用于各个页面的退出登录功能
/// 点击确认后清除登录状态并返回 true，由调用方处理导航

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  /// 显示退出登录对话框
  ///
  /// [context] BuildContext
  /// 返回 `Future<bool>` - 用户是否确认退出
  /// 如果返回 true，调用方需要：
  /// 1. 清除本地存储
  /// 2. 跳转到登录页
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const LogoutDialog(),
    );

    if (result == true) {
      Logs.auth.info('用户确认退出');
      // 清除本地存储
      await SecureStorage.clearTokens();
      Logs.storage.info('已清除本地存储');
    }

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppStrings.logoutConfirmTitle,
        textAlign: TextAlign.center,
        style: AppTextStyles.emojiLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.black87,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Row(
          children: [
            // 确定按钮（左边）
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.confirm,
                  style: AppTextStyles.dialogConfirmButton.copyWith(
                    fontSize: 22 * AppTextStyles.fontSizeScale,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 取消按钮（右边）
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightTextColor,
                  foregroundColor: AppColors.whiteText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.cancel,
                  style: AppTextStyles.dialogButton.copyWith(
                    fontSize: 22 * AppTextStyles.fontSizeScale,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
