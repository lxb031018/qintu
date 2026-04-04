import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../config/app_config.dart';
import '../../services/secure_storage.dart';
import '../../pages/role_selection_page.dart';

/// 退出登录确认对话框
///
/// 公共组件,用于各个页面的退出登录功能
/// 点击确认后清除登录状态并跳转到角色选择页面

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  /// 显示退出登录对话框
  ///
  /// [context] BuildContext
  /// 返回 `Future<bool>` - 用户是否确认退出
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const LogoutDialog(),
    );
    return result ?? false;
  }

  /// 处理退出登录逻辑
  static Future<void> _handleLogout(BuildContext context) async {
    // 关闭对话框
    Navigator.of(context).pop(true);

    // 清除登录状态
    await SecureStorage.clearTokens();

    // 跳转到角色选择页面
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RoleSelectionPage(
          userId: '',
          accessToken: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppStrings.logoutConfirmTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontFamily: AppConfig.fontFamily,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Row(
          children: [
            // 确定按钮（左边）
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.confirmLogout,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConfig.fontFamily,
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
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.cancelLogout,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConfig.fontFamily,
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
