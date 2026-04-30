import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/models/location/lat_lng.dart';
import '../core/amap_map_controller.dart';
import '../models/amap_routing_models.dart';
import '../models/map_overlay_models.dart';

final mapControllerProvider = Provider<AmapMapController?>((ref) {
  ref.onDispose(() {
    // Provider 销毁时清理 controller
  });
  return null;
});

class MapControllerNotifier extends Notifier<AmapMapController?> {
  @override
  AmapMapController? build() => null;

  void setController(AmapMapController controller) {
    state = controller;
  }

  void clearController() {
    state = null;
  }

  Future<void> startLocation({bool autoMoveToFirstLocation = true}) async {
    await state?.startLocation(autoMoveToFirstLocation: autoMoveToFirstLocation);
  }

  Future<void> moveToMyLocation() async {
    await state?.moveToMyLocation();
  }

  Future<Map<String, dynamic>?> getCurrentLocation() async {
    return await state?.getCurrentLocation();
  }

  Future<void> moveCamera({required double lat, required double lng, double zoom = 15.0}) async {
    await state?.moveCamera(lat: lat, lng: lng, zoom: zoom);
  }

  Future<void> addPolyline(List<LatLng> points, {int color = 0xFF1890FF, double width = 8.0}) async {
    await state?.addPolyline(points, color: color, width: width);
  }

  Future<int?> showRoutes(
    List<List<LatLng>> routes, {
    int selectIndex = 0,
    List<int>? colors,
    List<double>? widths,
  }) async {
    return await state?.showRoutes(routes, selectIndex: selectIndex, colors: colors, widths: widths);
  }

  Future<bool> selectRoute(
    int index, {
    int selectedColor = 0xFFFF4D4F,
    int unselectedColor = 0x401890FF,
  }) async {
    return await state?.selectRoute(index, selectedColor: selectedColor, unselectedColor: unselectedColor) ?? false;
  }

  Future<void> clearRoutes() async {
    await state?.clearRoutes();
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

  Future<bool> setRouteMarkers({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String? startLabel,
    String? endLabel,
  }) async {
    return await state?.setRouteMarkers(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      startLabel: startLabel,
      endLabel: endLabel,
    ) ?? false;
  }

  Future<bool> clearRouteMarkers() async {
    return await state?.clearRouteMarkers() ?? false;
  }

  Future<void> addPoiMarkers(List<PoiMarkerData> pois) async {
    await state?.addPoiMarkers(pois);
  }

  Future<void> clearPoiMarkers() async {
    await state?.clearPoiMarkers();
  }

  Future<void> setCarOverlayVisible(bool visible) async {
    await state?.setCarOverlayVisible(visible);
  }
}

final mapControllerNotifierProvider = NotifierProvider<MapControllerNotifier, AmapMapController?>(() {
  return MapControllerNotifier();
});