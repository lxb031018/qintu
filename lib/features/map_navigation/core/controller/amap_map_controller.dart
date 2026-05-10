import 'package:flutter/foundation.dart';
import 'location_controller.dart';
import 'route_controller.dart';
import 'marker_controller.dart';
import 'camera_controller.dart';
import 'gesture_controller.dart';
import 'navi_view_controller.dart';

class AmapMapController {
  final LocationController locationController = LocationController();
  final RouteController routeController = RouteController();
  final MarkerController markerController = MarkerController();
  final CameraController cameraController = CameraController();
  final GestureController gestureController = GestureController();
  final NaviViewController naviViewController = NaviViewController();

  void setOnNaviViewExitListener(VoidCallback? listener) {
    locationController.setOnNaviViewExitListener(listener);
  }

  void dispose() {
    locationController.dispose();
  }

  String? get lastKnownCity => locationController.lastKnownCity;

  // ==================== 定位代理 ====================

  Future<void> startLocation({bool autoMoveToFirstLocation = true}) =>
      locationController.startLocation(autoMoveToFirstLocation: autoMoveToFirstLocation);

  Future<void> moveToMyLocation() => locationController.moveToMyLocation();

  Future<Map<String, dynamic>?> getCurrentLocation() =>
      locationController.getCurrentLocation();

  Future<Map<String, dynamic>?> getLastKnownLocation() =>
      locationController.getLastKnownLocation();

  // ==================== 路线代理 ====================

  Future<int?> showRoutes(
    List<Map<String, dynamic>> routes, {
    int selectIndex = 0,
    List<int>? colors,
    List<double>? widths,
    List<bool>? dashedFlags,
  }) =>
      routeController.showRoutes(routes, selectIndex: selectIndex,
          colors: colors, widths: widths, dashedFlags: dashedFlags);

  Future<bool> selectRoute(int index,
          {int selectedColor = 0xFFFF4D4F, int unselectedColor = 0x401890FF}) =>
      routeController.selectRoute(index,
          selectedColor: selectedColor, unselectedColor: unselectedColor);

  Future<bool> enterNavigationMode(int routeId) =>
      routeController.enterNavigationMode(routeId);

  Future<void> clearRoutes() => routeController.clearRoutes();

  Future<void> clearRouteOverlays() => routeController.clearRouteOverlays();

  Future<int?> showRoutesWithOverlay(List<int> routeIds, {int selectIndex = 0}) =>
      routeController.showRoutesWithOverlay(routeIds, selectIndex: selectIndex);

  Future<bool> highlightRouteOverlay(int routeId) =>
      routeController.highlightRouteOverlay(routeId);

  // ==================== 标记代理 ====================

  Future<bool> setRouteMarkers({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String? startLabel,
    String? endLabel,
  }) =>
      markerController.setRouteMarkers(
          startLat: startLat,
          startLng: startLng,
          endLat: endLat,
          endLng: endLng,
          startLabel: startLabel,
          endLabel: endLabel);

  Future<bool> clearRouteMarkers() => markerController.clearRouteMarkers();

  Future<bool> showSingleMarker({
    required double lat,
    required double lng,
    required bool isStart,
    String? label,
  }) =>
      markerController.showSingleMarker(lat: lat, lng: lng, isStart: isStart, label: label);

  Future<bool> clearSingleMarker(bool isStart) =>
      markerController.clearSingleMarker(isStart);

  Future<bool> showStationMarkers(List<Map<String, dynamic>> stations) =>
      markerController.showStationMarkers(stations);

  Future<bool> clearStationMarkers() => markerController.clearStationMarkers();

  // ==================== 相机代理 ====================

  Future<void> moveCamera({
    required double lat,
    required double lng,
    double zoom = 15.0,
  }) =>
      cameraController.moveCamera(lat: lat, lng: lng, zoom: zoom);

  Future<bool> animateCamera({
    required double lat,
    required double lng,
    double zoom = 15.0,
    double bearing = -1,
    double tilt = -1,
    int duration = 0,
  }) =>
      cameraController.animateCamera(lat: lat, lng: lng, zoom: zoom,
          bearing: bearing, tilt: tilt, duration: duration);

  Future<void> zoomIn() => cameraController.zoomIn();
  Future<void> zoomOut() => cameraController.zoomOut();
  Future<void> zoomTo(double level, {int duration = 0}) =>
      cameraController.zoomTo(level, duration: duration);

  Future<void> setPointToCenter({required int x, required int y}) =>
      cameraController.setPointToCenter(x: x, y: y);

  Future<void> changeLatLng({required double lat, required double lng}) =>
      cameraController.changeLatLng(lat: lat, lng: lng);

  Future<void> moveCameraToCenter({
    required double lat,
    required double lng,
    double zoom = 15.0,
  }) =>
      cameraController.moveCameraToCenter(lat: lat, lng: lng, zoom: zoom);

  Future<void> animateCameraToCenter({
    required double lat,
    required double lng,
    double zoom = 15.0,
    int duration = 500,
  }) =>
      cameraController.animateCameraToCenter(lat: lat, lng: lng, zoom: zoom, duration: duration);

  Future<void> animateCameraToBounds(
    List<Map<String, double>> points, {
    int padding = 100,
    int duration = 800,
  }) =>
      cameraController.animateCameraToBounds(points, padding: padding, duration: duration);

  // ==================== 手势代理 ====================

  Future<bool> setScrollGesturesEnabled(bool enabled) =>
      gestureController.setScrollGesturesEnabled(enabled);

  Future<bool> setZoomGesturesEnabled(bool enabled) =>
      gestureController.setZoomGesturesEnabled(enabled);

  Future<bool> setRotateGesturesEnabled(bool enabled) =>
      gestureController.setRotateGesturesEnabled(enabled);

  Future<bool> setTiltGesturesEnabled(bool enabled) =>
      gestureController.setTiltGesturesEnabled(enabled);

  // ==================== 导航/车载代理 ====================

  Future<bool> updateCarMarker({
    required double lat,
    required double lng,
    double bearing = 0,
  }) =>
      naviViewController.updateCarMarker(lat: lat, lng: lng, bearing: bearing);

  Future<bool> setFollowMode(bool enabled) =>
      naviViewController.setFollowMode(enabled);

  Future<bool> setLockCar(bool locked) =>
      naviViewController.setLockCar(locked);

  Future<bool> setLocationDotEnabled(bool enabled) =>
      naviViewController.setLocationDotEnabled(enabled);

  Future<bool> setCarOverlayVisible(bool visible) =>
      naviViewController.setCarOverlayVisible(visible);

  Future<bool> clearCarMarker() => naviViewController.clearCarMarker();

  // ==================== 地图图层代理 ====================

  Future<bool> setMapType(int type) => naviViewController.setMapType(type);

  Future<bool> setTrafficEnabled(bool enabled) =>
      naviViewController.setTrafficEnabled(enabled);

  Future<bool> setBuildingsEnabled(bool enabled) =>
      naviViewController.setBuildingsEnabled(enabled);

  Future<bool> showIndoorMap(bool enabled) => naviViewController.showIndoorMap(enabled);

  // ==================== 路线渲染样式代理 ====================

  Future<bool> setRouteTmcEnabled(bool enabled) =>
      naviViewController.setRouteTmcEnabled(enabled);

  Future<bool> setRouteTrafficIconEnabled(bool enabled) =>
      naviViewController.setRouteTrafficIconEnabled(enabled);

  Future<bool> updateSelectedRouteStyle({
    int? selectedColor,
    int? unselectedColor,
    double? selectedWidth,
    double? unselectedWidth,
  }) =>
      naviViewController.updateSelectedRouteStyle(
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          selectedWidth: selectedWidth,
          unselectedWidth: unselectedWidth);

  // ==================== AMapNaviView 生命周期代理 ====================

  Future<void> pauseNaviView() => naviViewController.pauseNaviView();

  Future<void> resumeNaviView() => naviViewController.resumeNaviView();

  Future<void> setNaviShowMode(int mode) => naviViewController.setNaviShowMode(mode);

  Future<void> enableNaviMode() => naviViewController.enableNaviMode();

  Future<void> disableNaviMode() => naviViewController.disableNaviMode();
}