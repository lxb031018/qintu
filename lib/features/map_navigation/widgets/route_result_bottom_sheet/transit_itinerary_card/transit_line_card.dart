import 'package:flutter/material.dart';
import '../../../../../../constants/app_colors.dart';
import '../../../../../../constants/app_radii.dart';
import '../../../../../../constants/app_spacings.dart';
import '../../../models/amap_routing_models.dart';
import 'shared/entrance_exit_info.dart';
import 'shared/info_tag.dart';

/// 公交/地铁线路卡片
class TransitLineCard extends StatelessWidget {
  final TransitLine line;
  final bool isDark;

  const TransitLineCard({
    super.key,
    required this.line,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(color),
          if (line.departureStation != null || line.arrivalStation != null) ...[
            const SizedBox(height: AppSpacings.xs),
            _buildStationRoute(color),
          ],
          if (line.stationCount > 0 || line.totalPrice != null || line.firstBusTime != null)
            _buildInfoTags(),
          if (line.passStations != null && line.passStations!.isNotEmpty)
            _buildPassStations(),
          if (line.spaces != null && line.spaces!.isNotEmpty)
            _buildSpaces(),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Row(
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
        if (line.lineType != null && line.lineType!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              line.lineType!,
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
    );
  }

  Widget _buildInfoTags() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacings.xs),
      child: Wrap(
        spacing: AppSpacings.md,
        runSpacing: 2,
        children: [
          if (line.stationCount > 0)
            InfoTag(
              text: '${line.stationCount}站',
              icon: Icons.transfer_within_a_station,
              isDark: isDark,
            ),
          if (line.totalPrice != null && line.totalPrice! > 0)
            InfoTag(
              text: '¥${line.totalPrice!.toStringAsFixed(0)}',
              icon: Icons.attach_money,
              isDark: isDark,
            ),
          if (line.firstBusTime != null && line.lastBusTime != null)
            InfoTag(
              text: '${line.firstBusTime}-${line.lastBusTime}',
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
        '途经: ${line.passStations!.map((s) => s.name).join(" → ")}',
        style: TextStyle(
          fontSize: 10,
          color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSpaces() {
    return Padding(
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
    );
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
}

/// 公共交通多线路段内容（一个 TransitSegment 可能包含多条线路）
class TransitSegmentContent extends StatelessWidget {
  final TransitSegment segment;
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
        for (final line in segment.lines) TransitLineCard(line: line, isDark: isDark),
        EntranceExitInfo(
          entrance: segment.entrance,
          exit: segment.exit,
          isDark: isDark,
        ),
      ],
    );
  }
}