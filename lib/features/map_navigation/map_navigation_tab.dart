import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/providers/location_status_provider.dart';
import 'widgets/amap_map_view.dart';
import 'core/amap_map_controller.dart';
import 'models/amap_routing_models.dart'; // for RouteType
import 'provider/location_input_provider.dart';
import 'provider/map_navigation_provider.dart';
import 'widgets/location_input_card.dart';
import 'widgets/location_category_list.dart';
import 'widgets/location_status_button.dart';
import 'widgets/route_result_bottom_sheet.dart';
import 'models/map_overlay_models.dart';
import '../../../constants/app_spacings.dart';
import 'service/location_sharing_service.dart';
import 'service/map_display_service.dart';

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

  /// 获取当前的地图控制器（供子组件访问）
  static AmapMapController? getMapController() => _currentMapController;
  static void _setMapController(AmapMapController? controller) {
    _currentMapController = controller;
  }
}

AmapMapController? _currentMapController;

class _MapNavigationTabState extends ConsumerState<MapNavigationTab>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  AmapMapController? _mapController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 初始化时检查定位状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).checkStatus();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 应用回到前台时重新检查定位状态
      ref.read(locationProvider.notifier).checkStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onMapCreated(AmapMapController controller) {
    _mapController = controller;
    MapNavigationTab._setMapController(controller);
    // 设置地图控制器到位置共享服务
    locationSharingService.setMapController(controller);
    // 设置地图控制器到地图显示服务
    mapDisplayService.setMapController(controller);
  }

  /// 处理位置输入变化，移动地图到选中位置并显示标记
  void _handleLocationInputChange(LocationInputState? previous, LocationInputState next) {
    // 委托给地图显示服务处理
    mapDisplayService.handleLocationInputChange(previous, next);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 监听位置输入变化，移动地图到选中位置并显示标记
    ref.listen(locationInputProvider, (previous, next) {
      _handleLocationInputChange(previous, next);
      // 交换起点终点后，如果两点都存在且路线应该显示，则重新显示路线
      final navState = ref.read(mapNavigationProvider);
      if (next.origin.poi != null && next.destination.poi != null) {
        if (navState.showRoutesSheet && navState.routes.isNotEmpty && navState.currentRouteType != null) {
          mapDisplayService.showRoutes(navState.routes, 0, navState.currentRouteType!);
        }
      }
    });

    // 监听路线显示状态变化，显示/隐藏路线
    ref.listen(mapNavigationProvider.select((s) => (
      s.showRoutesSheet,
      s.routes,
      s.currentRouteType,
    )), (previous, next) {
      final (showRoutesSheet, routes, routeType) = next;
      if (showRoutesSheet && routes.isNotEmpty && routeType != null) {
        mapDisplayService.showRoutes(routes, 0, routeType);
      } else if (!showRoutesSheet) {
        mapDisplayService.clearRoutes();
      }
    });

    final navState = ref.watch(mapNavigationProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 地图层
          Positioned.fill(
            child: AmapMapView(onMapCreated: _onMapCreated),
          ),

          // 搜索栏层
          Positioned(
            left: AppSpacings.smd,
            right: AppSpacings.smd,
            top: AppSpacings.smd,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LocationInputCard(),
                // 列表显示在输入框下方（独立卡片）
                if (ref.watch(locationInputProvider).listVisible)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacings.sm),
                    child: LocationCategoryList(
                      mapController: _mapController,
                    ),
                  ),
              ],
            ),
          ),

          // 定位状态按钮
          Positioned(
            left: 12,
            bottom: 16,
            child: const LocationStatusButton(),
          ),

          // 路线栏（不阻塞交互）
          if (navState.showRoutesSheet && navState.routes.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RouteResultBottomSheet(
                routes: navState.routes.map((route) => RouteResultItem(
                  distance: route.distance.toString(),
                  formattedDistance: route.distanceText,
                  duration: route.duration.toString(),
                  formattedDuration: route.durationText,
                  strategy: route.strategyText,
                  tolls: route.tolls,
                )).toList(),
                selectedIndex: navState.selectedRouteIndex,
                currentRouteType: navState.currentRouteType ?? RouteType.driving,
                onRouteSelected: (index) {
                  ref.read(mapNavigationProvider.notifier).selectRoute(index);
                },
                onRouteTypeChanged: (type) {
                  ref.read(mapNavigationProvider.notifier).switchRouteType(type);
                },
                onClose: () {
                  ref.read(mapNavigationProvider.notifier).hideRoutesSheet();
                },
              ),
            ),
        ],
      ),
    );
  }
}
