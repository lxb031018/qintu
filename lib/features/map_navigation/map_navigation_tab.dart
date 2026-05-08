import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/providers/location_status_provider.dart';
import 'widgets/amap_map_view.dart';
import 'service/map_controller_service/map_controller_service.dart';
import 'models/amap_routing_models.dart';
import 'provider/location_input_provider.dart';
import 'provider/map_navigation_provider.dart';
import 'provider/location_sharing_provider.dart';
import 'provider/map_controller_provider.dart';
import 'package:qintu/providers/settings_manager.dart';
import 'widgets/location_input_card/location_input_card.dart';
import 'widgets/location_category_list/location_category_list.dart';
import 'widgets/location_status_button.dart';
import 'widgets/route_result_bottom_sheet/route_result_bottom_sheet.dart';
import 'models/map_overlay_models.dart';
import '../../../constants/app_durations.dart';
import '../../../constants/app_spacings.dart';
import 'provider/map_display_coordinator.dart';

/// 由 UnifiedHomePage 在首次布局后写入 Tab Bar 实际高度
final tabBarHeightProvider =
    NotifierProvider<TabBarHeightNotifier, double>(TabBarHeightNotifier.new);

class TabBarHeightNotifier extends Notifier<double> {
  @override
  double build() => 62;

  void setHeight(double height) {
    state = height;
  }
}

/// ============================================
/// 地图导航 Tab
///
/// 使用四层架构：
/// - api 层：纯 HTTP 调用
/// - service 层：纯业务逻辑
/// - provider 层：UI 状态管理
/// - widgets 层：UI 组件
///
/// 定位状态由 lib/providers/location_provider.dart 统一管理
/// ============================================

class MapNavigationTab extends ConsumerStatefulWidget {
  const MapNavigationTab({super.key});

  @override
  ConsumerState<MapNavigationTab> createState() => _MapNavigationTabState();
}

class _MapNavigationTabState extends ConsumerState<MapNavigationTab>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final _mapKey = GlobalKey();
  final _locationCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).checkStatus();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ref.read(locationProvider.notifier).checkStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onMapCreated(MapControllerService controller) {
    ref.read(mapControllerNotifierProvider.notifier).setController(controller);
    ref.read(locationSharingProvider.notifier).setMapController(controller);

    // 设置导航退出监听器
    controller.map.setOnNaviViewExitListener(() {
      debugPrint('🚪 地图导航 Tab 收到导航退出事件');
      ref.read(mapNavigationProvider.notifier).stopNavigation();
    });
  }

  void _handleLocationInputChange(LocationInputState? previous, LocationInputState next) {
    ref.read(mapDisplayCoordinatorProvider).handleLocationInputChange(previous, next);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(locationInputProvider, (previous, next) {
      _handleLocationInputChange(previous, next);
    });

    ref.listen(mapNavigationProvider.select((s) => (
      s.showRoutesSheet,
      s.isNavigating,
      s.routes,
      s.currentRouteType,
      s.originLocation,
      s.destinationLocation,
    )), (previous, next) {
      final (showRoutesSheet, isNavigating, routes, routeType, originLocation, destinationLocation) = next;
      if (isNavigating) return;
      if (showRoutesSheet && routes.isNotEmpty && routeType != null
          && originLocation != null && destinationLocation != null) {
      } else {
        ref.read(mapDisplayCoordinatorProvider).clearRoutes();
      }
    });

    final navState = ref.watch(mapNavigationProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: AmapMapView(
                key: _mapKey,
                onMapCreated: _onMapCreated,
              ),
            ),
          ),

          // 非导航状态：搜索UI
          if (!navState.isNavigating) ...[
            AnimatedPositioned(
              duration: AppDurations.fastAnimation,
              curve: Curves.easeInOut,
              left: AppSpacings.smd,
              right: AppSpacings.smd,
              top: navState.showRoutesSheet
                  ? MediaQuery.of(context).padding.top + AppSpacings.smd
                  : ref.watch(tabBarHeightProvider) + AppSpacings.smd,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!ref.watch(settingsManagerProvider).isAntiCollisionEnabled)
                    LocationInputCard(key: _locationCardKey),
                  if (!ref.watch(settingsManagerProvider).isAntiCollisionEnabled &&
                      ref.watch(locationInputProvider).listVisible)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacings.sm),
                      child: LocationCategoryList(),
                    ),
                ],
              ),
            ),

            Positioned(
              left: 12,
              bottom: 16,
              child: const LocationStatusButton(),
            ),
          ],

          // 路线栏（非导航时）
          if (!navState.isNavigating && navState.showRoutesSheet &&
              (navState.routes.isNotEmpty || navState.routesState.isLoading || navState.routesState.isSuccess))
            _RouteBottomSheetPositioner(
              navState: navState,
              tabBarHeight: ref.watch(tabBarHeightProvider),
              locationCardKey: _locationCardKey,
            ),
        ],
      ),
    );
  }
}

class _RouteBottomSheetPositioner extends ConsumerStatefulWidget {
  final MapNavigationState navState;
  final double tabBarHeight;
  final GlobalKey locationCardKey;

  const _RouteBottomSheetPositioner({
    required this.navState,
    required this.tabBarHeight,
    required this.locationCardKey,
  });

  @override
  ConsumerState<_RouteBottomSheetPositioner> createState() => _RouteBottomSheetPositionerState();
}

class _RouteBottomSheetPositionerState extends ConsumerState<_RouteBottomSheetPositioner> {
  double _dragOffset = 0;
  bool _isDragging = false;

  static const double _maxDragOffset = 120;
  static const double _dismissThreshold = 80;

  bool get _isTransit => widget.navState.currentRouteType == RouteType.transit;

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset = 0;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isTransit) return;
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0, _maxDragOffset);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset > _dismissThreshold) {
      ref.read(mapNavigationProvider.notifier).hideRoutesSheet();
    }
    setState(() {
      _isDragging = false;
      _dragOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTransit = _isTransit;

    if (!isTransit) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: _RouteBottomSheetBuilder(
          navState: widget.navState,
          locationCardKey: widget.locationCardKey,
        ),
      );
    }

    final cardBox =
        widget.locationCardKey.currentContext?.findRenderObject() as RenderBox?;
    final cardTop = cardBox?.localToGlobal(Offset.zero).dy ?? 0;
    final cardHeight = cardBox?.size.height ?? 0;
    final cardBottom = cardTop + cardHeight;
    final sheetTop = cardBottom + AppSpacings.sm;

    final top = _isDragging ? sheetTop + _dragOffset : sheetTop;

    return Positioned(
      top: top,
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: _RouteBottomSheetBuilder(
          navState: widget.navState,
          locationCardKey: widget.locationCardKey,
        ),
      ),
    );
  }
}

class _RouteBottomSheetBuilder extends ConsumerWidget {
  final MapNavigationState navState;
  final GlobalKey locationCardKey;

  const _RouteBottomSheetBuilder({
    required this.navState,
    required this.locationCardKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 直接从 provider 读取最新状态，确保不因 prop 传递延迟导致数据过期
    final currentState = ref.watch(mapNavigationProvider);
    final routes = currentState.routes;
    debugPrint('[BOTTOM_SHEET_BUILDER] routes.length=${routes.length}, '
        'currentRouteType=${currentState.currentRouteType}, '
        'routesState=${currentState.routesState}, '
        'showRoutesSheet=${currentState.showRoutesSheet}');
    final selectedIdx = currentState.selectedRouteIndex;
    final selectedRoute = selectedIdx < routes.length ? routes[selectedIdx] : null;

    // 计算公共交通的 maxHeight
    double? maxHeight;
    if (currentState.currentRouteType == RouteType.transit) {
      final cardBox =
          locationCardKey.currentContext?.findRenderObject() as RenderBox?;
      final cardTop = cardBox?.localToGlobal(Offset.zero).dy ?? 0;
      final cardHeight = cardBox?.size.height ?? 0;
      final screenHeight = MediaQuery.of(context).size.height;
      maxHeight = screenHeight - cardTop - cardHeight - AppSpacings.sm;
    }

    return RouteResultBottomSheet(
      maxHeight: maxHeight,
      routes: routes.asMap().entries.map((entry) {
        final idx = entry.key;
        final route = entry.value;
        final isSelected = idx == selectedIdx;

        int? timeDiff;
        int? distanceDiff;
        if (!isSelected && selectedRoute != null) {
          final diffSec = (route.duration - selectedRoute.duration).round();
          final diffM = (route.distance - selectedRoute.distance).round();
          if (diffSec.abs() >= 60) timeDiff = diffSec;
          if (diffM.abs() >= 100) distanceDiff = diffM;
        }

        return RouteResultItem(
          distance: route.distance,
          formattedDistance: route.distanceText,
          duration: route.duration,
          formattedDuration: route.durationText,
          strategy: route.strategyText,
          tolls: route.tolls,
          strategyId: route.strategyId,
          trafficStatuses: route.trafficStatuses,
          timeDiff: timeDiff,
          distanceDiff: distanceDiff,
          routeType: route.routeType,
          transitSegments: route.transitSegments,
          transitSummary: route.transitSummaryText,
          transitLineNames: route.transitLineNames,
          transferCount: route.transferCount,
          walkDistance: route.walkDistance,
          cityCode: route.cityCodes?.isNotEmpty == true ? route.cityCodes!.first : null,
        );
      }).toList(),
      selectedIndex: selectedIdx,
      currentRouteType: currentState.currentRouteType ?? RouteType.driving,
      drivingStrategy: currentState.drivingStrategy,
      onDrivingStrategyChanged: (strategy) {
        ref.read(mapNavigationProvider.notifier).setDrivingStrategy(strategy);
      },
      onRouteSelected: (index) {
        ref.read(mapNavigationProvider.notifier).selectRoute(index);
        if (currentState.currentRouteType == RouteType.transit) {
          final route = currentState.routes[index];
          ref.read(mapDisplayCoordinatorProvider).showTransitRouteDetail(route);
        }
      },
      onClose: () {
        ref.read(mapNavigationProvider.notifier).hideRoutesSheet();
      },
      errorMessage: currentState.errorMessage,
      onStartNavigation: () {
        ref.read(mapNavigationProvider.notifier).startNavigation();
      },
      onDetailExited: () {
        ref.read(mapDisplayCoordinatorProvider).clearRoutes();
      },
      isLoading: currentState.routesState.isLoading,
    );
  }
}
