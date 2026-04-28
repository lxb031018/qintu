import '../core/amap_map_controller.dart';
import '../models/amap_routing_models.dart';
import '../models/map_overlay_models.dart';
import '../provider/location_input_provider.dart';

/// ============================================
/// 地图显示 Service
///
/// 封装地图状态编排逻辑（相机移动、标记操作）
/// 不持有 UI 状态，只负责地图视图层面的操作协调
/// ============================================

class MapDisplayService {
  AmapMapController? _mapController;

  /// 设置地图控制器
  void setMapController(AmapMapController? controller) {
    _mapController = controller;
  }

  /// 处理位置输入变化，更新地图视图
  ///
  /// 起点 marker 只在起点输入框有地点后显示
  /// 终点 marker 只在终点输入框有地点后显示
  void handleLocationInputChange(
    LocationInputState? previous,
    LocationInputState next,
  ) {
    // 当起点 POI 变化时
    if (next.origin.poi != previous?.origin.poi) {
      if (next.origin.poi != null) {
        final latlng = next.origin.poi!.latLng;
        if (latlng != null) {
          // 显示起点 marker，移动相机到起点
          _mapController?.showSingleMarker(
            lat: latlng.latitude,
            lng: latlng.longitude,
            isStart: true,
            label: next.origin.poi!.name,
          );
          _mapController?.moveCamera(
            lat: latlng.latitude,
            lng: latlng.longitude,
            zoom: 17,
          );
        }
      } else {
        // 清除起点 marker
        _mapController?.clearSingleMarker(true);
      }
    }

    // 当终点 POI 变化时
    if (next.destination.poi != previous?.destination.poi) {
      if (next.destination.poi != null) {
        final latlng = next.destination.poi!.latLng;
        if (latlng != null) {
          // 显示终点 marker，移动相机到终点
          _mapController?.showSingleMarker(
            lat: latlng.latitude,
            lng: latlng.longitude,
            isStart: false,
            label: next.destination.poi!.name,
          );
          _mapController?.moveCamera(
            lat: latlng.latitude,
            lng: latlng.longitude,
            zoom: 17,
          );
        }
      } else {
        // 清除终点 marker
        _mapController?.clearSingleMarker(false);
      }
    }
  }

  /// 显示路线预览
  ///
  /// [routes] 路线列表
  /// [selectedIndex] 当前选中的路线索引
  /// [routeType] 出行方式（决定路线颜色）
  Future<void> showRoutes(
    List<RouteOption> routes,
    int selectedIndex,
    RouteType routeType,
  ) async {
    if (routes.isEmpty) return;

    // 提取路线坐标点
    final routePoints = routes.map((r) => r.points).toList();

    // 获取路线颜色
    final colors = routes.map((r) => RouteColors.getColor(r.routeType)).toList();

    // 调用地图控制器显示路线
    await _mapController?.showRoutes(
      routePoints,
      selectIndex: selectedIndex,
      colors: colors,
    );
  }

  /// 清除路线预览
  Future<void> clearRoutes() async {
    await _mapController?.clearRoutes();
  }
}

/// 全局单例
final mapDisplayService = MapDisplayService();
