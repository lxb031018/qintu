import 'dart:async';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
import 'package:qintu/features/map_navigation/models/navigation_models.dart';
import 'package:qintu/features/map_navigation/core/amap_navigation_bridge.dart';
import 'package:qintu/features/map_navigation/core/route_search_bridge.dart';
import 'package:qintu/features/map_navigation/core/poi_api.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/utils/retry_utils.dart';

export 'package:qintu/features/map_navigation/models/amap_routing_models.dart';

class AmapRoutingService {
  static final AmapRoutingService _instance = AmapRoutingService._internal();
  factory AmapRoutingService() => _instance;
  AmapRoutingService._internal();

  final _poiApi = PoiApi();

  final Map<String, String> _cityCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const _cacheExpiry = Duration(minutes: 30);

  Future<List<RouteOption>> planRoute({
    required RouteType type,
    required LatLng origin,
    required LatLng destination,
    int strategy = 0,
    String? city,
    int maxTrans = 3,
    int alternativeRoute = 1,
    String? time,
    String? timeType,
    String? destCity,
  }) async {
    String routeCity = city ?? '';

    switch (type) {
      case RouteType.driving:
      case RouteType.walking:
      case RouteType.riding:
      case RouteType.eleBike:
        return withRetry(() => AmapRouteSearchBridge.calculateRoute(
          type: type,
          origin: origin,
          destination: destination,
          strategy: strategy,
        ));
      case RouteType.transit:
        if (routeCity.isEmpty) {
          routeCity = await _getCityCodeFromLocation(origin);
        }
        if (routeCity.isEmpty) {
          throw const RoutingException('公共交通路线需要城市区号，请开启定位权限或手动输入城市区号（如 010）');
        }
        return withRetry(() async {
          final result = await AmapRouteSearchBridge.calculateRoute(
            type: type,
            origin: origin,
            destination: destination,
            strategy: strategy,
            city: routeCity,
            maxTrans: maxTrans,
            alternativeRoute: alternativeRoute,
            time: time,
            timeType: timeType,
            destCity: destCity,
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

    LatLng? firstTransitStop;
    for (final seg in segments) {
      if (seg.hasTransit && seg.points.isNotEmpty) {
        firstTransitStop = seg.points.first;
        break;
      }
    }

    LatLng? lastTransitStop;
    for (final seg in segments.reversed) {
      if (seg.hasTransit && seg.points.isNotEmpty) {
        lastTransitStop = seg.points.last;
        break;
      }
    }

    if (firstTransitStop == null || lastTransitStop == null) {
      return route;
    }

    List<LatLng>? firstWalkPoints;
    List<LatLng>? lastWalkPoints;

    try {
      final walkRoutes = await AmapRouteSearchBridge.calculateRoute(
        type: RouteType.walking,
        origin: origin,
        destination: firstTransitStop,
      );
      if (walkRoutes.isNotEmpty && walkRoutes.first.points.isNotEmpty) {
        firstWalkPoints = walkRoutes.first.points;
        Logs.ui.info('✅ 首端步行路线已补充: ${firstWalkPoints.length} 点');
      }
    } catch (e) {
      Logs.ui.warning('⚠️ 首端步行路线获取失败: $e');
    }

    try {
      final walkRoutes = await AmapRouteSearchBridge.calculateRoute(
        type: RouteType.walking,
        origin: lastTransitStop,
        destination: dest,
      );
      if (walkRoutes.isNotEmpty && walkRoutes.first.points.isNotEmpty) {
        lastWalkPoints = walkRoutes.first.points;
        Logs.ui.info('✅ 末端步行路线已补充: ${lastWalkPoints.length} 点');
      }
    } catch (e) {
      Logs.ui.warning('⚠️ 末端步行路线获取失败: $e');
    }

    if (firstWalkPoints == null && lastWalkPoints == null) {
      return route;
    }

    final newSegments = <TransitSegment>[];

    if (firstWalkPoints != null && firstWalkPoints.length > 1) {
      newSegments.add(TransitSegment(
        lines: const [],
        walkingDistance: _calcDistance(firstWalkPoints).round(),
        points: firstWalkPoints,
      ));
    }

    newSegments.addAll(segments);

    if (lastWalkPoints != null && lastWalkPoints.length > 1) {
      newSegments.add(TransitSegment(
        lines: const [],
        walkingDistance: _calcDistance(lastWalkPoints).round(),
        points: lastWalkPoints,
      ));
    }

    final newAllPoints = <LatLng>[];
    for (final seg in newSegments) {
      if (seg.points.isEmpty) continue;
      if (newAllPoints.isNotEmpty && !_pointsNear(newAllPoints.last, seg.points.first)) {
        newAllPoints.add(seg.points.first);
      }
      final start = (newAllPoints.isEmpty || !_pointsNear(newAllPoints.last, seg.points.first)) ? 0 : 1;
      if (start < seg.points.length) {
        newAllPoints.addAll(start == 0 ? seg.points : seg.points.sublist(start));
      }
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
      walkDistance: route.walkDistance,
      busDistance: route.busDistance,
      isNightBus: route.isNightBus,
      taxiCost: route.taxiCost,
      strategyMode: route.strategyMode,
      strategyId: route.strategyId,
      trafficLights: route.trafficLights,
    );
  }

  static bool _pointsNear(LatLng a, LatLng b) {
    const double epsilon = 1e-5;
    return (a.latitude - b.latitude).abs() < epsilon &&
        (a.longitude - b.longitude).abs() < epsilon;
  }

  Stream<NavigationState> get navigationStateStream =>
      AmapNavigationBridge.navigationStateStream;

  Future<bool> selectRouteId(int routeId) =>
      AmapNavigationBridge.selectRouteId(routeId);

  Future<bool> startNavigation({bool isEmulator = false, bool enableVoice = true}) =>
      AmapNavigationBridge.startNavigation(isEmulator: isEmulator, enableVoice: enableVoice);

  Future<bool> pauseNavigation() => AmapNavigationBridge.pauseNavigation();

  Future<bool> resumeNavigation() => AmapNavigationBridge.resumeNavigation();

  Future<bool> stopNavigation() => AmapNavigationBridge.stopNavigation();

  double _calcDistance(List<LatLng> points) {
    if (points.length < 2) return 0;
    double dist = 0;
    for (int i = 0; i < points.length - 1; i++) {
      dist += points[i].distanceTo(points[i + 1]);
    }
    return dist;
  }
}