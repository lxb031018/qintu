import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/providers/location_status_provider.dart';
import 'widgets/amap_map_view.dart';
import 'core/amap_map_controller.dart';
import 'package:qintu/features/map_navigation/models/map_overlay_models.dart';
import 'provider/location_input_provider.dart';
import 'provider/map_navigation_provider.dart';
import 'widgets/location_input_card.dart';
import 'widgets/location_category_list.dart';
import 'widgets/route_result_list.dart';
import 'widgets/location_status_button.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_spacings.dart';
import 'service/location_sharing_service.dart';

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
  }

  /// 处理位置输入变化，移动地图到选中位置并显示标记
  void _handleLocationInputChange(LocationInputState? previous, LocationInputState next) {
    // 当起点 POI 变化时
    if (next.origin.poi != previous?.origin.poi && next.origin.poi != null) {
      final latlng = next.origin.poi!.latLng;
      if (latlng != null) {
        _mapController?.moveCamera(lat: latlng.latitude, lng: latlng.longitude, zoom: 17);
        _mapController?.addPoiMarker(PoiMarkerData(
          id: 'origin_${DateTime.now().millisecondsSinceEpoch}',
          name: next.origin.poi!.name,
          address: next.origin.poi!.address,
          position: latlng,
        ));
      }
    }
    // 当终点 POI 变化时
    if (next.destination.poi != previous?.destination.poi && next.destination.poi != null) {
      final latlng = next.destination.poi!.latLng;
      if (latlng != null) {
        _mapController?.moveCamera(lat: latlng.latitude, lng: latlng.longitude, zoom: 17);
        _mapController?.addPoiMarker(PoiMarkerData(
          id: 'destination_${DateTime.now().millisecondsSinceEpoch}',
          name: next.destination.poi!.name,
          address: next.destination.poi!.address,
          position: latlng,
        ));
      }
    }
    // 当起点被清除时
    if (previous?.origin.poi != null && next.origin.poi == null) {
      _mapController?.clearPoiMarkers();
    }
    // 当终点被清除时
    if (previous?.destination.poi != null && next.destination.poi == null) {
      _mapController?.clearPoiMarkers();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final navState = ref.watch(mapNavigationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 监听位置输入变化，移动地图到选中位置并显示标记
    ref.listen(locationInputProvider, (previous, next) {
      _handleLocationInputChange(previous, next);
    });

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

          // 路线结果层
          if (navState.routes.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 80,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackgroundColor
                      : AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: const RouteResultList(),
              ),
            ),

          // 定位状态按钮
          Positioned(
            left: 12,
            bottom: 16,
            child: const LocationStatusButton(),
          ),
        ],
      ),
    );
  }
}
