import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// ============================================
/// 设置分区卡片组件
///
/// 通用的设置项容器，提供统一的卡片样式
/// ============================================

class SettingsSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkLightTextColor
                  : AppColors.lightTextColor,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
