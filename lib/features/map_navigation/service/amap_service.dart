import 'dart:math' as math;

/// 高德地图服务 - 提供工具方法

class AmapService {
  static final AmapService _instance = AmapService._internal();
  factory AmapService() => _instance;
  AmapService._internal();

  static AmapService get instance => _instance;

  /// 计算两点之间的距离（米）
  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    const double earthRadius = 6371000;
    final double dLat = _toRadians(endLat - startLat);
    final double dLng = _toRadians(endLng - startLng);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(startLat)) * math.cos(_toRadians(endLat)) * math.sin(dLng / 2) * math.sin(dLng / 2);
    return earthRadius * 2 * math.asin(math.sqrt(a));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
