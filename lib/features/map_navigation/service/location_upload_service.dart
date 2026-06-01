import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/location_upload_api.dart';
import '../utils/location_distance_service.dart';
import 'package:qintu/utils/retry_utils.dart';

/// ============================================
/// 位置上传服务
///
/// 包装 LocationUploadApi，提供重试和去抖能力（去抖逻辑委托给 [DistanceThrottle]）
/// ============================================
class LocationUploadService {
  final LocationUploadApi _api = LocationUploadApi();
  final DistanceThrottle _throttle = DistanceThrottle(
    minDistanceMeters: 10.0,
    minInterval: const Duration(seconds: 2),
  );

  /// 上传位置（带重试和去抖）
  Future<void> uploadLocation({
    required double latitude,
    required double longitude,
    int? accuracy,
    int? speed,
    int? bearing,
    int? altitude,
    bool isNavigating = true,
  }) async {
    if (!_throttle.shouldAllow(latitude, longitude)) {
      return;
    }

    await withRetry(
      () => _api.uploadLocation(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        speed: speed,
        bearing: bearing,
        altitude: altitude,
        isNavigating: isNavigating,
      ),
      baseDelay: const Duration(milliseconds: 300),
      errorMessage: '位置上传失败',
    );
  }

  /// 删除后端存储的位置信息
  Future<void> deleteLocation() async {
    await _api.deleteLocation();
    _throttle.reset();
  }
}

final locationUploadServiceProvider = Provider<LocationUploadService>((ref) => LocationUploadService());