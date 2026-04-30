import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
import 'package:qintu/features/map_navigation/utils/location_distance_service.dart';
import 'package:qintu/features/map_navigation/core/amap_bus_search_bridge.dart';
import 'package:qintu/features/map_navigation/core/poi_api.dart';
import 'package:qintu/utils/logger.dart';
import 'amap_navigation_bridge.dart';

export 'package:qintu/features/map_navigation/models/amap_routing_models.dart';

/// ============================================
/// 高德地图路线规划服务（统一入口）
///
/// 驾车/步行/骑行 → 通过原生导航 SDK 算路
/// 公共交通 → 原生 RouteSearchV2.calculateBusRouteAsyn
/// ============================================
class AmapRoutingService {
  static final AmapRoutingService _instance = AmapRoutingService._internal();
  factory AmapRoutingService() => _instance;
  AmapRoutingService._internal();

  static AmapRoutingService get instance => _instance;

  final _poiApi = PoiApi();

  /// 城市缓存（key: "lat,lng", value: city name or code）
  final Map<String, String> _cityCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const _cacheExpiry = Duration(minutes: 30);

  /// 规划路线（统一入口）
  ///
  /// [type] 出行方式（驾车/步行/骑行/公交）
  /// [origin] 起点坐标
  /// [destination] 终点坐标
  /// [strategy] 策略（驾车:0-速度最快,1-费用优先,2-距离最短; 公交:0-较快捷,1-较少换乘,2-较少步行,3-最短时间,4-不乘地铁）
  /// [city] 城市区号（电话区号如 "010"、"0771"），用于公共交通路线规划（自动从 origin 坐标逆地理编码获取）
  Future<List<RouteOption>> planRoute({
    required RouteType type,
    required LatLng origin,
    required LatLng destination,
    int strategy = 0,
    String? city,
  }) async {
    // 公共交通路线需要城市区号（如 "010"、"0771"），不能是城市名
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
        if (routeCity.isEmpty) {
          routeCity = await _getCityCodeFromLocation(origin);
        }
        if (routeCity.isEmpty) {
          throw const RoutingException('公共交通路线需要城市区号，请开启定位权限或手动输入城市区号（如 010）');
        }
        return _withRetry(() async {
          final result = await AmapBusSearchBridge.planTransitRoute(
            origin: origin,
            destination: destination,
            city: routeCity,
            mode: strategy,
          );
          if (result.isNotEmpty) {
            final supplemented = <RouteOption>[];
            for (final r in result) {
              supplemented.add(await _supplementTransitWalkSegments(r));
            }
            return supplemented;
          }
          return result;
        });
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

  /// 从坐标逆地理编码获取城市区号（电话区号，如 "010"、"0771"，带缓存）
  ///
  /// BusRouteQuery 的 city 参数要求城市区号，不能是城市名称
  Future<String> _getCityCodeFromLocation(LatLng location) async {
    final cacheKey = 'citycode_${location.latitude},${location.longitude}';

    if (_cityCache.containsKey(cacheKey)) {
      final age = DateTime.now().difference(_cacheTimestamps[cacheKey]!);
      if (age < _cacheExpiry) {
        return _cityCache[cacheKey]!;
      }
    }

    try {
      final citycode = await _poiApi.getCityCodeFromLocation(location) ?? '';
      if (citycode.isNotEmpty) {
        _cityCache[cacheKey] = citycode;
        _cacheTimestamps[cacheKey] = DateTime.now();
      }
      return citycode;
    } catch (e) {
      Logs.ui.warning('获取城市区号失败: $e');
      return '';
    }
  }

  /// 补充公共交通路线的首端和末端步行段（使用步行 SDK 获取实际路线）
  ///
  /// AMap RouteSearchV2 的 BusStepV2.getWalk() 不包含首端步行（起点→首站）
  /// 和末端步行（末站→终点），本方法用导航 SDK 补充这两段实际路线，
  /// 始终保留所有原始 transit segment，不会因补充而丢失公交/地铁路段
  Future<RouteOption> _supplementTransitWalkSegments(RouteOption route) async {
    final segments = route.transitSegments;
    if (segments == null || segments.isEmpty) {
      return route;
    }

    final origin = route.userOrigin;
    final dest = route.userDest;
    if (origin == null || dest == null) {
      return route;
    }

    final firstSeg = segments.first;
    final lastSeg = segments.last;

    // 获取首站和末站坐标（来自 segment.points）
    final firstTransitStop = firstSeg.points.isNotEmpty ? firstSeg.points.first : null;
    final lastTransitStop = lastSeg.points.isNotEmpty ? lastSeg.points.last : null;

    // 如果首站/末站坐标无效，跳过补充
    if (firstTransitStop == null || lastTransitStop == null) {
      return route;
    }

    List<LatLng>? firstWalkPoints;
    List<LatLng>? lastWalkPoints;

    // 补充首端步行（起点 → 首站）
    try {
      final walkRoutes = await AmapNavigationBridge.calculateRoute(
        type: RouteType.walking,
        origin: origin,
        destination: firstTransitStop,
        multiRoute: false,
      );
      if (walkRoutes.isNotEmpty && walkRoutes.first.points.isNotEmpty) {
        firstWalkPoints = walkRoutes.first.points;
        Logs.ui.info('✅ 首端步行路线已补充: ${firstWalkPoints.length} 点');
      }
    } catch (e) {
      Logs.ui.warning('⚠️ 首端步行路线获取失败: $e');
    }

    // 补充末端步行（末站 → 终点）
    try {
      final walkRoutes = await AmapNavigationBridge.calculateRoute(
        type: RouteType.walking,
        origin: lastTransitStop,
        destination: dest,
        multiRoute: false,
      );
      if (walkRoutes.isNotEmpty && walkRoutes.first.points.isNotEmpty) {
        lastWalkPoints = walkRoutes.first.points;
        Logs.ui.info('✅ 末端步行路线已补充: ${lastWalkPoints.length} 点');
      }
    } catch (e) {
      Logs.ui.warning('⚠️ 末端步行路线获取失败: $e');
    }

    // 如果两端步行都未能获取，不做处理
    if (firstWalkPoints == null && lastWalkPoints == null) {
      return route;
    }

    // 始终在首尾添加步行段，保留所有原始 transit 段
    final newSegments = <TransitSegment>[];

    if (firstWalkPoints != null && firstWalkPoints.length > 1) {
      newSegments.add(TransitSegment(
        lines: const [],
        walkingDistance: _calcDistance(firstWalkPoints).round(),
        points: firstWalkPoints,
      ));
    }

    // 始终保留所有原始 segments
    newSegments.addAll(segments);

    if (lastWalkPoints != null && lastWalkPoints.length > 1) {
      newSegments.add(TransitSegment(
        lines: const [],
        walkingDistance: _calcDistance(lastWalkPoints).round(),
        points: lastWalkPoints,
      ));
    }

    // 重建 allPoints
    final newAllPoints = <LatLng>[];
    for (final seg in newSegments) {
      newAllPoints.addAll(seg.points);
    }

    return RouteOption(
      routeId: route.routeId,
      distance: route.distance,
      duration: route.duration,
      strategy: route.strategy,
      tolls: route.tolls,
      points: newAllPoints,
      routeType: route.routeType,
      transitSegments: newSegments,
      userOrigin: route.userOrigin,
      userDest: route.userDest,
    );
  }

  /// 计算一组坐标的总距离（米）
  double _calcDistance(List<LatLng> points) {
    if (points.length < 2) return 0;
    double dist = 0;
    for (int i = 0; i < points.length - 1; i++) {
      dist += calculateHaversineDistance(
        lat1: points[i].latitude,
        lng1: points[i].longitude,
        lat2: points[i + 1].latitude,
        lng2: points[i + 1].longitude,
      );
    }
    return dist;
  }
}