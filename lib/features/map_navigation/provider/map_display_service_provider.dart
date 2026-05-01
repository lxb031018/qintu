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

    // 公交路线：列表页使用扁平渲染（统一紫色），详情页另行调用 showTransitRouteDetail
    if (routeType == RouteType.transit) {
      _drawFlatRoutes(routes, selectedIndex, routeType);
      return;
    }

    _drawFlatRoutes(routes, selectedIndex, routeType);
  }

  /// 公交路线详情页：仅渲染所选路线的分段样式（步行虚线、公交蓝、地铁红）
  Future<void> showTransitRouteDetail(RouteOption route) async {
    final segments = route.transitSegments;
    if (segments == null || segments.isEmpty) return;

    final segmentPoints = <List<LatLng>>[];
    final segmentColors = <int>[];
    final segmentWidths = <double>[];
    final segmentDashed = <bool>[];

    for (final seg in segments) {
      if (seg.points.isEmpty) continue;
      segmentPoints.add(seg.points);
      segmentColors.add(_segmentColor(seg));
      segmentWidths.add(_segmentWidth(seg));
      segmentDashed.add(seg.segmentType == 0);
    }

    if (segmentPoints.isEmpty) return;

    await _notifier.showRoutes(
      segmentPoints,
      selectIndex: 0,
      colors: segmentColors,
      widths: segmentWidths,
      dashedFlags: segmentDashed,
    );
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

  static const double _walkWidth = 8.0;
  static const double _busWidth = 12.0;
  static const double _subwayWidth = 14.0;

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

  static double _segmentWidth(TransitSegment seg) {
    switch (seg.segmentType) {
      case 1:
        return _busWidth;
      case 2:
        return _subwayWidth;
      default:
        return _walkWidth;
    }
  }

  Future<void> clearRoutes() async {
    await _notifier.clearRoutes();
  }
}

final mapDisplayServiceProvider = Provider<MapDisplayService>((ref) {
  return MapDisplayService(ref);
});