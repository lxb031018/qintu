import 'package:flutter/foundation.dart';
import '../../core/controller/amap_map_controller.dart';
import '../../core/controller/camera_controller.dart';

/// ============================================
/// 地图控制器服务（service 层）
///
/// 包装 core 层的 AmapMapController，提供给 provider 层使用。
/// provider 层禁止直接访问 core/，必须通过本 service。
/// ============================================
class MapControllerService {
  final AmapMapController _controller;
  final CameraController _cameraController;  // 直接持有，简化相机调用链

  MapControllerService() : _controller = AmapMapController(),
                           _cameraController = CameraController();

  void setOnNaviViewExitListener(VoidCallback? listener) =>
      _controller.setOnNaviViewExitListener(listener);

  void dispose() => _controller.dispose();

  // ==================== 定位 ====================

  Future<void> startLocation({bool autoMoveToFirstLocation = true}) =>
      _controller.startLocation(autoMoveToFirstLocation: autoMoveToFirstLocation);

  Future<void> moveToMyLocation() => _controller.moveToMyLocation();

  Future<Map<String, dynamic>?> getCurrentLocation() =>
      _controller.getCurrentLocation();

  String? get lastKnownCity => _controller.lastKnownCity;

  Future<Map<String, dynamic>?> getLastKnownLocation() =>
      _controller.getLastKnownLocation();

  // ==================== 相机 ====================

  Future<void> moveCamera({
    required double lat,
    required double lng,
    double zoom = 15.0,
  }) => _cameraController.moveCamera(lat: lat, lng: lng, zoom: zoom);

  Future<bool> animateCamera({
    required double lat,
    required double lng,
    double zoom = 15.0,
    double bearing = -1,
    double tilt = -1,
    int duration = 0,
  }) => _cameraController.animateCamera(lat: lat, lng: lng, zoom: zoom,
          bearing: bearing, tilt: tilt, duration: duration);

  Future<void> zoomIn() => _cameraController.zoomIn();
  Future<void> zoomOut() => _cameraController.zoomOut();
  Future<void> zoomTo(double level, {int duration = 0}) =>
      _cameraController.zoomTo(level, duration: duration);

  Future<void> setPointToCenter({required int x, required int y}) =>
      _cameraController.setPointToCenter(x: x, y: y);

  Future<void> changeLatLng({required double lat, required double lng}) =>
      _cameraController.changeLatLng(lat: lat, lng: lng);

  Future<void> moveCameraToCenter({
    required double lat,
    required double lng,
    double zoom = 15.0,
  }) => _cameraController.moveCameraToCenter(lat: lat, lng: lng, zoom: zoom);

  Future<void> animateCameraToCenter({
    required double lat,
    required double lng,
    double zoom = 15.0,
    int duration = 500,
  }) => _cameraController.animateCameraToCenter(lat: lat, lng: lng, zoom: zoom, duration: duration);

  Future<void> animateCameraToBounds(
    List<Map<String, double>> points, {
    int padding = 100,
    int duration = 800,
  }) => _cameraController.animateCameraToBounds(points, padding: padding, duration: duration);

  // ==================== 路线 ====================

  Future<int?> showRoutes(
    List<Map<String, dynamic>> routes, {
    int selectIndex = 0,
    List<int>? colors,
    List<double>? widths,
    List<bool>? dashedFlags,
  }) => _controller.showRoutes(routes, selectIndex: selectIndex,
          colors: colors, widths: widths, dashedFlags: dashedFlags);

  Future<bool> selectRoute(int index,
          {int selectedColor = 0xFFFF4D4F, int unselectedColor = 0x401890FF}) =>
      _controller.selectRoute(index,
          selectedColor: selectedColor, unselectedColor: unselectedColor);

  Future<bool> enterNavigationMode(int routeId) =>
      _controller.enterNavigationMode(routeId);

  Future<void> clearRoutes() => _controller.clearRoutes();

  Future<void> clearRouteOverlays() => _controller.clearRouteOverlays();

  Future<int?> showRoutesWithOverlay(List<int> routeIds, {int selectIndex = 0}) =>
      _controller.showRoutesWithOverlay(routeIds, selectIndex: selectIndex);

  Future<bool> highlightRouteOverlay(int routeId) =>
      _controller.highlightRouteOverlay(routeId);

  // ==================== 标记 ====================

  Future<bool> showSingleMarker({
    required double lat,
    required double lng,
    required bool isStart,
    String? label,
  }) => _controller.showSingleMarker(lat: lat, lng: lng, isStart: isStart, label: label);

  Future<bool> clearSingleMarker(bool isStart) =>
      _controller.clearSingleMarker(isStart);

  Future<bool> showStationMarkers(List<Map<String, dynamic>> stations) =>
      _controller.showStationMarkers(stations);

  Future<bool> clearStationMarkers() => _controller.clearStationMarkers();

  // ==================== 导航/车载 ====================

  Future<bool> updateCarMarker({
    required double lat,
    required double lng,
    double bearing = 0,
  }) => _controller.updateCarMarker(lat: lat, lng: lng, bearing: bearing);

  Future<bool> setFollowMode(bool enabled) =>
      _controller.setFollowMode(enabled);

  Future<bool> setLockCar(bool locked) =>
      _controller.setLockCar(locked);

  Future<bool> setLocationDotEnabled(bool enabled) =>
      _controller.setLocationDotEnabled(enabled);

  Future<bool> setCarOverlayVisible(bool visible) =>
      _controller.setCarOverlayVisible(visible);

  Future<bool> clearCarMarker() => _controller.clearCarMarker();

  // ==================== 地图图层 ====================

  Future<bool> setMapType(int type) => _controller.setMapType(type);
  Future<bool> setTrafficEnabled(bool enabled) =>
      _controller.setTrafficEnabled(enabled);
  Future<bool> setBuildingsEnabled(bool enabled) =>
      _controller.setBuildingsEnabled(enabled);
  Future<bool> showIndoorMap(bool enabled) => _controller.showIndoorMap(enabled);

  // ==================== 手势控制 ====================

  Future<bool> setScrollGesturesEnabled(bool enabled) =>
      _controller.setScrollGesturesEnabled(enabled);
  Future<bool> setZoomGesturesEnabled(bool enabled) =>
      _controller.setZoomGesturesEnabled(enabled);
  Future<bool> setRotateGesturesEnabled(bool enabled) =>
      _controller.setRotateGesturesEnabled(enabled);
  Future<bool> setTiltGesturesEnabled(bool enabled) =>
      _controller.setTiltGesturesEnabled(enabled);

  // ==================== 路线渲染样式 ====================

  Future<bool> setRouteTmcEnabled(bool enabled) =>
      _controller.setRouteTmcEnabled(enabled);
  Future<bool> setRouteTrafficIconEnabled(bool enabled) =>
      _controller.setRouteTrafficIconEnabled(enabled);
  Future<bool> updateSelectedRouteStyle({
    int? selectedColor,
    int? unselectedColor,
    double? selectedWidth,
    double? unselectedWidth,
  }) => _controller.updateSelectedRouteStyle(
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          selectedWidth: selectedWidth,
          unselectedWidth: unselectedWidth);

  // ==================== AMapNaviView 生命周期 ====================

  /// 暂停 AMapNaviView（对应 Activity.onPause）
  Future<void> pauseNaviView() => _controller.pauseNaviView();

  /// 恢复 AMapNaviView（对应 Activity.onResume）
  Future<void> resumeNaviView() => _controller.resumeNaviView();

  /// 设置导航视图显示模式
  /// 1=锁车态 2=全览态 3=普通态
  Future<void> setNaviShowMode(int mode) => _controller.setNaviShowMode(mode);

  /// 启用导航模式：显示完整 SDK 导航 UI，自动绘制路线
  Future<void> enableNaviMode() => _controller.enableNaviMode();

  /// 禁用导航模式：隐藏导航 UI，仅显示地图
  Future<void> disableNaviMode() => _controller.disableNaviMode();
}
