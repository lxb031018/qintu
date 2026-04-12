import 'package:flutter/material.dart';
import '../../../providers/binding_provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/binding_limits.dart';
import '../../../theme/app_text_styles.dart';

/// 绑定统计卡片
class BindingStatsCard extends StatelessWidget {
  final BindingProvider provider;

  const BindingStatsCard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? AppColors.darkCardBackground : AppColors.blue50;
    final borderColor = isDark ? AppColors.darkDividerColor : AppColors.blue200;

    final count = provider.totalBindings;
    final limit = BindingLimits.maxBindingsPerUser;
    final isLimitReached = provider.isBindingLimitReached;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_alt_outlined,
            color: isLimitReached ? AppColors.errorColor : AppColors.infoColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.myBindings,
                style: AppTextStyles.statLabel,
              ),
              Text(
                '$count/$limit',
                style: AppTextStyles.statValue.copyWith(
                  color: isLimitReached ? AppColors.errorColor : null,
                ),
              ),
              if (isLimitReached)
                Text(
                  AppStrings.limitReached,
                  style: AppTextStyles.statUnit,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
