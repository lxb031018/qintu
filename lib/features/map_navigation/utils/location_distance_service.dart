import 'dart:math' as math;

/// 地球半径（米）
const double _earthRadius = 6371000;

/// 计算两点间的 Haversine 距离（米）
///
/// [lat1] 起点纬度
/// [lng1] 起点经度
/// [lat2] 终点纬度
/// [lng2] 终点经度
double calculateHaversineDistance({
  required double lat1,
  required double lng1,
  required double lat2,
  required double lng2,
}) {
  final double dLat = _toRadians(lat2 - lat1);
  final double dLng = _toRadians(lng2 - lng1);
  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return _earthRadius * 2 * math.asin(math.sqrt(a));
}

double _toRadians(double degrees) => degrees * math.pi / 180;