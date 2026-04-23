import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/binding_provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/binding_limits.dart';
import '../../../constants/app_spacings.dart';
import '../../../constants/app_radii.dart';
import '../../../theme/app_text_styles.dart';

/// 绑定统计卡片
class BindingStatsCard extends StatelessWidget {
  const BindingStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bindingState = context.watch<BindingNotifier>().state;
    final summary = bindingState.bindingSummary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? AppColors.darkCardBackground : AppColors.blue50;
    final borderColor = isDark ? AppColors.darkDividerColor : AppColors.blue200;

    final count = (summary?.asSender ?? 0) + (summary?.asReceiver ?? 0);
    final limit = BindingLimits.maxBindingsPerUser;
    final isLimitReached = count >= limit;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacings.lg),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.all(AppRadii.large),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Text(
            '绑定统计',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
            ),
          ),
          SizedBox(height: AppSpacings.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
Text(
                '$count',
                style: TextStyle(
                  color: isLimitReached ? AppColors.errorColor : AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              Text(
                ' / $limit',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacings.xs),
          Text(
            '发送 $count 个绑定请求',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
