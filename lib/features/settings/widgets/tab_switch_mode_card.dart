import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/settings_manager.dart';
import '../../../theme/app_text_styles.dart';
import 'settings_section_card.dart';

/// Tab 切换模式设置卡片
class TabSwitchModeCard extends StatelessWidget {
  const TabSwitchModeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsManager = Provider.of<SettingsManager>(context);

    return SettingsSectionCard(
      title: 'Tab 切换',
      child: SwitchListTile(
        title: Text(
          settingsManager.doubleTapToSwitchTab
              ? '双击切换页面'
              : '单击切换页面',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextColor : AppColors.textColor,
          ),
        ),
        subtitle: Text(
          settingsManager.doubleTapToSwitchTab
              ? '防误触模式（推荐）'
              : '单击顶部标签切换页面',
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
          ),
        ),
        value: settingsManager.doubleTapToSwitchTab,
        onChanged: (value) {
          settingsManager.setDoubleTapTab(value);
        },
        activeThumbColor: AppColors.primaryColor,
      ),
    );
  }
}
