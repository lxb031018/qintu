import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_durations.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_spacings.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/font_size_setting.dart';
import '../../../providers/settings_manager.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/logger.dart';

/// 字体大小选择卡片组件
class FontSizeSelectorCard extends ConsumerWidget {
  const FontSizeSelectorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.textColor;
    final settingsState = ref.watch(settingsManagerProvider);

    return Container(
      padding: EdgeInsets.all(AppSpacings.xl),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(AppRadii.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackOpacity5,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(Icons.text_fields, color: textColor, size: 24),
              const SizedBox(width: 12),
              Text(
                AppStrings.fontSize,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacings.lg),
          // 选项网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppSpacings.md,
              mainAxisSpacing: AppSpacings.md,
            ),
            itemCount: FontSizeOption.values.length,
            itemBuilder: (context, index) {
              final option = FontSizeOption.values[index];
              final isSelected = option.scale == settingsState.fontSizeScale;
              return _FontSizeOptionButton(
                option: option,
                isSelected: isSelected,
                onTap: () => _selectFontSize(ref, option.scale),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectFontSize(WidgetRef ref, double scale) async {
    await ref.read(settingsManagerProvider.notifier).setFontSizeScale(scale);
    Logs.ui.info('字体大小已调整为 ${scale}x');
  }
}

/// 字体大小选项按钮
class _FontSizeOptionButton extends StatelessWidget {
  final FontSizeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontSizeOptionButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fastAnimation,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : isDark
                  ? AppColors.darkBackgroundColor
                  : AppColors.grey100,
          borderRadius: BorderRadius.all(AppRadii.medium),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : isDark
                    ? AppColors.darkBorderColor
                    : AppColors.grey300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              color: isSelected ? AppColors.whiteText : AppColors.primaryColor,
              size: 24,
            ),
            SizedBox(height: AppSpacings.xs),
            Text(
              option.label,
              style: AppTextStyles.locationTitle.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.whiteText : AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}