import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_spacings.dart';
import '../../models/amap_routing_models.dart';
import '../../models/map_overlay_models.dart';

/// 路线选项卡片
///
/// 垂直堆叠布局的小方块卡片，用于步行、骑行、驾车水平滚动场景
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.sm,
          vertical: AppSpacings.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? _getRouteTypeColor(currentRouteType).withValues(alpha: 0.15)
              : (isDark ? AppColors.darkCardBackground : AppColors.cardBackground),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? _getRouteTypeColor(currentRouteType)
                : (isDark ? AppColors.darkDividerColor : AppColors.grey200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _getRouteTypeColor(currentRouteType).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getRouteTypeIcon(currentRouteType),
                  size: 14,
                  color: _getRouteTypeColor(currentRouteType),
                ),
                const SizedBox(width: 4),
                Text(
                  _getRouteTypeLabel(currentRouteType),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getRouteTypeColor(currentRouteType),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, size: 12, color: AppColors.grey500),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    route.formattedDuration,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.straighten, size: 11, color: AppColors.grey400),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    route.formattedDistance,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.traffic, size: 11, color: AppColors.grey400),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    route.strategy,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.darkLightTextColor : AppColors.grey400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRouteTypeColor(RouteType type) {
    if (type == RouteType.driving) return const Color(0xFF1890FF);
    if (type == RouteType.walking) return const Color(0xFF52C41A);
    if (type == RouteType.riding) return const Color(0xFFFAAD14);
    return const Color(0xFF722ED1);
  }

  IconData _getRouteTypeIcon(RouteType type) {
    if (type == RouteType.driving) return Icons.directions_car;
    if (type == RouteType.walking) return Icons.directions_walk;
    if (type == RouteType.riding) return Icons.directions_bike;
    return Icons.directions_bus;
  }

  String _getRouteTypeLabel(RouteType type) {
    if (type == RouteType.driving) return '出租车';
    if (type == RouteType.walking) return '步行';
    if (type == RouteType.riding) return '骑行';
    return '公交';
  }
}