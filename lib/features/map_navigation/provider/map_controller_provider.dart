import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/models/location/lat_lng.dart';
import '../service/map_controller_service.dart';

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
    List<List<LatLng>> routes, {
    int selectIndex = 0,
    List<int>? colors,
    List<double>? widths,
    List<int>? routeIds,
  }) async {
    return await state?.showRoutes(routes, selectIndex: selectIndex, colors: colors, widths: widths, routeIds: routeIds);
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

}

final mapControllerNotifierProvider = NotifierProvider<MapControllerNotifier, MapControllerService?>(() {
  return MapControllerNotifier();
});
