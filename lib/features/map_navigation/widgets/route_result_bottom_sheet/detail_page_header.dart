import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_spacings.dart';
import '../../models/map_overlay_models.dart';

/// 详情页头部
///
/// 公交模式行程详情的顶部 Header
/// 包含：返回按钮 + 标题 + 路线摘要（距离+耗时）
class RouteDetailHeader extends StatelessWidget {
  final RouteResultItem route;
  final bool isDark;
  final VoidCallback? onBack;

  const RouteDetailHeader({
    super.key,
    required this.route,
    required this.isDark,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacings.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_back, size: 20, color: AppColors.grey600),
          ),
          const SizedBox(width: AppSpacings.sm),
          Text(
            '行程详情',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextColor : AppColors.textColor,
            ),
          ),
          const Spacer(),
          Text(
            '${route.formattedDistance} · ${route.formattedDuration}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}
