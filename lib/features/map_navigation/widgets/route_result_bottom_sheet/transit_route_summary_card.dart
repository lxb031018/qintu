import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_radii.dart';
import '../../../../constants/app_spacings.dart';
import '../../models/map_overlay_models.dart';
import '../../models/bus_route_models.dart';
import 'transit_itinerary_card/shared/segment_tag_flow_builder.dart';

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
    final tags = SegmentTagFlowBuilder(
      segments: segments,
      isDark: isDark,
    ).build();

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