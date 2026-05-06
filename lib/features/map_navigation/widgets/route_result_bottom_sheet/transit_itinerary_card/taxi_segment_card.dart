import 'package:flutter/material.dart';
import 'package:qintu/constants/app_colors.dart';
import 'package:qintu/constants/app_radii.dart';
import 'package:qintu/constants/app_spacings.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';

/// 打车段展示组件
class TaxiSegmentCard extends StatelessWidget {
  final TaxiSegment taxi;
  final bool isDark;

  const TaxiSegmentCard({
    super.key,
    required this.taxi,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = taxi.distance != null
        ? (taxi.distance! >= 1000
            ? '${(taxi.distance! / 1000).toStringAsFixed(1)}km'
            : '${taxi.distance!.toInt()}m')
        : '';
    final priceText = taxi.price != null ? '约¥${taxi.price!.toStringAsFixed(0)}' : '';

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
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF722ED1).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.local_taxi, size: 16, color: Color(0xFF722ED1)),
          ),
          const SizedBox(width: AppSpacings.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '打车',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                  ),
                ),
                if (distanceText.isNotEmpty || priceText.isNotEmpty)
                  Text(
                    [distanceText, priceText].where((s) => s.isNotEmpty).join(' · '),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}