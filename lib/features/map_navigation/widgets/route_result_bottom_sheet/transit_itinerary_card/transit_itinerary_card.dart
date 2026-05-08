import 'package:flutter/material.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_radii.dart';
import '../../../../../constants/app_spacings.dart';
import '../../../models/amap_routing_models.dart';
import '../../../models/bus_route_models.dart';
import 'segment_timeline.dart';
import 'walk_segment_card.dart';
import 'transit_line_card.dart';
import 'taxi_segment_card.dart';

/// ============================================
/// 公共交通行程详情卡片
///
/// 显示 step-by-step 的公共交通行程分解：
/// 步行 → 公交/地铁 → 步行 → ...
/// ============================================

class TransitItineraryCard extends StatelessWidget {
  final List<BusTransitSegment> segments;
  final double totalDistance;
  final double totalDuration;
  final double tolls;
  final double? walkDistance;

  const TransitItineraryCard({
    super.key,
    required this.segments,
    required this.totalDistance,
    required this.totalDuration,
    required this.tolls,
    this.walkDistance,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackgroundColor : AppColors.grey50,
        borderRadius: const BorderRadius.vertical(top: AppRadii.large),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacings.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(segments.length, (i) {
              final isFirst = i == 0;
              final isLast = i == segments.length - 1;
              return _buildSegmentRow(
                segments[i],
                isFirst: isFirst,
                isLast: isLast,
                isDark: isDark,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentRow(
    BusTransitSegment segment, {
    required bool isFirst,
    required bool isLast,
    required bool isDark,
  }) {
    final color = _segmentThemeColor(segment);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacings.sm),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentTimeline(
              color: color,
              showTopLine: !isFirst,
              showBottomLine: !isLast,
              isDark: isDark,
            ),
            const SizedBox(width: AppSpacings.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacings.sm),
                child: _buildSegmentContent(segment, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentContent(BusTransitSegment seg, bool isDark) {
    if (seg.hasTaxi) {
      return TaxiSegmentCard(segment: seg, isDark: isDark);
    }
    if (seg.hasTransit) {
      return TransitSegmentContent(segment: seg, isDark: isDark);
    }
    return WalkSegmentCard(
      segment: seg,
      themeColor: _segmentThemeColor(seg),
      isDark: isDark,
    );
  }

  static Color _segmentThemeColor(BusTransitSegment seg) {
    switch (seg.segmentType) {
      case 0:
        return const Color(0xFF8C8C8C);
      case 1:
        return const Color(0xFF1890FF);
      case 2:
        return const Color(0xFFFF4D4F);
      case 4:
        return const Color(0xFF722ED1);
      default:
        return const Color(0xFF8C8C8C);
    }
  }
}
