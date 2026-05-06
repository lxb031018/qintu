import 'package:flutter/material.dart';
import 'package:qintu/constants/app_colors.dart';

/// 行程概览标签（时间/距离/换乘）
class SummaryChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isDark;

  const SummaryChip({
    super.key,
    required this.text,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.grey500),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
          ),
        ),
      ],
    );
  }
}