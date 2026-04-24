import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_text_styles.dart';
import '../../router/app_router.dart';
import 'widgets/theme_selector_card.dart';
import 'widgets/logout_card.dart';
import 'widgets/font_size_selector_card.dart';
import 'widgets/tab_switch_mode_card.dart';
import 'provider/settings_page_provider.dart';

/// ============================================
/// 设置页面
///
/// 使用 Riverpod Notifier 管理状态，遵循四层架构
/// ============================================

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageState = ref.watch(settingsPageProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FontSizeSelectorCard(),
          const SizedBox(height: 16),
          const TabSwitchModeCard(),
          const SizedBox(height: 16),
          const ThemeSelectorCard(),
          const SizedBox(height: 16),
          LogoutCard(
            isLoading: pageState.isLoggingOut,
            onLogout: () => _handleLogout(context, ref),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '${AppStrings.appName} v1.0.0',
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.darkLightTextColor
                    : AppColors.lightTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(settingsPageProvider.notifier).handleLogout();
    if (success && context.mounted) {
      context.goToAuth();
    }
  }
}