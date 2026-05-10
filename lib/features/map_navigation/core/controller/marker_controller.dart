import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/platform_channels.dart';

class MarkerController {
  static const _channel = MethodChannel(PlatformChannels.mapControl);

  Future<bool> setRouteMarkers({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String? startLabel,
    String? endLabel,
  }) async {
    try {
      debugPrint('🗺️ [Flutter] setRouteMarkers: start=($startLat,$startLng), end=($endLat,$endLng)');

      final result = await _channel.invokeMethod<bool>('setRouteMarkers', {
        'startLat': startLat,
        'startLng': startLng,
        'endLat': endLat,
        'endLng': endLng,
        'startLabel': startLabel ?? '起点',
        'endLabel': endLabel ?? '终点',
      });

      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 设置路线标记失败: $e');
      return false;
    }
  }

  Future<bool> clearRouteMarkers() async {
    try {
      final result = await _channel.invokeMethod<bool>('clearRouteMarkers');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 清除路线标记失败: $e');
      return false;
    }
  }

  Future<bool> showSingleMarker({
    required double lat,
    required double lng,
    required bool isStart,
    String? label,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('showSingleMarker', {
        'lat': lat,
        'lng': lng,
        'isStart': isStart,
        'label': label ?? (isStart ? '起点' : '终点'),
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 显示单条路线标记失败: $e');
      return false;
    }
  }

  Future<bool> showStationMarkers(List<Map<String, dynamic>> stations) async {
    try {
      debugPrint('🗺️ [Flutter] showStationMarkers: ${stations.length} 个站点');
      final result = await _channel.invokeMethod<bool>('showStationMarkers', {
        'stations': stations,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 显示站点标记失败: $e');
      return false;
    }
  }

  Future<bool> clearStationMarkers() async {
    try {
      final result = await _channel.invokeMethod<bool>('clearStationMarkers');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 清除站点标记失败: $e');
      return false;
    }
  }

  Future<bool> clearSingleMarker(bool isStart) async {
    try {
      final result = await _channel.invokeMethod<bool>('clearSingleMarker', {
        'isStart': isStart,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 清除单条路线标记失败: $e');
      return false;
    }
  }
}