import 'package:flutter/material.dart';
import '../color/subway_color_helper.dart';
import '../../../../../../features/map_navigation/models/bus_route_models.dart';

/// ============================================
/// 公交/地铁标签组件
///
/// 显示公交或地铁线路标签，包含线路名称和站点数量
/// 根据类型自动选择颜色（地铁使用各地铁城市配色）
/// ============================================
class TransitTag extends StatelessWidget {
  final String name;
  final int stationCount;
  final TransitSegmentType type;
  final String? cityCode;

  const TransitTag({
    super.key,
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