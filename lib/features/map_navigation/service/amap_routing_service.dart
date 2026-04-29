import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
import 'package:qintu/features/map_navigation/core/amap_transit_api.dart';
import 'package:qintu/features/map_navigation/core/poi_api.dart';
import 'package:qintu/utils/logger.dart';
import 'amap_navigation_bridge.dart';

export 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
export 'package:qintu/features/map_navigation/core/amap_transit_api.dart';

/// ============================================
/// 高德地图路线规划服务（统一入口）
///
/// 驾车/步行/骑行 → 通过原生导航 SDK 算路
/// 公共交通 → 保留 Web API
/// ============================================
class AmapRoutingService {
  static final AmapRoutingService _instance = AmapRoutingService._internal();
  factory AmapRoutingService() => _instance;
  AmapRoutingService._internal();

  static AmapRoutingService get instance => _instance;

  final _transitService = AmapTransitApi.instance;
  final _poiApi = PoiApi();

  /// 城市缓存（key: "lat,lng", value: city name）
  final Map<String, String> _cityCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const _cacheExpiry = Duration(minutes: 30);

  /// 规划路线（统一入口）
  ///
  /// [type] 出行方式（驾车/步行/骑行/公交）
  /// [origin] 起点坐标
  /// [destination] 终点坐标
  /// [strategy] 策略（驾车:0-速度最快,1-费用优先,2-距离最短; 公交:0-较快捷,1-较少换乘,2-较少步行,3-最短时间,4-不乘地铁）
  /// [city] 城市名称，用于公共交通路线规划（自动从 origin 坐标逆地理编码获取）
  Future<List<RouteOption>> planRoute({
    required RouteType type,
    required LatLng origin,
    required LatLng destination,
    int strategy = 0,
    String? city,
  }) async {
    // 公共交通路线需要城市参数
    String routeCity = city ?? '';

    switch (type) {
      case RouteType.driving:
      case RouteType.walking:
      case RouteType.riding:
        return _withRetry(() => AmapNavigationBridge.calculateRoute(
          type: type,
          origin: origin,
          destination: destination,
          strategy: strategy,
          multiRoute: true,
        ));
      case RouteType.transit:
        // 如果没有提供城市，尝试从起点坐标逆地理编码获取
        if (routeCity.isEmpty) {
          routeCity = await _getCityFromLocation(origin);
        }
        if (routeCity.isEmpty) {
          throw const RoutingException('公共交通路线需要城市参数，请开启定位权限或手动输入城市');
        }
        return _withRetry(() => _transitService.planTransitRoute(
          origin: origin,
          destination: destination,
          strategy: strategy,
          city: routeCity,
        ));
    }
  }

  /// 带重试的路由规划
  Future<List<RouteOption>> _withRetry(
    Future<List<RouteOption>> Function() request,
  ) async {
    const maxRetries = 2;
    Exception? lastError;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await request();
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
        }
      }
    }
    throw lastError ?? Exception('路由规划失败');
  }

  /// 从坐标逆地理编码获取城市名称（带缓存）
  Future<String> _getCityFromLocation(LatLng location) async {
    final cacheKey = '${location.latitude},${location.longitude}';

    // 检查缓存
    if (_cityCache.containsKey(cacheKey)) {
      final age = DateTime.now().difference(_cacheTimestamps[cacheKey]!);
      if (age < _cacheExpiry) {
        return _cityCache[cacheKey]!;
      }
    }

    try {
      final city = await _poiApi.getCityFromLocation(location) ?? '';
      if (city.isNotEmpty) {
        _cityCache[cacheKey] = city;
        _cacheTimestamps[cacheKey] = DateTime.now();
      }
      return city;
    } catch (e) {
      Logs.ui.warning('获取城市失败: $e');
      return '';
    }
  }
}