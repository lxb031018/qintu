import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../providers/auth_state_manager.dart';
import '../../../router/app_router.dart';
import '../../../utils/app_snackbar.dart';
import '../../../utils/logger.dart';
import '../../../widgets/common/logout_dialog.dart';
import 'settings_section_card.dart';

/// ============================================
/// 退出登录卡片组件
///
/// 提供退出登录功能
/// ============================================

class LogoutCard extends StatelessWidget {
  const LogoutCard({super.key});

  /// 处理退出登录
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await LogoutDialog.show(context);

    if (confirmed && context.mounted) {
      try {
        Logs.auth.info('执行退出登录');

        // 使用 AuthStateManager 执行登出
        final authStateManager = context.read<AuthStateManager>();
        await authStateManager.logout();
        
        // 使用 go_router 跳转到登录页
        if (context.mounted) {
          context.goToAuth();
        }
        
        Logs.auth.info('退出登录成功');
      } catch (e, stackTrace) {
        Logs.auth.error('退出登录失败: $e', stackTrace: stackTrace);
        if (context.mounted) {
          AppSnackbar.showError(context, '${AppStrings.logoutFailed}: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: AppStrings.account,
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout),
        label: const Text(AppStrings.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorColor,
          foregroundColor: AppColors.whiteText,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
