import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_radii.dart';
import '../../../../constants/app_spacings.dart';
import '../../models/amap_routing_models.dart';
import '../../models/map_overlay_models.dart';
import '../../models/bus_route_models.dart';
import 'transit_itinerary_card/color/subway_color_helper.dart';

class TransitRouteSummaryCard extends StatelessWidget {
  final RouteResultItem route;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDark;

  const TransitRouteSummaryCard({
    super.key,
    required this.route,
    required this.isSelected,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final segments = route.transitSegments ?? [];

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacings.xs),
            _buildSegmentTagFlow(segments),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (isSelected)
          Container(
            width: 3,
            height: 20,
            margin: const EdgeInsets.only(right: AppSpacings.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        Text(
          '约${route.formattedDuration}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextColor : AppColors.textColor,
          ),
        ),
        const Spacer(),
        if (route.tolls != null && route.tolls! > 0) ...[
          Text(
            '¥${route.tolls!.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: AppSpacings.sm),
        ],
        if (route.transferCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkDividerColor
                  : AppColors.grey200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '换乘${route.transferCount}次',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
              ),
            ),
          ),
        if (isSelected) ...[
          const SizedBox(width: AppSpacings.xs),
          const Icon(Icons.check_circle, size: 18, color: AppColors.primaryColor),
        ],
      ],
    );
  }

  Widget _buildSegmentTagFlow(List<BusTransitSegment> segments) {
    final tags = <Widget>[];

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];

      if (seg.hasWalking) {
        tags.add(_WalkTag(distance: seg.distance, isDark: isDark));
        if (i < segments.length - 1) {
          tags.add(const _ArrowSeparator());
        }
      }

      if (seg.hasTransit) {
        tags.add(_TransitTag(
          name: seg.lineName ?? '',
          stationCount: seg.stationCount ?? 0,
          type: seg.type,
          cityCode: route.cityCode,
        ));
        if (i < segments.length - 1) {
          tags.add(const _ArrowSeparator());
        }
      }

      if (seg.hasTaxi) {
        tags.add(_TaxiTag(isDark: isDark));
        if (i < segments.length - 1) {
          tags.add(const _ArrowSeparator());
        }
      }
    }

    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: tags,
    );
  }
}

class _WalkTag extends StatelessWidget {
  final double distance;
  final bool isDark;

  const _WalkTag({required this.distance, required this.isDark});

  String get _distanceText {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}公里';
    }
    return '${distance.toInt()}米';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkDividerColor : AppColors.grey200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_walk,
            size: 12,
            color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
          ),
          const SizedBox(width: 2),
          Text(
            _distanceText,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransitTag extends StatelessWidget {
  final String name;
  final int stationCount;
  final TransitSegmentType type;
  final String? cityCode;

  const _TransitTag({
    required this.name,
    required this.stationCount,
    required this.type,
    this.cityCode,
  });

  Color get _color {
    if (type == TransitSegmentType.subway) {
      return SubwayColorHelper.getSubwayColor(
        name,
        cityCode,
        defaultColor: const Color(0xFFFF4D4F),
      );
    }
    return const Color(0xFF1890FF);
  }

  IconData get _icon {
    switch (type) {
      case TransitSegmentType.subway:
        return Icons.subway;
      case TransitSegmentType.bus:
        return Icons.directions_bus;
      default:
        return Icons.directions_bus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '·$stationCount站',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxiTag extends StatelessWidget {
  final bool isDark;

  const _TaxiTag({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF722ED1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_taxi, size: 12, color: Colors.white),
          SizedBox(width: 2),
          Text(
            '打车',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowSeparator extends StatelessWidget {
  const _ArrowSeparator();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.arrow_forward,
      size: 12,
      color: AppColors.grey400,
    );
  }
}
