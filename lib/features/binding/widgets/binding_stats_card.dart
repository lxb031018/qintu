import 'package:flutter/material.dart';
import '../../../providers/binding_provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../utils/constants.dart';
import '../../../theme/app_text_styles.dart';

/// 绑定统计卡片
class BindingStatsCard extends StatelessWidget {
  final BindingProvider provider;

  const BindingStatsCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? AppColors.darkCardBackground : Colors.blue.shade50;
    final borderColor = isDark ? AppColors.darkDividerColor : Colors.blue.shade200;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.currentBinding,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.person_outlined,
                  label: AppStrings.asSender,
                  value: '${provider.asSenderCount}/${Constants.maxReceiversPerSender}',
                  isLimitReached: provider.isSenderLimitReached,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatItem(
                  icon: Icons.group_outlined,
                  label: AppStrings.asReceiver,
                  value: '${provider.asReceiverCount}/${Constants.maxSendersPerReceiver}',
                  isLimitReached: provider.isReceiverLimitReached,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 统计项
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLimitReached;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isLimitReached = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: isLimitReached ? AppColors.errorColor : Colors.blue),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.statLabel,
        ),
        const SizedBox(height: 2),
        Text(
          value,
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
    );
  }
}
