import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/models/async_state.dart';
import 'package:qintu/utils/logger.dart';
import '../../models/poi_models.dart';
import '../../models/amap_routing_models.dart';
import '../../models/bus_route_models.dart' as bus;
import '../../service/poi_service.dart';
import '../../service/bus_route_service.dart';
import '../../core/amap_navigation_bridge.dart';
import '../map_display/map_display_coordinator.dart';
import '../../models/navigation_models.dart';
import '../map_display/map_controller_provider.dart';
import 'map_navigation_state.dart';
import 'map_navigation_service.dart';

/// ============================================
/// 地图导航 Notifier
///
/// 管理路线规划、导航状态和导航事件：
/// - 起点/终点设置和交换
/// - 路线搜索和规划（驾车/步行/骑行/公交）
/// - 导航启动/暂停/恢复/停止
/// - 导航状态变化监听和重算处理
///
/// 实现 MapNavigationService 接口
/// ============================================
class MapNavigationNotifier extends Notifier<MapNavigationState> implements MapNavigationService {
  late final PoiService _poiService = ref.read(poiServiceProvider);
  late final MapDisplayCoordinator _mapDisplayCoordinator = ref.read(mapDisplayCoordinatorProvider);
  bool _disposed = false;
  StreamSubscription<NavigationState>? _navStreamSub;

  @override
  MapNavigationState build() {
    _startNavEventListener();
    ref.onDispose(() {
      _disposed = true;
      _navStreamSub?.cancel();
      AmapNavigationBridge.stopNavigation();
    });
    return const MapNavigationState();
  }

  void _startNavEventListener() {
    _navStreamSub?.cancel();
    _navStreamSub = AmapNavigationBridge.navigationStateStream.listen((navState) {
      if (_disposed) return;
      switch (navState.status) {
        case NavigationStatus.navigating:
          state = state.copyWith(isNavigating: true);
          break;
        case NavigationStatus.arrived:
          _handleNavEnd();
          break;
        case NavigationStatus.stopped:
          _handleNavEnd();
          break;
        case NavigationStatus.recalculated:
          _handleRouteRecalculated(navState);
          break;
        case NavigationStatus.idle:
        case NavigationStatus.offRoute:
        case NavigationStatus.recalculating:
          debugPrint('🔄 重算中… calcType=${navState.calcRouteType}');
          break;
        case NavigationStatus.gpsWeak:
        case NavigationStatus.parallelRoad:
        case NavigationStatus.error:
          break;
      }
    });
  }

  void _handleRouteRecalculated(NavigationState navState) {
    final rawData = navState.rawData;
    if (rawData == null) return;

    final reason = rawData['reason']?.toString() ?? 'unknown';
    final calcType = rawData['calcRouteType'] as int? ?? -1;
    final routesList = rawData['routes'] as List<dynamic>?;
    if (routesList == null || routesList.isEmpty) {
      debugPrint('🔄 重算完成但无路线数据: reason=$reason, calcType=$calcType');
      return;
    }

    debugPrint('🔄 重算完成: reason=$reason, calcType=$calcType, ${routesList.length} 条新路线');

    final firstRoute = routesList.first as Map<dynamic, dynamic>;
    final routeId = firstRoute['routeId'] as int?;
    if (routeId != null && routeId >= 0) {
      AmapNavigationBridge.selectRouteId(routeId);
      ref.read(mapControllerNotifierProvider)?.enterNavigationMode(routeId);
    }
  }

  void _handleNavEnd() {
    state = state.copyWith(
      isNavigating: false,
      showRoutesSheet: false,
      clearCurrentRouteType: true,
    );
    ref.read(mapControllerNotifierProvider)?.disableNaviMode();
    ref.read(mapControllerNotifierProvider)?.setFollowMode(false);
    ref.read(mapControllerNotifierProvider)?.setLocationDotEnabled(true);
    ref.read(mapControllerNotifierProvider)?.setCarOverlayVisible(false);
    ref.read(mapControllerNotifierProvider)?.clearCarMarker();
    ref.read(mapControllerNotifierProvider)?.setRouteTmcEnabled(false);
    ref.read(mapControllerNotifierProvider)?.setRouteTrafficIconEnabled(false);
    ref.read(mapControllerNotifierProvider)?.clearRoutes();
    ref.read(mapControllerNotifierProvider)?.clearRouteOverlays();
    ref.read(mapControllerNotifierProvider)?.moveToMyLocation();
  }

  @override
  void setOrigin(PoiSuggestion poi) {
    state = state.copyWith(
      originPoi: poi,
      originLocation: poi.latLng,
    );
    _resetSearchAndRoutes();
  }

  @override
  void setDestination(PoiSuggestion poi) {
    state = state.copyWith(
      destinationPoi: poi,
      destinationLocation: poi.latLng,
    );
    _resetSearchAndRoutes(clearRouteType: true);
  }

  @override
  void clearOrigin() {
    state = state.copyWith(
      originPoi: null,
      originLocation: null,
      clearCurrentRouteType: true,
    );
  }

  @override
  void clearDestination() {
    state = state.copyWith(
      destinationPoi: null,
      destinationLocation: null,
      clearCurrentRouteType: true,
    );
  }

  void _resetSearchAndRoutes({bool clearRouteType = false}) {
    state = state.copyWith(
      searchKeyword: '',
      searchState: const AsyncState.success([]),
      routes: const [],
      showRoutesSheet: false,
      clearCurrentRouteType: clearRouteType,
    );
  }

  @override
  Future<void> swapOriginAndDestination() async {
    state = state.copyWith(
      originPoi: state.destinationPoi,
      originLocation: state.destinationLocation,
      destinationPoi: state.originPoi,
      destinationLocation: state.originLocation,
      routes: const [],
      showRoutesSheet: false,
    );

    _mapDisplayCoordinator.clearRoutes();

    if (state.canPlanRoute && state.currentRouteType != null) {
      await planRoute();
    }
  }

  Future<void> searchPoi(String keywords) async {
    if (keywords.length < 2) {
      state = state.copyWith(
        searchState: const AsyncState.success([]),
        searchKeyword: keywords,
      );
      return;
    }

    state = state.copyWith(
      searchState: const AsyncState.loading(),
      searchKeyword: keywords,
    );

    try {
      final result = await _poiService.searchPoi(
        keywords: keywords,
        location: state.originLocation,
      );

      if (_disposed) return;

      if (result.isSuccess) {
        state = state.copyWith(
          searchState: AsyncState.success(result.suggestions),
        );
      } else {
        state = state.copyWith(
          searchState: AsyncState.error(result.errorMessage ?? '搜索失败'),
        );
      }
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(
        searchState: AsyncState.error(e.toString()),
      );
    }
  }

  Future<void> planRoute() async {
    if (!state.canPlanRoute) {
      state = state.copyWith(errorMessage: '请选择起点和终点');
      return;
    }

    if (state.currentRouteType == null) {
      state = state.copyWith(errorMessage: '请选择出行方式');
      return;
    }

    state = state.copyWith(
      routes: const [],
      routesState: const AsyncState.loading(),
      errorMessage: null,
    );

    ref.read(mapControllerNotifierProvider)?.clearRouteOverlays();
    _mapDisplayCoordinator.clearRoutes();

    try {
      List<RouteOption> routes;

      if (state.currentRouteType == RouteType.transit) {
        final geoResult = await _poiService.getRegeocodeFromLocation(state.originLocation!);
        final cityCode = geoResult?.cityCode;
        Logs.navigation.info('公交路线搜索：起点(${state.originLocation!.latitude},${state.originLocation!.longitude}) 终点(${state.destinationLocation!.latitude},${state.destinationLocation!.longitude}) 城市码=$cityCode');
        final busService = BusRouteService();
        final busPaths = await busService.calculateBusRoute(
          from: state.originLocation!,
          to: state.destinationLocation!,
          city: cityCode ?? '010',
          cityCode: cityCode ?? '010',
        );
        Logs.navigation.info('公交路线搜索结果：${busPaths.length} 条路径');
        routes = busPaths.map((bp) => _busPathToRouteOption(bp, cityCode)).toList();
      } else {
        final naviRoutes = await AmapNavigationBridge.calculateRoute(
          routeType: _routeTypeToString(state.currentRouteType!),
          origin: state.originLocation!,
          destination: state.destinationLocation!,
          strategy: 10,
        );
        routes = naviRoutes ?? [];
      }

      if (_disposed) return;

      if (routes.isEmpty) {
        Logs.navigation.warning('未找到路线');
        ref.read(mapControllerNotifierProvider)?.clearRouteOverlays();
        _mapDisplayCoordinator.clearRoutes();
        state = state.copyWith(
          routes: const [],
          routesState: const AsyncState.success([]),
          errorMessage: '未找到路线',
          showRoutesSheet: true,
        );
        debugPrint('[PLAN_ROUTE] 空结果状态已写入: routes=0, showRoutesSheet=true');
      } else {
        state = state.copyWith(
          routes: routes,
          selectedRouteIndex: 0,
          routesState: AsyncState.success(routes),
          showRoutesSheet: true,
        );
        debugPrint('[PLAN_ROUTE] ${routes.length}条路线状态已写入: showRoutesSheet=true, routeType=${state.currentRouteType}');

        if (state.currentRouteType != RouteType.transit) {
          final routeIds = routes.map((r) => r.routeId).where((id) => id >= 0).toList();
          if (routeIds.isNotEmpty) {
            ref.read(mapControllerNotifierProvider)?.showRoutesWithOverlay(routeIds, selectIndex: 0);
          }
          _animateCameraToShowAllRoutes(routes);
        }
      }
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(
        routesState: AsyncState.error(e.toString()),
      );
    }
  }

  String _routeTypeToString(RouteType type) {
    switch (type) {
      case RouteType.driving:
        return 'driving';
      case RouteType.walking:
        return 'walking';
      case RouteType.riding:
        return 'riding';
      case RouteType.transit:
        return 'transit';
    }
  }

  RouteOption _busPathToRouteOption(bus.BusPath bp, String? cityCode) {
    return RouteOption(
      routeId: bp.routeId,
      distance: bp.distance,
      duration: bp.duration.toDouble(),
      strategy: '公共交通',
      tolls: bp.cost,
      points: bp.points,
      routeType: RouteType.transit,
      transitSegments: bp.segments,
      walkDistance: bp.walkDistance,
      busDistance: bp.busDistance,
      isNightBus: bp.nightBus,
      cityCodes: cityCode != null ? [cityCode] : null,
    );
  }

  void _animateCameraToShowAllRoutes(List<RouteOption> routes) {
    if (routes.isEmpty) return;

    final allPoints = <Map<String, double>>[];
    for (final route in routes) {
      for (final point in route.points) {
        allPoints.add({'latitude': point.latitude, 'longitude': point.longitude});
      }
    }

    if (allPoints.isEmpty) return;

    ref.read(mapControllerNotifierProvider)?.animateCameraToBounds(
      allPoints,
      padding: 100,
      duration: 800,
    );
  }

  @override
  Future<void> switchRouteType(RouteType type) async {
    state = state.copyWith(currentRouteType: type);
    if (!state.canPlanRoute) return;
    await planRoute();
  }

  void selectRoute(int index) {
    if (index >= 0 && index < state.routes.length) {
      state = state.copyWith(selectedRouteIndex: index);
      if (state.currentRouteType != RouteType.transit) {
        final route = state.routes[index];
        if (route.routeId >= 0) {
          ref.read(mapControllerNotifierProvider)?.highlightRouteOverlay(route.routeId);
          AmapNavigationBridge.selectRouteId(route.routeId);
        }
      }
    }
  }

  void setOriginFocused(bool focused) {
    state = state.copyWith(isOriginFocused: focused);
  }

  @override
  void showRoutesSheet() {
    state = state.copyWith(showRoutesSheet: true);
  }

  void hideRoutesSheet() {
    state = state.copyWith(showRoutesSheet: false, clearCurrentRouteType: true);
  }

  Future<void> startNavigation() async {
    final route = state.selectedRoute;
    if (route == null) {
      state = state.copyWith(errorMessage: '请先选择路线');
      return;
    }

    if (route.points.isEmpty) {
      state = state.copyWith(errorMessage: '路线数据异常');
      return;
    }

    if (state.currentRouteType == RouteType.transit) {
      _mapDisplayCoordinator.showRoutes(state.routes, state.selectedRouteIndex, state.currentRouteType!);
      return;
    }

    state = state.copyWith(
      isNavigating: true,
      showRoutesSheet: false,
    );

    ref.read(mapControllerNotifierProvider)?.enableNaviMode();

    ref.read(mapControllerNotifierProvider)?.setFollowMode(true);
    ref.read(mapControllerNotifierProvider)?.setLocationDotEnabled(false);
    ref.read(mapControllerNotifierProvider)?.setCarOverlayVisible(true);
    ref.read(mapControllerNotifierProvider)?.setRouteTmcEnabled(true);
    ref.read(mapControllerNotifierProvider)?.setRouteTrafficIconEnabled(true);

    await AmapNavigationBridge.selectRouteId(route.routeId);

    if (route.routeId >= 0) {
      ref.read(mapControllerNotifierProvider)?.enterNavigationMode(route.routeId);
    }

    Logs.navigation.info('📍 调用 AmapNavigationBridge.startNavigation...');
    final success = await AmapNavigationBridge.startNavigation(enableVoice: true);
    Logs.navigation.info('📍 AmapNavigationBridge.startNavigation 返回: $success');

    if (!success) {
      state = state.copyWith(
        isNavigating: false,
        errorMessage: '启动导航失败',
      );
      _handleNavEnd();
    }
  }

  Future<void> pauseNavigation() async {
    await AmapNavigationBridge.pauseNavigation();
  }

  Future<void> resumeNavigation() async {
    await AmapNavigationBridge.resumeNavigation();
  }

  Future<void> stopNavigation() async {
    await AmapNavigationBridge.stopNavigation();
    _handleNavEnd();
  }
}

final mapNavigationProvider =
    NotifierProvider<MapNavigationNotifier, MapNavigationState>(
  MapNavigationNotifier.new,
);