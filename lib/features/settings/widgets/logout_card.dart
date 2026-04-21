import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import 'settings_section_card.dart';

/// ============================================
/// 退出登录卡片组件
///
/// 提供退出登录功能
/// ============================================

class LogoutCard extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLogout;

  const LogoutCard({
    super.key,
    required this.isLoading,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: AppStrings.account,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onLogout,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.whiteText,
                ),
              )
            : const Icon(Icons.logout),
        label: Text(isLoading ? AppStrings.loggingOut : AppStrings.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorColor,
          foregroundColor: AppColors.whiteText,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
