import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_spacings.dart';

/// 空状态组件
///
/// 无路线时的空状态提示
class RouteEmptyState extends StatelessWidget {
  const RouteEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 80,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route,
              size: 36,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey400,
            ),
            SizedBox(height: AppSpacings.xs),
            Text(
              '暂无路线',
              style: TextStyle(
                color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
