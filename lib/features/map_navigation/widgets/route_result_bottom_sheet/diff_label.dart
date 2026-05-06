import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../models/map_overlay_models.dart';

/// 路线对比差异标签
///
/// 显示"快X分钟"、"少Xkm"等对比差异标签
class RouteDiffLabel extends StatelessWidget {
  final RouteResultItem route;
  final bool isDark;

  const RouteDiffLabel({
    super.key,
    required this.route,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];

    if (route.timeDiff != null) {
      final absMin = (route.timeDiff!.abs() / 60).round();
      if (route.timeDiff! < 0) {
        parts.add('快$absMin分钟');
      } else {
        parts.add('慢$absMin分钟');
      }
    }

    if (route.distanceDiff != null) {
      final absKm = (route.distanceDiff!.abs() / 1000).toStringAsFixed(1);
      if (route.distanceDiff! < 0) {
        parts.add('少${absKm}km');
      } else {
        parts.add('多${absKm}km');
      }
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join(' · '),
      style: TextStyle(
        fontSize: 10,
        color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
      ),
    );
  }
}
