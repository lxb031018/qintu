import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/location_distance_service.dart';

/// ============================================
/// 位置共享服务
///
/// 负责距离阈值判断逻辑（委托给 [DistanceThrottle]）。
/// 本服务不调用其他 service，不持有 Timer 等运行时状态。
/// 运行时状态和跨 service 编排由 LocationSharingProvider 负责。
/// ============================================
class LocationSharingService {
  final DistanceThrottle _throttle = DistanceThrottle(
    minDistanceMeters: 3.0,
  );

  /// 是否已至少上传过 1 次
  bool get isSharing => _throttle.hasRecorded;

  /// 判断是否应该上传位置（移动超过阈值）
  bool shouldUpload(double lat, double lng) => _throttle.shouldAllow(lat, lng);

  /// 标记已上传位置（不更新节流内部状态——由 [shouldUpload] 自身管理）
  void markUploaded(double lat, double lng) {
    // no-op: DistanceThrottle 在 shouldAllow 内部已记录
  }

  /// 清除节流状态
  void clearUploaded() => _throttle.reset();

  /// 重置状态
  void reset() => _throttle.reset();
}

final locationSharingServiceProvider = Provider<LocationSharingService>((ref) => LocationSharingService());
