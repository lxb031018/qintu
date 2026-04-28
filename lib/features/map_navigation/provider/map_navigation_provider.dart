import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/poi_api.dart'; // 仅导入类型 PoiSuggestion, RouteType, RouteOption, LatLng
import '../service/poi_service.dart';
import '../service/amap_routing_service.dart';
import '../service/map_display_service.dart';
import '../service/amap_navigation_bridge.dart';

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

  const MapNavigationState({
    this.searchKeyword = '',
    this.originPoi,
    this.destinationPoi,
    this.originLocation,
    this.destinationLocation,
    this.routes = const [],
    this.selectedRouteIndex = 0,
    this.routesState = const AsyncState(isLoading: true),
    this.searchState = const AsyncState(isLoading: true),
    this.isOriginFocused = true,
    this.errorMessage,
    this.currentRouteType,
    this.showRoutesSheet = false,
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

/// 异步状态
class AsyncState<T> {
  final T? data;
  final bool isLoading;
  final String? errorMessage;

  const AsyncState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  /// 创建加载中状态
  static AsyncState<T> loading<T>() => AsyncState<T>(isLoading: true);

  /// 创建带数据的状态
  static AsyncState<T> success<T>(T data) => AsyncState<T>(data: data);

  /// 创建错误状态
  static AsyncState<T> failure<T>(String message) => AsyncState<T>(errorMessage: message);
}

/// ============================================
/// 地图导航 Provider
/// ============================================

class MapNavigationNotifier extends Notifier<MapNavigationState> {
  final AmapRoutingService _routeService = AmapRoutingService();
  final PoiService _poiService = poiService;
  bool _disposed = false;

  @override
  MapNavigationState build() {
    ref.onDispose(() {
      _disposed = true;
    });
    return const MapNavigationState();
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
      searchState: const AsyncState(data: []),
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
    mapDisplayService.clearRoutes();

    // 如果已有出行方式，自动重新规划路线
    if (state.canPlanRoute && state.currentRouteType != null) {
      await planRoute();
    }
  }

  /// 搜索 POI
  Future<void> searchPoi(String keywords) async {
    if (keywords.length < 2) {
      state = state.copyWith(
        searchState: const AsyncState(data: []),
        searchKeyword: keywords,
      );
      return;
    }

    state = state.copyWith(
      searchState: const AsyncState(isLoading: true),
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
          searchState: AsyncState.failure(result.errorMessage ?? '搜索失败'),
        );
      }
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(
        searchState: AsyncState.failure(e.toString()),
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
      routesState: const AsyncState(isLoading: true),
      errorMessage: null,
    );

    try {
      final routes = await _routeService.planRoute(
        type: state.currentRouteType!,
        origin: state.originLocation!,
        destination: state.destinationLocation!,
      );

      if (_disposed) return;

      if (routes.isEmpty) {
        state = state.copyWith(
          routesState: const AsyncState(data: []),
          errorMessage: '未找到路线',
        );
      } else {
        state = state.copyWith(
          routes: routes,
          selectedRouteIndex: 0,
          routesState: AsyncState.success(routes),
        );
        // 在地图上显示路线预览
        mapDisplayService.showRoutes(routes, 0, state.currentRouteType!);
      }
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(
        routesState: AsyncState.failure(e.toString()),
      );
    }
  }

  /// 切换出行方式并重新规划路线
  Future<void> switchRouteType(RouteType type) async {
    if (!state.canPlanRoute) return;
    state = state.copyWith(currentRouteType: type);
    await planRoute();
  }

  /// 选择路线
  void selectRoute(int index) {
    if (index >= 0 && index < state.routes.length) {
      state = state.copyWith(selectedRouteIndex: index);
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
    state = state.copyWith(showRoutesSheet: false);
  }

  /// 开始导航
  ///
  /// 调用原生 GPS 导航，传入当前选中的路线
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

    final success = await AmapNavigationBridge.startNavigation(
      routePoints: route.points,
      enableVoice: true,
      enableTts: true,
    );

    if (!success) {
      state = state.copyWith(errorMessage: '启动导航失败');
    }
  }
}

/// Provider 导出
final mapNavigationProvider =
    NotifierProvider<MapNavigationNotifier, MapNavigationState>(
  MapNavigationNotifier.new,
);
