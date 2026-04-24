import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme_manager.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_spacings.dart';
import '../../../constants/app_radii.dart';
import '../../../theme/app_text_styles.dart';
import 'settings_section_card.dart';

/// ============================================
/// 主题选择卡片组件
///
/// 提供浅色/深色/跟随系统三种主题选项
/// ============================================

class ThemeSelectorCard extends ConsumerWidget {
  const ThemeSelectorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeManagerProvider);

    return SettingsSectionCard(
      title: AppStrings.themeSettings,
      child: Column(
        children: [
          _buildThemeOption(
            context: context,
            ref: ref,
            currentMode: currentThemeMode,
            themeMode: ThemeMode.light,
            icon: Icons.light_mode,
            title: AppStrings.lightMode,
          ),
          SizedBox(height: AppSpacings.md),
          _buildThemeOption(
            context: context,
            ref: ref,
            currentMode: currentThemeMode,
            themeMode: ThemeMode.dark,
            icon: Icons.dark_mode,
            title: AppStrings.darkMode,
          ),
          SizedBox(height: AppSpacings.md),
          _buildThemeOption(
            context: context,
            ref: ref,
            currentMode: currentThemeMode,
            themeMode: ThemeMode.system,
            icon: Icons.brightness_auto,
            title: AppStrings.followSystem,
          ),
        ],
      ),
    );
  }

  /// 切换主题
  Future<void> _switchTheme(WidgetRef ref, ThemeMode themeMode) async {
    await ref.read(themeManagerProvider.notifier).setThemeMode(themeMode);
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeMode currentMode,
    required ThemeMode themeMode,
    required IconData icon,
    required String title,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = currentMode == themeMode;

    return InkWell(
      onTap: () => _switchTheme(ref, themeMode),
      borderRadius: BorderRadius.all(AppRadii.small),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacings.lg, vertical: AppSpacings.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.all(AppRadii.small),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : isDark
                    ? AppColors.darkDividerColor
                    : AppColors.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryColor
                  : isDark
                      ? AppColors.darkIconColor
                      : AppColors.textColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primaryColor
                      : isDark
                          ? AppColors.darkTextColor
                          : AppColors.textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}