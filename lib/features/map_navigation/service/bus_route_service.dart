import 'package:qintu/features/map_navigation/core/bridge/amap_bus_route_bridge.dart';
import 'package:qintu/features/map_navigation/models/bus_route_models.dart';
import 'package:qintu/models/location/lat_lng.dart';

/// ============================================
/// 公交路线 Service
///
/// 业务逻辑层，封装 AmapBusRouteBridge 调用
/// 不持有 UI 状态，只负责公交路线相关业务逻辑
/// ============================================

class BusRouteService {
  final AmapBusRouteBridge _bridge = AmapBusRouteBridge();

  /// 计算公交路线
  ///
  /// [from] 起点坐标
  /// [to] 终点坐标
  /// [city] 城市区号（用于公交规划）
  /// [cityCode] 城市区号（用于地铁颜色匹配）
  /// [mode] 公交模式，默认推荐模式
  Future<List<BusPath>> calculateBusRoute({
    required LatLng from,
    required LatLng to,
    required String city,
    required String cityCode,
    int mode = BusModeValues.defaultMode,
    int nightFlag = 0,
  }) async {
    return await _bridge.calculateBusRoute(
      from: from,
      to: to,
      city: city,
      cityCode: cityCode,
      mode: mode,
      nightFlag: nightFlag,
    );
  }
}
