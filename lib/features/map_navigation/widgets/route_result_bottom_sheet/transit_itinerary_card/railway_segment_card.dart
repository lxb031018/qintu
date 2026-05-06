import 'package:flutter/material.dart';
import 'package:qintu/constants/app_colors.dart';
import 'package:qintu/constants/app_radii.dart';
import 'package:qintu/constants/app_spacings.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';

/// 火车/高铁段展示组件
class RailwaySegmentCard extends StatelessWidget {
  final RailwaySegment railway;
  final bool isDark;

  const RailwaySegmentCard({
    super.key,
    required this.railway,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(),
          if (railway.departureStation != null || railway.arrivalStation != null) ...[
            const SizedBox(height: AppSpacings.xs),
            _buildStationRoute(),
          ],
          if (railway.viaStations.isNotEmpty)
            _buildViaStations(),
          if (railway.spaces.isNotEmpty)
            _buildSpaces(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    const color = Color(0xFF52C41A);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            railway.trip.isNotEmpty ? railway.trip : railway.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        if (railway.type != null && railway.type!.isNotEmpty) ...[
          const SizedBox(width: AppSpacings.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              railway.type!,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
        const Spacer(),
        if (railway.duration != null)
          Text(
            '${(railway.duration! / 60).round()}分钟',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
            ),
          ),
      ],
    );
  }

  Widget _buildStationRoute() {
    const color = Color(0xFF52C41A);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 16,
          child: Column(
            children: [
              const Icon(Icons.trip_origin, size: 10, color: color),
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
              if (railway.departureStation != null)
                Text(
                  '${railway.departureStation!.time} ${railway.departureStation!.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                  ),
                ),
              const SizedBox(height: 10),
              if (railway.arrivalStation != null)
                Text(
                  '${railway.arrivalStation!.time} ${railway.arrivalStation!.name}',
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

  Widget _buildViaStations() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacings.xs),
      child: Text(
        '途经: ${railway.viaStations.map((s) => '${s.time} ${s.name}').join(" → ")}',
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
        children: railway.spaces.map((space) {
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