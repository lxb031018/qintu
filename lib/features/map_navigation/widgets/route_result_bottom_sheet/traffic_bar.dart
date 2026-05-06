import 'package:flutter/material.dart';
import '../../models/map_overlay_models.dart';

/// 路况摘要条
///
/// 驾车模式下选中路线的路况分段彩色条
/// 显示畅通(绿)/缓行(黄)/拥堵(红)的分段比例
class RouteTrafficBar extends StatelessWidget {
  final RouteResultItem route;

  const RouteTrafficBar({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final statuses = route.trafficStatuses;
    if (statuses == null || statuses.isEmpty) return const SizedBox.shrink();

    int smoothCount = 0;
    int slowCount = 0;
    int jamCount = 0;

    for (final s in statuses) {
      final status = s['status'] as String? ?? '';
      if (status == '畅通') {
        smoothCount++;
      } else if (status == '缓行') {
        slowCount++;
      } else if (status == '拥堵' || status == '严重拥堵') {
        jamCount++;
      }
    }

    if (smoothCount + slowCount + jamCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          height: 4,
          child: Row(
            children: [
              if (smoothCount > 0)
                Expanded(
                  flex: smoothCount,
                  child: Container(color: Color(RouteColors.trafficSmooth)),
                ),
              if (slowCount > 0)
                Expanded(
                  flex: slowCount,
                  child: Container(color: Color(RouteColors.trafficSlow)),
                ),
              if (jamCount > 0)
                Expanded(
                  flex: jamCount,
                  child: Container(color: Color(RouteColors.trafficJam)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
