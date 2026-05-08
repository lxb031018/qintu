import 'package:flutter/material.dart';
import '../../../../../../constants/app_colors.dart';
import '../../../../../../constants/app_radii.dart';
import '../../../../../../constants/app_spacings.dart';
import '../../../models/amap_routing_models.dart';
import '../../../models/bus_route_models.dart';
import 'shared/entrance_exit_info.dart';
import 'shared/info_tag.dart';

/// 公交/地铁线路卡片
class TransitLineCard extends StatelessWidget {
  final BusTransitSegment segment;
  final bool isDark;

  const TransitLineCard({
    super.key,
    required this.segment,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = _lineColor(segment);

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
          _buildHeader(color),
          if (segment.departureStation != null || segment.arrivalStation != null) ...[
            const SizedBox(height: AppSpacings.xs),
            _buildStationRoute(color),
          ],
          if ((segment.stationCount ?? 0) > 0 ||
              segment.totalPrice != null ||
              segment.firstBusTime != null)
            _buildInfoTags(),
          if (segment.passStations != null && segment.passStations!.isNotEmpty)
            _buildPassStations(),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    final typeLabel = segment.type == TransitSegmentType.subway ? '地铁' : '公交';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            segment.lineName ?? '',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: AppSpacings.xs),
        if (segment.lineType != null && segment.lineType!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              segment.lineType!,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              typeLabel,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        const Spacer(),
        if (segment.duration != null)
          Text(
            '${(segment.duration! / 60).round()}分钟',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
            ),
          ),
      ],
    );
  }

  Widget _buildStationRoute(Color color) {
    return Row(
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
                segment.departureStation ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                segment.arrivalStation ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTags() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacings.xs),
      child: Wrap(
        spacing: AppSpacings.md,
        runSpacing: 2,
        children: [
          if ((segment.stationCount ?? 0) > 0)
            InfoTag(
              text: '${segment.stationCount}站',
              icon: Icons.transfer_within_a_station,
              isDark: isDark,
            ),
          if (segment.totalPrice != null && segment.totalPrice! > 0)
            InfoTag(
              text: '¥${segment.totalPrice!.toStringAsFixed(0)}',
              icon: Icons.attach_money,
              isDark: isDark,
            ),
          if (segment.firstBusTime != null && segment.lastBusTime != null)
            InfoTag(
              text: '${segment.firstBusTime}-${segment.lastBusTime}',
              icon: Icons.schedule,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildPassStations() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacings.xs),
      child: Text(
        '途经: ${segment.passStations!.map((s) => s.name).join(" → ")}',
        style: TextStyle(
          fontSize: 10,
          color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static Color _lineColor(BusTransitSegment segment) {
    switch (segment.type) {
      case TransitSegmentType.subway:
        return const Color(0xFFFF4D4F);
      case TransitSegmentType.bus:
        return const Color(0xFF1890FF);
      default:
        return const Color(0xFF1890FF);
    }
  }
}

/// 公共交通多线路段内容
class TransitSegmentContent extends StatelessWidget {
  final BusTransitSegment segment;
  final bool isDark;

  const TransitSegmentContent({
    super.key,
    required this.segment,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransitLineCard(segment: segment, isDark: isDark),
        EntranceExitInfo(
          entrance: segment.entrance,
          exit: segment.exit,
          isDark: isDark,
        ),
      ],
    );
  }
}
