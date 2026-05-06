import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_radii.dart';
import '../../../../constants/app_spacings.dart';
import '../../models/amap_routing_models.dart';
import '../../models/map_overlay_models.dart';
import 'diff_label.dart';
import 'traffic_bar.dart';
import 'transit_line_tag.dart';

/// 路线选项卡片
///
/// 全宽横向布局：左侧距离+耗时，中部策略+线路名，右侧费用信息
class RouteCard extends StatelessWidget {
  final RouteResultItem route;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDark;
  final RouteType currentRouteType;

  const RouteCard({
    super.key,
    required this.route,
    required this.isSelected,
    this.onTap,
    required this.isDark,
    required this.currentRouteType,
  });

  @override
  Widget build(BuildContext context) {
    final isTransit = currentRouteType == RouteType.transit;
    final transitLines = route.transitLineNames;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.sm,
          vertical: AppSpacings.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.08)
              : (isDark ? AppColors.darkBackgroundColor : AppColors.grey50),
          borderRadius: BorderRadius.all(AppRadii.medium),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // 选中指示条
                if (isSelected)
                  Container(
                    width: 3,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                if (isSelected) const SizedBox(width: AppSpacings.sm),
                // 左侧：距离 + 耗时
                _buildDistanceDuration(),
                const SizedBox(width: AppSpacings.md),
                // 中部：策略 + 线路名称
                Expanded(
                  child: _buildStrategySection(isTransit, transitLines),
                ),
                const SizedBox(width: AppSpacings.sm),
                // 右侧：费用 / 换乘信息 / 差异标记
                _buildRightSection(isTransit),
                // 选中图标
                if (isSelected) ...[
                  const SizedBox(width: AppSpacings.xs),
                  const Icon(Icons.check_circle, size: 18, color: AppColors.primaryColor),
                ],
              ],
            ),
            if (isSelected && currentRouteType == RouteType.driving)
              RouteTrafficBar(route: route),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceDuration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          route.formattedDistance,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextColor : AppColors.textColor,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, size: 12, color: AppColors.grey500),
            const SizedBox(width: 2),
            Text(
              route.formattedDuration,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStrategySection(bool isTransit, List<String>? transitLines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          route.strategy,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextColor : AppColors.textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (isTransit && transitLines != null && transitLines.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: transitLines.map((name) => TransitLineTag(name: name)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildRightSection(bool isTransit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isTransit && route.tolls != null && route.tolls! > 0)
          Text(
            '¥${route.tolls!.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          )
        else if (!isTransit && route.tolls != null && route.tolls! > 0)
          Text(
            '¥${route.tolls!.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
            ),
          ),
        if (isTransit && route.transferCount > 0) ...[
          const SizedBox(height: 2),
          Text(
            '换乘${route.transferCount}次',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
            ),
          ),
        ],
        if (!isSelected && (route.timeDiff != null || route.distanceDiff != null))
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: RouteDiffLabel(route: route, isDark: isDark),
          ),
      ],
    );
  }
}
