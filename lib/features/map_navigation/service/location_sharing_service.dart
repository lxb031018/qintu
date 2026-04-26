import 'dart:async';
import 'dart:math' as math;
import '../core/amap_map_controller.dart';
import '../core/location_upload_api.dart';
import 'package:qintu/utils/logger.dart';

/// ============================================
/// 位置共享服务
///
/// 负责将本设备 GPS 位置自动上传到后端，供绑定者查询
///
/// 上传策略：
/// - 每秒获取一次 GPS
/// - 仅当与上次上传位置距离超过 5 米时才上传
/// - GPS 静止时自动停止上传（节省资源）
/// ============================================

class LocationSharingService {
  Timer? _uploadTimer;
  AmapMapController? _mapController;

  /// 上次上传的位置（用于距离判断）
  double? _lastUploadedLat;
  double? _lastUploadedLng;

  /// 是否正在上传
  bool get isSharing => _uploadTimer != null;

  /// 设置地图控制器（用于获取 GPS）
  void setMapController(AmapMapController controller) {
    _mapController = controller;
  }

  /// 启动定时上传
  void startSharing() {
    if (_uploadTimer != null) return; // 已在运行

    Logs.location.info('LocationSharingService: 启动位置共享');

    // 立即上传一次位置（每次重启+开启定位后都需要上报）
    _uploadOnce();

    // 启动定时检查（只有移动超过 5 米才继续上传）
    _uploadTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await _tryUpload();
    });
  }

  /// 停止定时上传
  void stopSharing() {
    _uploadTimer?.cancel();
    _uploadTimer = null;
    _lastUploadedLat = null;
    _lastUploadedLng = null;
    Logs.location.info('LocationSharingService: 停止位置共享');
  }

  /// 立即上传一次当前位置（不带距离判断，用于重启后首次上报）
  Future<void> _uploadOnce() async {
    if (_mapController == null) {
      Logs.location.warning('LocationSharingService: mapController 未设置，跳过首次上传');
      return;
    }

    try {
      final location = await _mapController!.getCurrentLocation();
      if (location == null) {
        Logs.location.warning('LocationSharingService: 获取定位失败，跳过首次上传');
        return;
      }

      final lat = location['latitude'] as double;
      final lng = location['longitude'] as double;

      await _uploadLocation(lat, lng, location);
      _lastUploadedLat = lat;
      _lastUploadedLng = lng;
      Logs.location.info('LocationSharingService: 首次位置已上报');
    } catch (e) {
      Logs.location.warning('位置上传失败: $e');
    }
  }

  /// 尝试上传位置（仅当移动超过 5 米时真正上传）
  Future<void> _tryUpload() async {
    if (_mapController == null) return;

    try {
      final location = await _mapController!.getCurrentLocation();
      if (location == null) return;

      final lat = location['latitude'] as double;
      final lng = location['longitude'] as double;

      // 判断是否移动超过 5 米
      if (_lastUploadedLat != null && _lastUploadedLng != null) {
        final distance = _calculateHaversineDistance(
          _lastUploadedLat!,
          _lastUploadedLng!,
          lat,
          lng,
        );

        if (distance <= 5) {
          // 静止，不上传
          return;
        }
      }

      // 移动了，上传到后端
      await _uploadLocation(lat, lng, location);

      _lastUploadedLat = lat;
      _lastUploadedLng = lng;
    } catch (e) {
      Logs.location.warning('位置上传失败: $e');
    }
  }

  /// 上传位置到后端
  Future<void> _uploadLocation(
    double lat,
    double lng,
    Map<String, dynamic> location,
  ) async {
    try {
      final api = LocationUploadApi();
      await api.uploadLocation(
        latitude: lat,
        longitude: lng,
        accuracy: (location['accuracy'] as double?)?.toInt(),
        speed: (location['speed'] as double?)?.toInt(),
      );
      Logs.location.debug('位置已上传: lat=$lat, lng=$lng');
    } catch (e) {
      Logs.location.warning('上传位置API失败: $e');
    }
  }

  /// 计算两点间的 Haversine 距离（米）
  double _calculateHaversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final R = 6371000.0; // 地球半径（米）
    final dLat = math.pi / 180 * (lat2 - lat1);
    final dLng = math.pi / 180 * (lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(math.pi / 180 * lat1) *
            math.cos(math.pi / 180 * lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }
}

/// 全局单例
final locationSharingService = LocationSharingService();
