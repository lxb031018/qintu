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

    // 公交路线：按 segment 拆分渲染（步行=灰, 公交=蓝, 地铁=红）
    if (routeType == RouteType.transit && routes.first.transitSegments != null) {
      await _showTransitSegments(routes, selectedIndex);
      return;
    }

    _drawFlatRoutes(routes, selectedIndex, routeType);
  }

  Future<void> _drawFlatRoutes(
    List<RouteOption> routes,
    int selectedIndex,
    RouteType routeType,
  ) async {
    final routePoints = routes.map((r) => r.points).toList();
    final colors = routes.map((r) => RouteColors.getColor(r.routeType)).toList();
    final routeIds = routes.map((r) => r.routeId).where((id) => id >= 0).toList();

    await _notifier.showRoutes(
      routePoints,
      selectIndex: selectedIndex,
      colors: colors,
      routeIds: routeIds.isNotEmpty ? routeIds : null,
    );
  }

  Future<void> _showTransitSegments(
    List<RouteOption> routes,
    int selectedIndex,
  ) async {
    final allSegmentPoints = <List<LatLng>>[];
    final allSegmentColors = <int>[];

    for (int ri = 0; ri < routes.length; ri++) {
      final segments = routes[ri].transitSegments;
      if (segments == null) continue;

      final isSelected = ri == selectedIndex;
      final dimmed = isSelected ? 1.0 : 0.3;

      for (final seg in segments) {
        if (seg.points.isEmpty) continue;
        final baseColor = _segmentColor(seg);
        allSegmentPoints.add(seg.points);
        allSegmentColors.add(_dimColor(baseColor, dimmed));
      }
    }

    // 无任何分段数据时回退扁平渲染
    if (allSegmentPoints.isEmpty) {
      _drawFlatRoutes(routes, selectedIndex, RouteType.transit);
      return;
    }

    await _notifier.showRoutes(
      allSegmentPoints,
      selectIndex: 0,
      colors: allSegmentColors,
    );
  }

  static int _segmentColor(TransitSegment seg) {
    switch (seg.segmentType) {
      case 1:
        return RouteColors.transitBus;
      case 2:
        return RouteColors.transitSubway;
      default:
        return RouteColors.transitWalk;
    }
  }

  static int _dimColor(int color, double factor) {
    final a = ((color >> 24) & 0xFF) * factor;
    final r = (color >> 16) & 0xFF;
    final g = (color >> 8) & 0xFF;
    final b = color & 0xFF;
    return (a.toInt() << 24) | (r << 16) | (g << 8) | b;
  }

  Future<void> clearRoutes() async {
    await _notifier.clearRoutes();
  }
}

final mapDisplayServiceProvider = Provider<MapDisplayService>((ref) {
  return MapDisplayService(ref);
});