import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_spacings.dart';

/// ============================================
/// 路线按钮（入口，不参与列表分类）
/// ============================================

class LocationRouteButton extends StatelessWidget {
  final VoidCallback? onTap;

  const LocationRouteButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.sm,
          vertical: AppSpacings.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route,
              size: 16,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
            ),
            const SizedBox(width: 4),
            Text(
              '路线',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
