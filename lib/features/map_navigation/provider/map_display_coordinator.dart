import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/utils/logger.dart';
import '../models/amap_routing_models.dart';
import '../models/map_overlay_models.dart';
import 'location_input_provider.dart';
import 'map_controller_provider.dart';

class MapDisplayCoordinator {
  MapControllerNotifier get _notifier => _ref.read(mapControllerNotifierProvider.notifier);
  final Ref _ref;

  MapDisplayCoordinator(this._ref);

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
          _notifier.moveCameraToCenter(
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
          _notifier.moveCameraToCenter(
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

    final routeDataList = <Map<String, dynamic>>[];
    final segmentColors = <int>[];
    final segmentWidths = <double>[];
    final segmentDashed = <bool>[];

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final typeLabel = seg.segmentType == 0 ? '步行' : (seg.segmentType == 1 ? '公交' : '地铁');
      if (seg.points.isEmpty) {
        Logs.map.warning('⚠️ 渲染侧 segment [$typeLabel] points 为空，跳过渲染');
        continue;
      }
      if (seg.points.length <= 2) {
        Logs.map.warning('⚠️ 渲染侧 segment [$typeLabel] points 仅 ${seg.points.length} 个，可能渲染为直线');
      } else {
        Logs.map.debug('✅ 渲染侧 segment [$typeLabel] points 共 ${seg.points.length} 个');
      }

      final polyline = seg.points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
      routeDataList.add({'polyline': polyline, 'routeId': i});
      segmentColors.add(_segmentColor(seg));
      segmentWidths.add(_segmentWidth(seg));
      segmentDashed.add(seg.segmentType == 0);

      if (i < segments.length - 1) {
        final nextSeg = segments[i + 1];
        if (nextSeg.points.isNotEmpty &&
            !_pointsNear(seg.points.last, nextSeg.points.first)) {
          final gapPolyline = [
            {'lat': seg.points.last.latitude, 'lng': seg.points.last.longitude},
            {'lat': nextSeg.points.first.latitude, 'lng': nextSeg.points.first.longitude}
          ];
          routeDataList.add({'polyline': gapPolyline, 'routeId': -1});
          segmentColors.add(RouteColors.transitWalk);
          segmentWidths.add(_walkWidth);
          segmentDashed.add(true);
        }
      }
    }

    if (routeDataList.isEmpty) return;

    await _notifier.showRoutes(
      routeDataList,
      selectIndex: 0,
      colors: segmentColors,
      widths: segmentWidths,
      dashedFlags: segmentDashed,
    );
  }

  static bool _pointsNear(LatLng a, LatLng b) {
    const double epsilon = 1e-5;
    return (a.latitude - b.latitude).abs() < epsilon &&
        (a.longitude - b.longitude).abs() < epsilon;
  }

  Future<void> _drawFlatRoutes(
    List<RouteOption> routes,
    int selectedIndex,
    RouteType routeType,
  ) async {
    final routeDataList = routes.map((r) {
      final polyline = r.points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
      return {'polyline': polyline, 'routeId': r.routeId};
    }).toList();
    final colors = routes.map((r) => RouteColors.getColor(r.routeType)).toList();

    await _notifier.showRoutes(
      routeDataList,
      selectIndex: selectedIndex,
      colors: colors,
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

final mapDisplayCoordinatorProvider = Provider<MapDisplayCoordinator>((ref) {
  return MapDisplayCoordinator(ref);
});