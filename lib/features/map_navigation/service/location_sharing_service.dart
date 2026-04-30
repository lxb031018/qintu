import '../utils/location_distance_service.dart';

/// ============================================
/// 位置共享服务
///
/// 负责距离阈值判断逻辑：
/// - 判断是否应该上传位置（移动超过 5 米）
/// - 记录上次上传位置
///
/// 本服务不调用其他 service，不持有运行时状态（Timer 等）。
/// 运行时状态和跨 service 编排由 LocationSharingProvider 负责。
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
    final distance = calculateHaversineDistance(
      lat1: _lastUploadedLat!,
      lng1: _lastUploadedLng!,
      lat2: lat,
      lng2: lng,
    );
    return distance > distanceThreshold;
  }

  /// 标记已上传位置
  void markUploaded(double lat, double lng) {
    _lastUploadedLat = lat;
    _lastUploadedLng = lng;
  }

  /// 删除位置记录
  void clearUploaded() {
    _lastUploadedLat = null;
    _lastUploadedLng = null;
  }

  /// 重置状态
  void reset() {
    _lastUploadedLat = null;
    _lastUploadedLng = null;
  }
}

/// 全局单例
final locationSharingService = LocationSharingService();
