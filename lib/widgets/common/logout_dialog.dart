import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../config/app_config.dart';
import '../../state/managers/user_state_manager.dart';

/// 退出登录确认对话框
///
/// 公共组件,用于各个页面的退出登录功能
/// 点击确认后清除登录状态并跳转到登录页面

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
  static Future<void> _handleLogout(BuildContext dialogContext) async {
    // 先关闭对话框
    if (!dialogContext.mounted) return;
    Navigator.of(dialogContext).pop(true);

    // 使用用户状态管理器退出登录
    try {
      final userStateManager = dialogContext.read<UserStateManager>();
      await userStateManager.logout();
      
      // 路由会由 go_router 的 redirect 自动处理
      // 当 isLoggedIn 变为 false 时，会自动重定向到 /auth
    } catch (e) {
      // 如果退出失败，显示错误消息
      if (dialogContext.mounted) {
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Text('退出登录失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
