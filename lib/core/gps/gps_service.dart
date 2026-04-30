import 'package:flutter/services.dart';
import '../../models/location/lat_lng.dart';
import '../constants/platform_channels.dart';

/// GPS 位置服务
///
/// 职责：获取用户当前位置（封装 Platform Channel 调用）
class GpsService {
  static const _channel = MethodChannel(PlatformChannels.mapControl);

  /// 缓存的上一次城市名
  String? _lastKnownCity;

  /// 获取缓存的城市名（来自最近一次 GPS 定位）
  String? get lastKnownCity => _lastKnownCity;

  /// 获取当前位置坐标
  /// 返回包含 latitude、longitude、accuracy、timestamp、city 的 Map
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getCurrentLocation');
      if (result != null) {
        _lastKnownCity = result['city'] as String? ?? '';
        return {
          'latitude': result['latitude'] as double,
          'longitude': result['longitude'] as double,
          'accuracy': result['accuracy'] as double,
          'timestamp': result['timestamp'] as int,
          'city': _lastKnownCity,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取当前位置的 LatLng
  Future<LatLng?> getCurrentLatLng() async {
    final location = await getCurrentLocation();
    if (location != null) {
      return LatLng(
        location['latitude'] as double,
        location['longitude'] as double,
      );
    }
    return null;
  }

  /// 获取设备上一次缓存的位置（无需发起 GPS 请求）
  /// 用于在 GPS 未就绪时获取城市信息以限定搜索范围
  Future<LatLng?> getLastKnownLocation() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getLastKnownLocation');
      if (result != null) {
        _lastKnownCity = result['city'] as String? ?? '';
        return LatLng(
          result['latitude'] as double,
          result['longitude'] as double,
        );
      }
    } catch (e) { }
    return null;
  }
}