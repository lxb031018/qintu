import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
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
  void _handleLogout(BuildContext context) {
    LogoutDialog.show(context);
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
