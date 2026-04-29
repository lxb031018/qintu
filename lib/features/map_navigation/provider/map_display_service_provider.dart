import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/amap_routing_models.dart';
import '../models/map_overlay_models.dart';
import 'location_input_provider.dart';
import 'map_controller_provider.dart';

class MapDisplayService {
  MapControllerNotifier get _notifier => _ref.read(mapControllerNotifierProvider.notifier);
  final Ref _ref;

  MapDisplayService(this._ref);

  void handleLocationInputChange(
    LocationInputState? previous,
    LocationInputState next,
  ) {
    if (next.origin.poi != previous?.origin.poi) {
      if (next.origin.poi != null) {
        final latlng = next.origin.poi!.latLng;
        if (latlng != null) {
          _notifier.showSingleMarker(
            lat: latlng.latitude,
            lng: latlng.longitude,
            isStart: true,
            label: next.origin.poi!.name,
          );
          _notifier.moveCamera(
            lat: latlng.latitude,
            lng: latlng.longitude,
            zoom: 17,
          );
        }
      } else {
        _notifier.clearSingleMarker(true);
        _notifier.clearRoutes();
      }
    }

    if (next.destination.poi != previous?.destination.poi) {
      if (next.destination.poi != null) {
        final latlng = next.destination.poi!.latLng;
        if (latlng != null) {
          _notifier.showSingleMarker(
            lat: latlng.latitude,
            lng: latlng.longitude,
            isStart: false,
            label: next.destination.poi!.name,
          );
          _notifier.moveCamera(
            lat: latlng.latitude,
            lng: latlng.longitude,
            zoom: 17,
          );
        }
      } else {
        _notifier.clearSingleMarker(false);
        _notifier.clearRoutes();
      }
    }
  }

  Future<void> showRoutes(
    List<RouteOption> routes,
    int selectedIndex,
    RouteType routeType,
  ) async {
    if (routes.isEmpty) return;

    final routePoints = routes.map((r) => r.points).toList();
    final colors = routes.map((r) => RouteColors.getColor(r.routeType)).toList();

    await _notifier.showRoutes(
      routePoints,
      selectIndex: selectedIndex,
      colors: colors,
    );
  }

  Future<void> clearRoutes() async {
    await _notifier.clearRoutes();
  }
}

final mapDisplayServiceProvider = Provider<MapDisplayService>((ref) {
  return MapDisplayService(ref);
});