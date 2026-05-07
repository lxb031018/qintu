import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/map_controller_service/map_controller_service.dart';

final mapControllerProvider = Provider<MapControllerService?>((ref) {
  final controller = MapControllerService();
  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});

class MapControllerNotifier extends Notifier<MapControllerService?> {
  @override
  MapControllerService? build() => null;

  void setController(MapControllerService controller) {
    state = controller;
  }

  Future<void> moveCamera({required double lat, required double lng, double zoom = 15.0}) async {
    await state?.moveCamera(lat: lat, lng: lng, zoom: zoom);
  }

  Future<int?> showRoutes(
    List<Map<String, dynamic>> routes, {
    int selectIndex = 0,
    List<int>? colors,
    List<double>? widths,
    List<bool>? dashedFlags,
  }) async {
    return await state?.showRoutes(routes, selectIndex: selectIndex,
        colors: colors, widths: widths, dashedFlags: dashedFlags);
  }

  Future<bool> selectRoute(
    int index, {
    int selectedColor = 0xFFFF4D4F,
    int unselectedColor = 0x401890FF,
  }) async {
    return await state?.selectRoute(index, selectedColor: selectedColor, unselectedColor: unselectedColor) ?? false;
  }

  Future<bool> enterNavigationMode(int routeId) async {
    return await state?.enterNavigationMode(routeId) ?? false;
  }

  Future<void> clearRoutes() async {
    await state?.clearRoutes();
  }

  Future<void> clearRouteOverlays() async {
    await state?.clearRouteOverlays();
  }

  Future<void> moveToMyLocation() async {
    await state?.moveToMyLocation();
  }

  Future<int?> showRoutesWithOverlay(List<int> routeIds, {int selectIndex = 0}) async {
    return await state?.showRoutesWithOverlay(routeIds, selectIndex: selectIndex);
  }

  Future<bool> highlightRouteOverlay(int routeId) async {
    return await state?.highlightRouteOverlay(routeId) ?? false;
  }

  Future<bool> showSingleMarker({
    required double lat,
    required double lng,
    required bool isStart,
    String? label,
  }) async {
    return await state?.showSingleMarker(lat: lat, lng: lng, isStart: isStart, label: label) ?? false;
  }

  Future<bool> clearSingleMarker(bool isStart) async {
    return await state?.clearSingleMarker(isStart) ?? false;
  }

  Future<bool> showStationMarkers(List<Map<String, dynamic>> stations) async {
    return await state?.showStationMarkers(stations) ?? false;
  }

  Future<bool> clearStationMarkers() async {
    return await state?.clearStationMarkers() ?? false;
  }

  Future<void> setNaviShowMode(int mode) async {
    await state?.setNaviShowMode(mode);
  }

  Future<void> setPointToCenter({required int x, required int y}) async {
    await state?.setPointToCenter(x: x, y: y);
  }

  Future<void> changeLatLng({required double lat, required double lng}) async {
    await state?.changeLatLng(lat: lat, lng: lng);
  }

  Future<void> moveCameraToCenter({required double lat, required double lng, double zoom = 15.0}) async {
    await state?.moveCameraToCenter(lat: lat, lng: lng, zoom: zoom);
  }

  Future<void> animateCameraToCenter({required double lat, required double lng, double zoom = 15.0, int duration = 500}) async {
    await state?.animateCameraToCenter(lat: lat, lng: lng, zoom: zoom, duration: duration);
  }
}

final mapControllerNotifierProvider = NotifierProvider<MapControllerNotifier, MapControllerService?>(() {
  return MapControllerNotifier();
});
