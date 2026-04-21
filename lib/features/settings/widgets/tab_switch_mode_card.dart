import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/settings_manager.dart';
import '../../../theme/app_text_styles.dart';
import 'settings_section_card.dart';

/// 防误触模式设置卡片
class TabSwitchModeCard extends ConsumerWidget {
  const TabSwitchModeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsState = ref.watch(settingsManagerProvider);
    final notifier = ref.read(settingsManagerProvider.notifier);

    return SettingsSectionCard(
      title: '防误触模式',
      child: SwitchListTile(
        title: Text(
          settingsState.doubleTapToSwitchTab
              ? '双击切换页面，已禁止路线规划'
              : '单击切换页面，已启用路线规划',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextColor : AppColors.textColor,
          ),
        ),
        subtitle: Text(
          settingsState.doubleTapToSwitchTab
              ? '避免误触顶部标签切换页面'
              : '单击顶部标签即可切换页面',
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
          ),
        ),
        value: settingsState.doubleTapToSwitchTab,
        onChanged: (value) {
          notifier.setDoubleTapTab(value);
        },
        activeThumbColor: AppColors.primaryColor,
      ),
    );
  }
}
