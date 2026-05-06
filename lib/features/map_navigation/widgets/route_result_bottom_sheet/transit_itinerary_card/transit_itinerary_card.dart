import 'package:flutter/material.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_radii.dart';
import '../../../../../constants/app_spacings.dart';
import '../../../models/amap_routing_models.dart';
import 'segment_timeline.dart';
import 'walk_segment_card.dart';
import 'transit_line_card.dart';
import 'railway_segment_card.dart';
import 'taxi_segment_card.dart';
import 'shared/summary_chip.dart';

/// ============================================
/// 公共交通行程详情卡片
///
/// 显示 step-by-step 的公共交通行程分解：
/// 步行 → 公交/地铁/铁路 → 步行 → ...
/// ============================================

class TransitItineraryCard extends StatelessWidget {
  final List<TransitSegment> segments;
  final double totalDistance;
  final double totalDuration;
  final double tolls;
  final double? walkDistance;
  final int transferCount;

  const TransitItineraryCard({
    super.key,
    required this.segments,
    required this.totalDistance,
    required this.totalDuration,
    required this.tolls,
    this.walkDistance,
    this.transferCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackgroundColor : AppColors.grey50,
        borderRadius: const BorderRadius.vertical(top: AppRadii.large),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryHeader(isDark),
          const SizedBox(height: AppSpacings.sm),
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
    );
  }

  Widget _buildSummaryHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacings.md, AppSpacings.md, AppSpacings.md, 0,
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_bus, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: AppSpacings.xs),
          Text(
            '行程详情',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextColor : AppColors.textColor,
            ),
          ),
          const Spacer(),
          SummaryChip(
            text: '${totalDuration ~/ 60}分钟',
            icon: Icons.access_time,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacings.sm),
          SummaryChip(
            text: totalDistance >= 1000
                ? '${(totalDistance / 1000).toStringAsFixed(1)}km'
                : '${totalDistance.toInt()}m',
            icon: Icons.straighten,
            isDark: isDark,
          ),
          if (transferCount > 0) ...[
            const SizedBox(width: AppSpacings.sm),
            SummaryChip(
              text: '换乘$transferCount次',
              icon: Icons.swap_horiz,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSegmentRow(
    TransitSegment segment, {
    required bool isFirst,
    required bool isLast,
    required bool isDark,
  }) {
    final color = _segmentThemeColor(segment);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacings.md),
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
                padding: const EdgeInsets.only(bottom: AppSpacings.md),
                child: _buildSegmentContent(segment, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentContent(TransitSegment seg, bool isDark) {
    if (seg.hasRailway) {
      return RailwaySegmentCard(railway: seg.railway!, isDark: isDark);
    }
    if (seg.hasTaxi) {
      return TaxiSegmentCard(taxi: seg.taxi!, isDark: isDark);
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

  static Color _segmentThemeColor(TransitSegment seg) {
    switch (seg.segmentType) {
      case 0:
        return const Color(0xFF8C8C8C);
      case 1:
        return const Color(0xFF1890FF);
      case 2:
        return const Color(0xFFFF4D4F);
      case 3:
        return const Color(0xFF52C41A);
      case 4:
        return const Color(0xFF722ED1);
      default:
        return const Color(0xFF8C8C8C);
    }
  }
}
