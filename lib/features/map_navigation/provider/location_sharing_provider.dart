import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/amap_map_controller.dart';
import '../service/location_sharing_service.dart';

/// ============================================
/// 位置共享状态
///
/// 运行时状态（Timer、上传状态）由 Provider 管理
/// ============================================
class LocationSharingState {
  final bool isSharing;
  final DateTime? lastUploadTime;

  const LocationSharingState({
    this.isSharing = false,
    this.lastUploadTime,
  });

  LocationSharingState copyWith({
    bool? isSharing,
    DateTime? lastUploadTime,
  }) {
    return LocationSharingState(
      isSharing: isSharing ?? this.isSharing,
      lastUploadTime: lastUploadTime ?? this.lastUploadTime,
    );
  }
}

/// ============================================
/// 位置共享 Provider
///
/// 管理位置共享的运行时状态：
/// - Timer? _uploadTimer（定时上传）
/// - isSharing 共享状态
///
/// 业务逻辑委托给 LocationSharingService
/// ============================================
class LocationSharingNotifier extends Notifier<LocationSharingState> {
  Timer? _uploadTimer;
  AmapMapController? _mapController;
  final _service = locationSharingService;

  @override
  LocationSharingState build() => const LocationSharingState();

  /// 设置地图控制器
  void setMapController(AmapMapController controller) {
    _mapController = controller;
  }

  /// 启动位置共享
  Future<void> startSharing() async {
    if (state.isSharing) return;

    state = state.copyWith(isSharing: true);

    // 首次上传
    await _uploadOnce();

    // 启动定时检查
    _uploadTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tryUpload();
    });
  }

  /// 停止位置共享
  void stopSharing() {
    _uploadTimer?.cancel();
    _uploadTimer = null;
    state = state.copyWith(isSharing: false);
    _service.deleteLocation();
    _service.reset();
  }

  /// 立即上传一次当前位置
  Future<void> _uploadOnce() async {
    if (_mapController == null) return;

    try {
      final location = await _mapController!.getCurrentLocation();
      if (location == null) return;

      final lat = location['latitude'] as double;
      final lng = location['longitude'] as double;

      await _service.uploadLocation(
        lat: lat,
        lng: lng,
        accuracy: (location['accuracy'] as double?)?.toInt(),
        speed: (location['speed'] as double?)?.toInt(),
      );

      state = state.copyWith(lastUploadTime: DateTime.now());
    } catch (e) {
      // 上传失败由 service 处理
    }
  }

  /// 尝试上传位置（仅当移动超过 5 米时）
  Future<void> _tryUpload() async {
    if (_mapController == null || !state.isSharing) return;

    try {
      final location = await _mapController!.getCurrentLocation();
      if (location == null) return;

      final lat = location['latitude'] as double;
      final lng = location['longitude'] as double;

      if (!_service.shouldUpload(lat, lng)) return;

      await _service.uploadLocation(
        lat: lat,
        lng: lng,
        accuracy: (location['accuracy'] as double?)?.toInt(),
        speed: (location['speed'] as double?)?.toInt(),
      );

      state = state.copyWith(lastUploadTime: DateTime.now());
    } catch (e) {
      // 上传失败由 service 处理
    }
  }
}

/// Provider 导出
final locationSharingProvider =
    NotifierProvider<LocationSharingNotifier, LocationSharingState>(
  LocationSharingNotifier.new,
);