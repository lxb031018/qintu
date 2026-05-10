import 'package:flutter/material.dart';
import '../../../../../../constants/app_colors.dart';

/// ============================================
/// 步行标签组件
///
/// 显示灰色的步行距离标签
/// ============================================
class WalkTag extends StatelessWidget {
  final double distance;
  final bool isDark;

  const WalkTag({
    super.key,
    required this.distance,
    required this.isDark,
  });

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