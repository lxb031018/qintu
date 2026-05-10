import 'package:flutter/services.dart';
import 'package:qintu/core/constants/platform_channels.dart';
import 'package:qintu/features/map_navigation/models/bus_route_models.dart';
import 'package:qintu/models/location/lat_lng.dart';
import 'package:qintu/utils/logger.dart';

/// ============================================
/// 高德公交路线规划桥接层
///
/// 通过 Platform Channel 调用 Android 原生公交路线规划 SDK
/// ============================================
class AmapBusRouteBridge {
  static const _channelName = PlatformChannels.routeSearch;

  static const _channel = MethodChannel(_channelName);

  /// 计算公交路线
  ///
  /// [from] 起点坐标
  /// [to] 终点坐标
  /// [city] 城市名称（用于公交规划）
  /// [cityCode] 城市区号（用于地铁颜色匹配）
  /// [mode] 公交模式，默认推荐模式
  /// [nightFlag] 夜班公交标志，0-不包含，1-仅夜班，2-包含
  Future<List<BusPath>> calculateBusRoute({
    required LatLng from,
    required LatLng to,
    required String city,
    required String cityCode,
    int mode = BusModeValues.defaultMode,
    int nightFlag = 0,
  }) async {
    try {
      final result = await _channel.invokeMethod('calculateBusRoute', {
        'fromLat': from.latitude,
        'fromLng': from.longitude,
        'toLat': to.latitude,
        'toLng': to.longitude,
        'city': city,
        'cityCode': cityCode,
        'mode': mode,
        'nightFlag': nightFlag,
      });

      if (result == null) return [];

      final routes = result as List<dynamic>;
      return routes.map((r) => BusPath.fromMap(r as Map<dynamic, dynamic>)).toList();
    } on PlatformException catch (e) {
      Logs.ui.warning('Bus route search failed: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      Logs.ui.warning('Bus route search unexpected error: $e');
      rethrow;
    }
  }
}
