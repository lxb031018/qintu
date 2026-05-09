import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/features/map_navigation/widgets/route_result_bottom_sheet/transit_itinerary_card/color/subway_color_helper.dart';
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
    final stationDataList = <Map<String, dynamic>>[];

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

      // 构建站点数据
      _buildStationData(seg, stationDataList);

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

    // 显示站点标记
    if (stationDataList.isNotEmpty) {
      await _notifier.showStationMarkers(stationDataList);
    }
  }

  /// 从 BusTransitSegment 构建站点数据
  void _buildStationData(BusTransitSegment seg, List<Map<String, dynamic>> stations) {
    final segType = seg.segmentType;

    // 地铁站入口/出口
    if (seg.entrance != null) {
      stations.add({
        'lat': seg.entrance!.lat,
        'lng': seg.entrance!.lng,
        'name': seg.entrance!.name,
        'type': 'subway_entrance',
      });
    }
    if (seg.exit != null) {
      stations.add({
        'lat': seg.exit!.lat,
        'lng': seg.exit!.lng,
        'name': seg.exit!.name,
        'type': 'subway_exit',
      });
    }

    // 公交/地铁线路站点
    if (seg.hasTransit) {
      final stationType = segType == 2 ? 'subway' : 'bus';

      // 起点站
      if (seg.departureStation != null && seg.departureStation!.isNotEmpty) {
        final startStation = _findStationByName(seg.passStations, seg.departureStation!);
        if (startStation != null) {
          stations.add({
            'lat': startStation.lat,
            'lng': startStation.lng,
            'name': seg.departureStation,
            'type': stationType,
          });
        }
      }

      // 途经站（只添加前几个，避免太多标记）
      if (seg.passStations != null && seg.passStations!.isNotEmpty) {
        final passCount = seg.passStations!.length > 5 ? 5 : seg.passStations!.length;
        for (int i = 0; i < passCount; i++) {
          final station = seg.passStations![i];
          stations.add({
            'lat': station.lat,
            'lng': station.lng,
            'name': station.name,
            'type': stationType,
          });
        }
      }

      // 终点站
      if (seg.arrivalStation != null && seg.arrivalStation!.isNotEmpty) {
        final endStation = _findStationByName(seg.passStations, seg.arrivalStation!);
        if (endStation != null) {
          stations.add({
            'lat': endStation.lat,
            'lng': endStation.lng,
            'name': seg.arrivalStation,
            'type': stationType,
          });
        }
      }
    }
  }

  /// 从站点列表中查找指定名称的站点
  BusLineStation? _findStationByName(List<BusLineStation>? stations, String name) {
    if (stations == null) return null;
    for (final station in stations) {
      if (station.name == name) return station;
    }
    return null;
  }

  /// 检查两个点是否足够接近
  ///
  /// [epsilon] 距离阈值（度数），默认 1e-5 约等于 1 米
  /// 对于步行段到公交段的连接，使用更大的阈值（约 50 米）
  static bool _pointsNear(LatLng a, LatLng b, {double? epsilon}) {
    final eps = epsilon ?? _defaultEpsilon;
    return (a.latitude - b.latitude).abs() < eps &&
        (a.longitude - b.longitude).abs() < eps;
  }

  /// 默认距离阈值：约 1 米（1e-5 度）
  static const double _defaultEpsilon = 1e-5;

  /// 步行到公交/地铁连接的阈值：约 50 米
  static const double _walkToTransitEpsilon = 5e-4;

  /// 检查步行段终点与下一公交段起点是否连接
  static bool _walkToTransitConnected(LatLng walkEnd, LatLng transitStart) {
    // 步行段终点到公交段起点的检查使用更大的阈值
    return _pointsNear(walkEnd, transitStart, epsilon: _walkToTransitEpsilon);
  }

  /// 检查公交段终点与下一步行段起点是否连接
  static bool _transitToWalkConnected(LatLng transitEnd, LatLng walkStart) {
    return _pointsNear(transitEnd, walkStart, epsilon: _walkToTransitEpsilon);
  }

  /// 检查两个连续公交段是否直接连接（换乘）
  static bool _transitToTransitConnected(LatLng firstEnd, LatLng secondStart) {
    // 公交到公交的换乘使用更小的阈值，因为公交站点是精确的
    return _pointsNear(firstEnd, secondStart, epsilon: _defaultEpsilon);
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

  static int _segmentColor(BusTransitSegment seg) {
    switch (seg.segmentType) {
      case 1:
        return RouteColors.transitBus;
      case 2:
        return SubwayColorHelper.getSubwayColor(seg.lineName, seg.cityCode).toARGB32();
      default:
        return RouteColors.transitWalk;
    }
  }

  static double _segmentWidth(BusTransitSegment seg) {
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
    await _notifier.clearStationMarkers();
  }
}

final mapDisplayCoordinatorProvider = Provider<MapDisplayCoordinator>((ref) {
  return MapDisplayCoordinator(ref);
});