import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../models/amap_routing_models.dart';

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
          // Header: summary
          _buildSummaryHeader(isDark),
          const SizedBox(height: AppSpacings.sm),
          // Segment list
          ...List.generate(segments.length, (i) {
            final isFirst = i == 0;
            final isLast = i == segments.length - 1;
            return _buildSegmentRow(
              context,
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
          _buildSummaryChip('${totalDuration ~/ 60}分钟', Icons.access_time, isDark),
          const SizedBox(width: AppSpacings.sm),
          _buildSummaryChip(
            totalDistance >= 1000
                ? '${(totalDistance / 1000).toStringAsFixed(1)}km'
                : '${totalDistance.toInt()}m',
            Icons.straighten,
            isDark,
          ),
          if (transferCount > 0) ...[
            const SizedBox(width: AppSpacings.sm),
            _buildSummaryChip('换乘$transferCount次', Icons.swap_horiz, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String text, IconData icon, bool isDark) {
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

  Widget _buildSegmentRow(
    BuildContext context,
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
            // Timeline column
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  // Top connector
                  if (!isFirst)
                    _buildConnector(isDark, topHalf: true)
                  else
                    const SizedBox(height: 12),
                  // Node dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBackgroundColor : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  // Bottom connector
                  if (!isLast)
                    _buildConnector(isDark, topHalf: false)
                  else
                    const SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(width: AppSpacings.sm),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacings.md),
                child: _buildSegmentContent(context, segment, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector(bool isDark, {required bool topHalf}) {
    return Expanded(
      child: Container(
        width: 2,
        color: isDark ? AppColors.darkDividerColor : AppColors.grey300,
      ),
    );
  }

  Widget _buildSegmentContent(BuildContext context, TransitSegment seg, bool isDark) {
    if (seg.hasTransit) {
      return _buildTransitContent(context, seg, isDark);
    }
    return _buildWalkContent(seg, isDark);
  }

  Widget _buildWalkContent(TransitSegment seg, bool isDark) {
    final walkDistance = seg.walkingDistance > 0
        ? seg.walkingDistance
        : _calcDistance(seg.points).round();
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
              color: _segmentThemeColor(seg).withValues(alpha: 0.15),
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
                if (seg.walkSteps != null && seg.walkSteps!.isNotEmpty)
                  Text(
                    seg.walkSteps!.map((s) => s.actionText).join(' → '),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitContent(BuildContext context, TransitSegment seg, bool isDark) {
    // May have multiple lines in one segment (e.g. bus transfer within same segment)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: seg.lines.map((line) {
        return _buildLineCard(context, line, isDark);
      }).toList(),
    );
  }

  Widget _buildLineCard(BuildContext context, TransitLine line, bool isDark) {
    final color = _lineColor(line);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacings.xs),
      padding: const EdgeInsets.all(AppSpacings.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: const BorderRadius.all(AppRadii.small),
        border: Border.all(
          color: isDark ? AppColors.darkDividerColor : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: line name + type badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  line.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacings.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  line.typeText,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              const Spacer(),
              if (line.duration != null)
                Text(
                  '${(line.duration! / 60).round()}分钟',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacings.xs),
          // Stations
          if (line.departureStation != null || line.arrivalStation != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 16,
                  child: Column(
                    children: [
                      const Icon(Icons.trip_origin, size: 10, color: AppColors.primaryColor),
                      const SizedBox(height: 2),
                      Container(width: 2, height: 16, color: AppColors.grey300),
                      const SizedBox(height: 2),
                      const Icon(Icons.location_on, size: 10, color: AppColors.errorColor),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacings.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.departureStation ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        line.arrivalStation ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          // Station count, price, schedule
          if (line.stationCount > 0 || line.totalPrice != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacings.xs),
              child: Wrap(
                spacing: AppSpacings.md,
                runSpacing: 2,
                children: [
                  if (line.stationCount > 0)
                    _buildInfoTag('${line.stationCount}站', Icons.transfer_within_a_station, isDark),
                  if (line.totalPrice != null && line.totalPrice! > 0)
                    _buildInfoTag('¥${line.totalPrice!.toStringAsFixed(0)}', Icons.attach_money, isDark),
                  if (line.firstBusTime != null && line.lastBusTime != null)
                    _buildInfoTag(
                      '${line.firstBusTime}-${line.lastBusTime}',
                      Icons.schedule,
                      isDark,
                    ),
                  if (line.trip != null)
                    _buildInfoTag(line.trip!, Icons.directions_railway, isDark),
                ],
              ),
            ),
          // Railway details
          if (line.railwayStations != null && line.railwayStations!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacings.xs),
              child: Text(
                line.railwayStations!
                    .map((s) => '${s.name} ${s.time}')
                    .join(' → '),
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Spaces (seat classes / prices)
          if (line.spaces != null && line.spaces!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacings.xs),
              child: Wrap(
                spacing: AppSpacings.sm,
                children: line.spaces!.map((space) {
                  final seatLabel = _seatLabel(space.code);
                  return Text(
                    '$seatLabel ¥${space.cost.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String text, IconData icon, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: AppColors.grey400),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
          ),
        ),
      ],
    );
  }

  static Color _segmentThemeColor(TransitSegment seg) {
    switch (seg.segmentType) {
      case 1:
        return const Color(0xFF1890FF);
      case 2:
        return const Color(0xFFFF4D4F);
      default:
        return const Color(0xFF8C8C8C);
    }
  }

  static Color _lineColor(TransitLine line) {
    switch (line.type) {
      case TransitLineType.subway:
      case TransitLineType.suburban:
        return const Color(0xFFFF4D4F);
      case TransitLineType.bus:
        return const Color(0xFF1890FF);
    }
  }

  static String _seatLabel(String code) {
    switch (code.toUpperCase()) {
      case 'M':
        return '一等座';
      case 'O':
        return '二等座';
      case 'F':
        return '商务座';
      case 'P':
        return '特等座';
      default:
        return code;
    }
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
