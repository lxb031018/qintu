import 'package:flutter/material.dart';
import '../../../../../../constants/app_colors.dart';
import '../../../../../../constants/app_radii.dart';
import '../../../../../../constants/app_spacings.dart';
import '../../../models/amap_routing_models.dart';

/// ============================================
/// 步行段展示组件
///
/// 公交行程中的步行段，显示步行距离和起止指示
/// ============================================
class WalkSegmentCard extends StatelessWidget {
  final BusTransitSegment segment;
  final Color themeColor;
  final bool isDark;

  const WalkSegmentCard({
    super.key,
    required this.segment,
    required this.themeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final walkDistance = segment.distance > 0
        ? segment.distance.round()
        : _calcDistance(segment.points).round();
    final distanceText = walkDistance >= 1000
        ? '${(walkDistance / 1000).toStringAsFixed(1)}km'
        : '${walkDistance}m';

    return Container(
      padding: const EdgeInsets.all(AppSpacings.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: const BorderRadius.all(AppRadii.small),
        border: Border.all(
          color: isDark ? AppColors.darkDividerColor : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.directions_walk, size: 16, color: AppColors.grey600),
          ),
          const SizedBox(width: AppSpacings.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '步行$distanceText',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                  ),
                ),
                if (segment.walkSteps != null && segment.walkSteps!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${segment.walkSteps!.first.instruction} → ${segment.walkSteps!.last.instruction}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calcDistance(List<LatLng> points) {
    if (points.length < 2) return 0;
    double dist = 0;
    for (int i = 0; i < points.length - 1; i++) {
      dist += points[i].distanceTo(points[i + 1]);
    }
    return dist;
  }
}