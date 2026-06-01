import 'package:qintu/models/location/lat_lng.dart';

/// 计算两点间的 Haversine 距离（米）
///
/// 委托给 [LatLng.distanceTo] 以保持单一实现。
double calculateHaversineDistance({
  required double lat1,
  required double lng1,
  required double lat2,
  required double lng2,
}) {
  return LatLng(lat1, lng1).distanceTo(LatLng(lat2, lng2));
}

/// 距离 + 时间双重节流：移动距离 < [minDistanceMeters] 或距离够但时间
/// 间隔 < [minIntervalMs] 时返回 false，否则返回 true 并更新内部状态
///
/// 用于位置共享/上传的"防抖"策略：避免重复上传相近位置
class DistanceThrottle {
  final double minDistanceMeters;
  final Duration minInterval;

  double? _lastLat;
  double? _lastLng;
  DateTime? _lastTime;

  DistanceThrottle({
    this.minDistanceMeters = 3.0,
    this.minInterval = const Duration(seconds: 2),
  });

  /// 是否应允许本次上报。返回 true 时内部状态会更新。
  bool shouldAllow(double lat, double lng) {
    final now = DateTime.now();

    // 首次上报
    if (_lastLat == null || _lastLng == null || _lastTime == null) {
      _record(lat, lng, now);
      return true;
    }

    // 距离检查
    final distance = calculateHaversineDistance(
      lat1: _lastLat!,
      lng1: _lastLng!,
      lat2: lat,
      lng2: lng,
    );
    if (distance < minDistanceMeters) {
      return false;
    }

    // 时间检查
    if (now.difference(_lastTime!) < minInterval) {
      return false;
    }

    _record(lat, lng, now);
    return true;
  }

  void _record(double lat, double lng, DateTime time) {
    _lastLat = lat;
    _lastLng = lng;
    _lastTime = time;
  }

  void reset() {
    _lastLat = null;
    _lastLng = null;
    _lastTime = null;
  }

  /// 是否已记录过至少一次位置
  bool get hasRecorded => _lastLat != null;
}
