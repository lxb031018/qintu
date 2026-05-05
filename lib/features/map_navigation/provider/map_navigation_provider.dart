import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/models/async_state.dart';
import 'package:qintu/providers/settings_manager.dart';
import 'package:qintu/utils/logger.dart';
import '../models/poi_models.dart';
import '../models/amap_routing_models.dart';
import '../models/bus_route_models.dart' as bus;
import '../service/poi_service.dart';
import '../service/bus_route_service.dart';
import '../core/amap_navigation_bridge.dart';
import 'map_display_coordinator.dart';
import '../models/navigation_models.dart';
import 'map_controller_provider.dart';

/// ============================================
/// 地图导航状态
/// ============================================

class MapNavigationState {
  /// 搜索关键词
  final String searchKeyword;

  /// 起点
  final PoiSuggestion? originPoi;

  /// 终点
  final PoiSuggestion? destinationPoi;

  /// 起点坐标
  final LatLng? originLocation;

  /// 终点坐标
  final LatLng? destinationLocation;

  /// 路线规划结果
  final List<RouteOption> routes;

  /// 当前选中的路线索引
  final int selectedRouteIndex;

  /// 路线规划状态
  final AsyncState<List<RouteOption>> routesState;

  /// POI 搜索状态
  final AsyncState<List<PoiSuggestion>> searchState;

  /// 出发地/目的地输入框焦点
  final bool isOriginFocused;

  /// 错误信息
  final String? errorMessage;

  /// 当前出行方式（可空，未选择时为 null）
  final RouteType? currentRouteType;

  /// 是否显示路线栏
  final bool showRoutesSheet;

  /// 是否正在导航
  final bool isNavigating;

  /// 导航实时信息
  final double navSpeed;
  final int navRemainingDistance;
  final int navRemainingTime;
  final String navNextRoad;
  final String navCurrentRoad;

  /// 驾车策略偏好 (10-20)
  final int drivingStrategy;

  const MapNavigationState({
    this.searchKeyword = '',
    this.originPoi,
    this.destinationPoi,
    this.originLocation,
    this.destinationLocation,
    this.routes = const [],
    this.selectedRouteIndex = 0,
    this.routesState = const AsyncState.loading(),
    this.searchState = const AsyncState.loading(),
    this.isOriginFocused = true,
    this.errorMessage,
    this.currentRouteType,
    this.showRoutesSheet = false,
    this.isNavigating = false,
    this.navSpeed = 0,
    this.navRemainingDistance = 0,
    this.navRemainingTime = 0,
    this.navNextRoad = '',
    this.navCurrentRoad = '',
    this.drivingStrategy = 10,
  });

  MapNavigationState copyWith({
    String? searchKeyword,
    PoiSuggestion? originPoi,
    PoiSuggestion? destinationPoi,
    LatLng? originLocation,
    LatLng? destinationLocation,
    List<RouteOption>? routes,
    int? selectedRouteIndex,
    AsyncState<List<RouteOption>>? routesState,
    AsyncState<List<PoiSuggestion>>? searchState,
    bool? isOriginFocused,
    String? errorMessage,
    RouteType? currentRouteType,
    bool clearCurrentRouteType = false,
    bool? showRoutesSheet,
    bool? isNavigating,
    double? navSpeed,
    int? navRemainingDistance,
    int? navRemainingTime,
    String? navNextRoad,
    String? navCurrentRoad,
    int? drivingStrategy,
  }) {
    return MapNavigationState(
      searchKeyword: searchKeyword ?? this.searchKeyword,
      originPoi: originPoi ?? this.originPoi,
      destinationPoi: destinationPoi ?? this.destinationPoi,
      originLocation: originLocation ?? this.originLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      routes: routes ?? this.routes,
      selectedRouteIndex: selectedRouteIndex ?? this.selectedRouteIndex,
      routesState: routesState ?? this.routesState,
      searchState: searchState ?? this.searchState,
      isOriginFocused: isOriginFocused ?? this.isOriginFocused,
      errorMessage: errorMessage,
      currentRouteType: clearCurrentRouteType ? null : (currentRouteType ?? this.currentRouteType),
      showRoutesSheet: showRoutesSheet ?? this.showRoutesSheet,
      isNavigating: isNavigating ?? this.isNavigating,
      navSpeed: navSpeed ?? this.navSpeed,
      navRemainingDistance: navRemainingDistance ?? this.navRemainingDistance,
      navRemainingTime: navRemainingTime ?? this.navRemainingTime,
      navNextRoad: navNextRoad ?? this.navNextRoad,
      navCurrentRoad: navCurrentRoad ?? this.navCurrentRoad,
      drivingStrategy: drivingStrategy ?? this.drivingStrategy,
    );
  }

  /// 是否可以开始路线规划
  bool get canPlanRoute => originLocation != null && destinationLocation != null;

  /// 当前选中的路线
  RouteOption? get selectedRoute =>
      routes.isNotEmpty && selectedRouteIndex < routes.length
          ? routes[selectedRouteIndex]
          : null;
}


/// ============================================
/// 地图导航 Provider
/// ============================================

class MapNavigationNotifier extends Notifier<MapNavigationState> {
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
    final settings = ref.watch(settingsManagerProvider);
    return MapNavigationState(drivingStrategy: settings.drivingStrategy);
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

  /// 处理偏航/拥堵重算完成：更新地图上的路线和导航 SDK 的选中路线
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

    // 取第一条新路线 ID 告知 AMapNavi 当前选中（SDK 自动选中最优路线）
    final firstRoute = routesList.first as Map<dynamic, dynamic>;
    final routeId = firstRoute['routeId'] as int?;
    if (routeId != null && routeId >= 0) {
      // 通知原生导航 SDK 选中此路线
      AmapNavigationBridge.selectRouteId(routeId);
      // 更新地图渲染：切换到新的导航路线
      ref.read(mapControllerNotifierProvider)?.enterNavigationMode(routeId);
    }
  }

  void _handleNavEnd() {
    state = state.copyWith(
      isNavigating: false,
      showRoutesSheet: true,
    );
    ref.read(mapControllerNotifierProvider)?.setRouteTmcEnabled(false);
    ref.read(mapControllerNotifierProvider)?.setRouteTrafficIconEnabled(false);
  }

  /// 设置起点
  void setOrigin(PoiSuggestion poi) {
    state = state.copyWith(
      originPoi: poi,
      originLocation: poi.latLng,
    );
    _resetSearchAndRoutes();
  }

  /// 设置终点
  void setDestination(PoiSuggestion poi) {
    state = state.copyWith(
      destinationPoi: poi,
      destinationLocation: poi.latLng,
    );
    _resetSearchAndRoutes(clearRouteType: true);
  }

  /// 清除起点
  void clearOrigin() {
    state = state.copyWith(
      originPoi: null,
      originLocation: null,
      clearCurrentRouteType: true,
    );
  }

  /// 清除终点
  void clearDestination() {
    state = state.copyWith(
      destinationPoi: null,
      destinationLocation: null,
      clearCurrentRouteType: true,
    );
  }

  /// 内部辅助方法：重置搜索状态和路线
  void _resetSearchAndRoutes({bool clearRouteType = false}) {
    state = state.copyWith(
      searchKeyword: '',
      searchState: const AsyncState.success([]),
      routes: const [],
      showRoutesSheet: false,
      clearCurrentRouteType: clearRouteType,
    );
  }

  /// 交换起点和终点
  Future<void> swapOriginAndDestination() async {
    state = state.copyWith(
      originPoi: state.destinationPoi,
      originLocation: state.destinationLocation,
      destinationPoi: state.originPoi,
      destinationLocation: state.originLocation,
      routes: const [],
      showRoutesSheet: false,
    );

    // 清除地图上的路线预览
    _mapDisplayCoordinator.clearRoutes();

    // 如果已有出行方式，自动重新规划路线
    if (state.canPlanRoute && state.currentRouteType != null) {
      await planRoute();
    }
  }

  /// 搜索 POI
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

  /// 规划路线
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
      routesState: const AsyncState.loading(),
      errorMessage: null,
    );

    try {
      List<RouteOption> routes;

      if (state.currentRouteType == RouteType.transit) {
        // 公共交通：使用 RouteSearchV2 API
        final busService = BusRouteService();
        final busPaths = await busService.calculateBusRoute(
          from: state.originLocation!,
          to: state.destinationLocation!,
          city: '北京', // TODO: 从起点城市获取
        );
        routes = busPaths.map((bp) => _busPathToRouteOption(bp)).toList();
      } else {
        final naviRoutes = await AmapNavigationBridge.calculateRoute(
          routeType: _routeTypeToString(state.currentRouteType!),
          origin: state.originLocation!,
          destination: state.destinationLocation!,
          strategy: state.drivingStrategy,
        );
        routes = naviRoutes ?? [];
      }

      if (_disposed) return;

      if (routes.isEmpty) {
        state = state.copyWith(
          routesState: const AsyncState.success([]),
          errorMessage: '未找到路线',
        );
      } else {
        state = state.copyWith(
          routes: routes,
          selectedRouteIndex: 0,
          routesState: AsyncState.success(routes),
        );

        if (state.currentRouteType != RouteType.transit) {
          // 使用 RouteOverLay 渲染多路线
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

  /// 将 BusPath 转换为 RouteOption
  RouteOption _busPathToRouteOption(bus.BusPath bp) {
    // 将 BusTransitSegment 转换为 TransitSegment 模型
    final transitSegments = bp.segments.map((seg) {
      final lines = <TransitLine>[];
      if (seg.type == bus.TransitSegmentType.bus || seg.type == bus.TransitSegmentType.subway) {
        lines.add(TransitLine(
          name: seg.lineName ?? '',
          type: seg.type == bus.TransitSegmentType.subway
              ? TransitLineType.subway
              : TransitLineType.bus,
          stationCount: 0,
        ));
      }
      return TransitSegment(
        lines: lines,
        walkingDistance: seg.type == bus.TransitSegmentType.walk ? seg.distance.toInt() : 0,
        points: seg.points,
      );
    }).toList();

    return RouteOption(
      routeId: bp.routeId,
      distance: bp.distance,
      duration: bp.duration.toDouble(),
      strategy: '公共交通',
      tolls: bp.cost,
      points: bp.points,
      routeType: RouteType.transit,
      transitSegments: transitSegments,
      walkDistance: bp.walkDistance,
      busDistance: bp.busDistance,
      isNightBus: bp.nightBus,
    );
  }

  void _animateCameraToShowAllRoutes(List<RouteOption> routes) {
    if (routes.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final route in routes) {
      for (final point in route.points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }
    }

    if (minLat == double.infinity) return;

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    double zoom = 10;
    if (maxDiff > 0) {
      if (maxDiff > 1) {
        zoom = 6;
      } else if (maxDiff > 0.5) {
        zoom = 8;
      } else if (maxDiff > 0.1) {
        zoom = 10;
      } else if (maxDiff > 0.05) {
        zoom = 12;
      } else if (maxDiff > 0.01) {
        zoom = 14;
      } else {
        zoom = 16;
      }
    }

    ref.read(mapControllerNotifierProvider)?.animateCameraToCenter(
      lat: centerLat,
      lng: centerLng,
      zoom: zoom,
      duration: 800,
    );
  }

  /// 切换出行方式并重新规划路线
  Future<void> switchRouteType(RouteType type) async {
    if (!state.canPlanRoute) return;
    state = state.copyWith(currentRouteType: type);
    await planRoute();
  }

  /// 设置驾车策略偏好并重新规划路线
  Future<void> setDrivingStrategy(int strategy) async {
    if (state.drivingStrategy == strategy) return;
    state = state.copyWith(drivingStrategy: strategy);
    ref.read(settingsManagerProvider.notifier).setDrivingStrategy(strategy);
    if (state.canPlanRoute && state.currentRouteType == RouteType.driving) {
      await planRoute();
    }
  }

  /// 选择路线
  void selectRoute(int index) {
    if (index >= 0 && index < state.routes.length) {
      state = state.copyWith(selectedRouteIndex: index);
      if (state.currentRouteType != RouteType.transit) {
        final route = state.routes[index];
        // 使用 RouteOverLay 高亮选中路线
        if (route.routeId >= 0) {
          ref.read(mapControllerNotifierProvider)?.highlightRouteOverlay(route.routeId);
          // 通知 AMapNavi 选中该路线
          AmapNavigationBridge.selectRouteId(route.routeId);
        }
      }
    }
  }

  /// 切换起点/终点输入框焦点
  void setOriginFocused(bool focused) {
    state = state.copyWith(isOriginFocused: focused);
  }

  /// 显示路线栏
  void showRoutesSheet() {
    state = state.copyWith(showRoutesSheet: true);
  }

  /// 隐藏路线栏
  void hideRoutesSheet() {
    state = state.copyWith(showRoutesSheet: false, clearCurrentRouteType: true);
  }

  /// 开始导航
  ///
  /// 驾车/步行/骑行：启动 GPS 导航
  /// 公共交通：无 GPS 导航，地图路线图已在上方展开，此方法放大显示路线详情
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

    // 公共交通无需 GPS 导航：行程详情已在 route_result_bottom_sheet 展开；
    // 点击按钮仅刷新地图视野以完整显示路线
    if (state.currentRouteType == RouteType.transit) {
      _mapDisplayCoordinator.showRoutes(state.routes, state.selectedRouteIndex, state.currentRouteType!);
      return;
    }

    // 隐藏搜索UI，进入导航模式
    state = state.copyWith(
      isNavigating: true,
      showRoutesSheet: false,
    );

    // 启用 SDK 导航模式：显示完整 UI，自动绘制路线
    ref.read(mapControllerNotifierProvider)?.enableNaviMode();

    // 开启跟随模式，隐藏定位蓝点，显示车载标记
    ref.read(mapControllerNotifierProvider)?.setFollowMode(true);
    ref.read(mapControllerNotifierProvider)?.setLocationDotEnabled(false);
    ref.read(mapControllerNotifierProvider)?.setCarOverlayVisible(true);
    // 启用导航路线拥堵颜色和交通事件图标
    ref.read(mapControllerNotifierProvider)?.setRouteTmcEnabled(true);
    ref.read(mapControllerNotifierProvider)?.setRouteTrafficIconEnabled(true);

    // 选中路线（多路径时需要）
    await AmapNavigationBridge.selectRouteId(route.routeId);

    // 切换到导航渲染：SDK 自动处理路线显示
    if (route.routeId >= 0) {
      ref.read(mapControllerNotifierProvider)?.enterNavigationMode(route.routeId);
    }

    // 启动无 View 导航
    Logs.navigation.info('📍 调用 AmapNavigationBridge.startNavigation...');
    final success = await AmapNavigationBridge.startNavigation(enableVoice: true);
    Logs.navigation.info('📍 AmapNavigationBridge.startNavigation 返回: $success');

    if (!success) {
      state = state.copyWith(
        isNavigating: false,
        errorMessage: '启动导航失败',
      );
    }
  }

  /// 暂停导航
  Future<void> pauseNavigation() async {
    await AmapNavigationBridge.pauseNavigation();
  }

  /// 恢复导航
  Future<void> resumeNavigation() async {
    await AmapNavigationBridge.resumeNavigation();
  }

  /// 停止导航
  Future<void> stopNavigation() async {
    await AmapNavigationBridge.stopNavigation();
    ref.read(mapControllerNotifierProvider)?.disableNaviMode();
    ref.read(mapControllerNotifierProvider)?.setFollowMode(false);
    ref.read(mapControllerNotifierProvider)?.setLocationDotEnabled(true);
    ref.read(mapControllerNotifierProvider)?.setCarOverlayVisible(false);
    _handleNavEnd();
  }
}

/// Provider 导出
final mapNavigationProvider =
    NotifierProvider<MapNavigationNotifier, MapNavigationState>(
  MapNavigationNotifier.new,
);
