import '../core/location_upload_api.dart';
import '../utils/location_distance_service.dart';

/// ============================================
/// 位置上传服务
///
/// 包装 LocationUploadApi，提供重试和去抖能力
/// ============================================
class LocationUploadService {
  final LocationUploadApi _api = LocationUploadApi();

  /// 上次上传的位置（用于去抖判断）
  double? _lastUploadLat;
  double? _lastUploadLng;
  DateTime? _lastUploadTime;
  static const _uploadDebounceMs = 2000;

  /// 上传位置（带重试和去抖）
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [accuracy] 精度（米）
  /// [speed] 速度（米/秒）
  /// [bearing] 方向（度）
  /// [altitude] 海拔（米）
  /// [isNavigating] 是否在导航中
  Future<void> uploadLocation({
    required double latitude,
    required double longitude,
    int? accuracy,
    int? speed,
    int? bearing,
    int? altitude,
    bool isNavigating = true,
  }) async {
    // 去抖：2秒内同一位置不重复上传
    if (_lastUploadLat != null && _lastUploadLng != null) {
      final distance = _calculateHaversineDistance(
        _lastUploadLat!,
        _lastUploadLng!,
        latitude,
        longitude,
      );
      if (distance < 10 && _lastUploadTime != null) {
        final elapsed = DateTime.now().difference(_lastUploadTime!);
        if (elapsed.inMilliseconds < _uploadDebounceMs) {
          return;
        }
      }
    }

    // 带重试上传
    const maxRetries = 2;
    Exception? lastError;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        await _api.uploadLocation(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
          speed: speed,
          bearing: bearing,
          altitude: altitude,
          isNavigating: isNavigating,
        );
        _lastUploadLat = latitude;
        _lastUploadLng = longitude;
        _lastUploadTime = DateTime.now();
        return;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
        }
      }
    }
    throw lastError ?? Exception('位置上传失败');
  }

  /// 删除后端存储的位置信息
  Future<void> deleteLocation() async {
    await _api.deleteLocation();
    _lastUploadLat = null;
    _lastUploadLng = null;
    _lastUploadTime = null;
  }

  /// 计算两点间的 Haversine 距离（米）
  double _calculateHaversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return calculateHaversineDistance(lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2);
  }
}

/// 全局单例
final locationUploadService = LocationUploadService();