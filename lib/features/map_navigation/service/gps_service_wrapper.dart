import '../../../core/gps/gps_service.dart';
import '../../../models/location/lat_lng.dart';

/// ============================================
/// GPS 服务封装
///
/// 封装 core 层 GpsService，提供位置获取能力
/// 位于 service 层，供 provider 层调用
/// ============================================

class GpsServiceWrapper {
  final GpsService _gpsService = GpsService();

  /// 获取缓存的城市名（来自最近一次 GPS 定位）
  String? get lastKnownCity => _gpsService.lastKnownCity;

  /// 获取当前位置坐标
  /// 返回包含 latitude、longitude、accuracy、timestamp、city 的 Map
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    return await _gpsService.getCurrentLocation();
  }

  /// 获取当前位置的 LatLng
  Future<LatLng?> getCurrentLatLng() async {
    return await _gpsService.getCurrentLatLng();
  }

  /// 获取设备上一次缓存的位置（无需发起 GPS 请求）
  /// 用于在 GPS 未就绪时获取城市信息以限定搜索范围
  Future<LatLng?> getLastKnownLocation() async {
    return await _gpsService.getLastKnownLocation();
  }
}

/// 全局单例
final gpsServiceWrapper = GpsServiceWrapper();
