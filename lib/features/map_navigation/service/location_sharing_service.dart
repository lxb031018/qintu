import 'location_upload_service.dart';
import 'location_distance_service.dart';

/// ============================================
/// 位置共享服务
///
/// 负责将本设备 GPS 位置自动上传到后端，供绑定者查询
///
/// 上传策略：
/// - 每秒获取一次 GPS
/// - 仅当与上次上传位置距离超过 5 米时才上传
///
/// 本服务不持有运行时状态（Timer、MapController 等），
/// 运行时状态由 LocationSharingProvider 管理
/// ============================================
class LocationSharingService {
  /// 上次上传的位置（用于距离判断）
  double? _lastUploadedLat;
  double? _lastUploadedLng;

  /// 距离阈值（米），移动超过此距离才上传
  static const double distanceThreshold = 5.0;

  /// 是否正在共享（上次上传位置不为空）
  bool get isSharing => _lastUploadedLat != null;

  /// 判断是否应该上传位置（移动超过阈值）
  bool shouldUpload(double lat, double lng) {
    if (_lastUploadedLat == null || _lastUploadedLng == null) {
      return true;
    }
    final distance = _calculateHaversineDistance(
      _lastUploadedLat!,
      _lastUploadedLng!,
      lat,
      lng,
    );
    return distance > distanceThreshold;
  }

  /// 上传位置（业务逻辑）
  Future<void> uploadLocation({
    required double lat,
    required double lng,
    int? accuracy,
    int? speed,
  }) async {
    await locationUploadService.uploadLocation(
      latitude: lat,
      longitude: lng,
      accuracy: accuracy,
      speed: speed,
    );
    _lastUploadedLat = lat;
    _lastUploadedLng = lng;
  }

  /// 删除后端存储的位置信息
  Future<void> deleteLocation() async {
    await locationUploadService.deleteLocation();
    _lastUploadedLat = null;
    _lastUploadedLng = null;
  }

  /// 重置状态
  void reset() {
    _lastUploadedLat = null;
    _lastUploadedLng = null;
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
final locationSharingService = LocationSharingService();