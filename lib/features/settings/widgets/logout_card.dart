import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../state/managers/user_state_manager.dart';
import '../../../router/app_router.dart';
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
        
        // 使用 UserStateManager 执行登出
        final userStateManager = context.read<UserStateManager>();
        await userStateManager.logout();
        
        // 使用 go_router 跳转到登录页
        if (context.mounted) {
          context.goToAuth();
        }
        
        Logs.auth.info('退出登录成功');
      } catch (e, stackTrace) {
        Logs.auth.error('退出登录失败: $e', stackTrace: stackTrace);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('退出登录失败: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: '账号',
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
