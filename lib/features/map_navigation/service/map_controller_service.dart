import 'package:qintu/models/location/lat_lng.dart';
import '../core/amap_map_controller.dart';
import '../models/map_overlay_models.dart';

/// ============================================
/// 地图控制器服务（service 层）
///
/// 包装 core 层的 AmapMapController，提供给 provider 层使用。
/// provider 层禁止直接访问 core/，必须通过本 service。
/// ============================================
class MapControllerService {
  final AmapMapController _controller;

  MapControllerService() : _controller = AmapMapController();

  void dispose() => _controller.dispose();

  // ==================== 定位 ====================

  Future<void> startLocation({bool autoMoveToFirstLocation = true}) =>
      _controller.startLocation(autoMoveToFirstLocation: autoMoveToFirstLocation);

  Future<void> moveToMyLocation() => _controller.moveToMyLocation();

  Future<Map<String, dynamic>?> getCurrentLocation() =>
      _controller.getCurrentLocation();

  Future<void> stopLocation() => _controller.stopLocation();

  // ==================== 相机 ====================

  Future<void> moveCamera({
    required double lat,
    required double lng,
    double zoom = 15.0,
  }) => _controller.moveCamera(lat: lat, lng: lng, zoom: zoom);

  // ==================== 路线 ====================

  Future<void> addPolyline(List<LatLng> points,
          {int color = 0xFF1890FF, double width = 8.0}) =>
      _controller.addPolyline(points, color: color, width: width);

  Future<int?> showRoutes(
    List<List<LatLng>> routes, {
    int selectIndex = 0,
    List<int>? colors,
    List<double>? widths,
    List<int>? routeIds,
  }) => _controller.showRoutes(routes,
          selectIndex: selectIndex, colors: colors, widths: widths, routeIds: routeIds);

  Future<bool> selectRoute(int index,
          {int selectedColor = 0xFFFF4D4F, int unselectedColor = 0x401890FF}) =>
      _controller.selectRoute(index,
          selectedColor: selectedColor, unselectedColor: unselectedColor);

  Future<bool> enterNavigationMode(int routeId) =>
      _controller.enterNavigationMode(routeId);

  Future<void> clearRoutes() => _controller.clearRoutes();

  // ==================== 标记 ====================

  Future<bool> setRouteMarkers({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String? startLabel,
    String? endLabel,
  }) => _controller.setRouteMarkers(
          startLat: startLat,
          startLng: startLng,
          endLat: endLat,
          endLng: endLng,
          startLabel: startLabel,
          endLabel: endLabel);

  Future<bool> clearRouteMarkers() => _controller.clearRouteMarkers();

  Future<bool> showSingleMarker({
    required double lat,
    required double lng,
    required bool isStart,
    String? label,
  }) => _controller.showSingleMarker(lat: lat, lng: lng, isStart: isStart, label: label);

  Future<bool> clearSingleMarker(bool isStart) =>
      _controller.clearSingleMarker(isStart);

  Future<void> addPoiMarkers(List<PoiMarkerData> pois) =>
      _controller.addPoiMarkers(pois);

  Future<void> clearPoiMarkers() => _controller.clearPoiMarkers();

  // ==================== 导航/车载 ====================

  Future<bool> updateCarMarker({
    required double lat,
    required double lng,
    double bearing = 0,
  }) => _controller.updateCarMarker(lat: lat, lng: lng, bearing: bearing);

  Future<bool> setFollowMode(bool enabled) =>
      _controller.setFollowMode(enabled);

  Future<bool> clearCarMarker() => _controller.clearCarMarker();

  Future<bool> setLocationDotEnabled(bool enabled) =>
      _controller.setLocationDotEnabled(enabled);

  Future<bool> setCarOverlayVisible(bool visible) =>
      _controller.setCarOverlayVisible(visible);
}
