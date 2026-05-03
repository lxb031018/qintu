import 'package:flutter/services.dart';
import 'package:qintu/core/constants/platform_channels.dart';
import 'package:qintu/utils/logger.dart';
import '../models/amap_bus_models.dart';
import '../models/amap_routing_models.dart';

export '../models/amap_bus_models.dart';

/// 高德公交搜索桥接层
///
/// 通过 Platform Channel 调用 Android 原生 BusStationSearch / BusLineSearch
/// 返回的数据模型已在 amap_bus_models.dart 中定义
///
/// 使用方式：
/// ```dart
/// // 搜索公交站
/// final result = await AmapBusSearchBridge.searchBusStation('公交', city: '北京');
/// // result.stations → BusStationInfo 列表（含途经线路简版）
///
/// // 搜索公交线路（按名称）
/// final lines = await AmapBusSearchBridge.searchBusLineByName('100', city: '北京');
/// // lines.lines → BusLineDetail 列表（含站点+坐标）
///
/// // 查询线路详情（按ID）
/// final detail = await AmapBusSearchBridge.searchBusLineById('xxx', city: '北京');
/// /// detail → BusLineDetail（含全部站点+polyline坐标）
/// ```
class AmapBusSearchBridge {
  static const _methodChannel = MethodChannel(PlatformChannels.busSearch);

  /// 原生公交路径规划（使用 RouteSearchV2.calculateBusRouteAsyn）
  ///
  /// [origin] 起点坐标
  /// [destination] 终点坐标
  /// [city] 城市名称/编码
  /// [mode] 策略: 0=最快捷, 1=最少换乘, 2=最少步行, 3=不乘地铁, 4=最舒适, 5=最经济
  static Future<List<RouteOption>> planTransitRoute({
    required LatLng origin,
    required LatLng destination,
    required String city,
    int mode = 0,
    int maxTrans = 3,
    int alternativeRoute = 1,
    String? time,
    String? timeType,
    String? destCity,
  }) async {
    try {
      Logs.ui.info('🚌 原生公交算路: ($origin → $destination), city=$city, mode=$mode');
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'calculateTransitRoute',
        {
          'fromLat': origin.latitude,
          'fromLng': origin.longitude,
          'toLat': destination.latitude,
          'toLng': destination.longitude,
          'city': city,
          'mode': mode,
          'maxTrans': maxTrans,
          'alternativeRoute': alternativeRoute,
          if (time != null) 'time': time,
          if (timeType != null) 'timeType': timeType,
          if (destCity != null) 'destCity': destCity,
        },
      );

      if (result == null) {
        Logs.ui.warning('⚠️ 原生公交算路返回为空');
        return [];
      }

      final paths = result['paths'] as List<dynamic>? ?? [];
      final taxiCost = (result['taxiCost'] as num?)?.toDouble();
      Logs.ui.info('✅ 原生公交算路: ${paths.length} 条方案');
      final routes = paths
          .map((p) => _parseTransitPath(p as Map<dynamic, dynamic>, mode: mode, taxiCost: taxiCost))
          .toList();
      return routes.expand((r) => _explodeAlternatives(r)).toList();
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 原生公交算路失败: ${e.message}');
      return [];
    } catch (e) {
      Logs.ui.warning('❌ 原生公交算路异常: $e');
      return [];
    }
  }

  static RouteOption _parseTransitPath(Map<dynamic, dynamic> path, {int mode = 0, double? taxiCost}) {
    final steps = (path['steps'] as List<dynamic>?) ?? [];

    final transitSegments = <TransitSegment>[];

    // 从独立字段读取起终点坐标（不再从 polyline 首尾提取单点）
    final startPoint = path['startPoint'] as Map<dynamic, dynamic>?;
    final endPoint = path['endPoint'] as Map<dynamic, dynamic>?;
    final userOrigin = startPoint != null
        ? LatLng(
            (startPoint['lat'] as num).toDouble(),
            (startPoint['lng'] as num).toDouble(),
          )
        : null;
    final userDest = endPoint != null
        ? LatLng(
            (endPoint['lat'] as num).toDouble(),
            (endPoint['lng'] as num).toDouble(),
          )
        : null;

    for (final step in steps) {
      if (step is! Map) continue;
      final stepMap = step;

      final walk = stepMap['walk'] as Map<dynamic, dynamic>?;
      final busLines = stepMap['busLines'] as List<dynamic>?;
      final railway = stepMap['railway'] as Map<dynamic, dynamic>?;

      var walkingDistance = 0;
      final segmentPoints = <LatLng>[];
      final lines = <TransitLine>[];

      // 步行部分 — 优先用步级 polyline（比路径级更详细）
      final parsedWalkSteps = <WalkStep>[];
      if (walk != null) {
        walkingDistance = ((walk['distance'] as num?)?.toDouble() ?? 0).round();
        final walkSteps = walk['steps'] as List<dynamic>?;
        if (walkSteps != null && walkSteps.isNotEmpty) {
          for (final ws in walkSteps) {
            if (ws is! Map) continue;
            final stepPolyline = ws['polyline'] as List<dynamic>? ?? [];
            final wsPoints = stepPolyline.map((p) => LatLng(
                  (p['lat'] as num).toDouble(),
                  (p['lng'] as num).toDouble(),
                )).toList();
            for (final p in stepPolyline) {
              segmentPoints.add(LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              ));
            }
            parsedWalkSteps.add(WalkStep(
              instruction: ws['instruction']?.toString() ?? '',
              road: ws['road']?.toString() ?? '',
              distance: (ws['distance'] as num?)?.toDouble() ?? 0,
              duration: (ws['duration'] as num?)?.toDouble() ?? 0,
              points: wsPoints,
            ));
          }
        } else {
          final walkPolyline = walk['polyline'] as List<dynamic>? ?? [];
          segmentPoints.addAll(walkPolyline.map((p) => LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              )));
        }
      }

      // 公交部分 — 所有线路加入 metadata，但只取第一条线路的 polyline 用于渲染
      // （多条线路是备选方案，由 _explodeAlternatives 拆分为独立 RouteOption，
      //   若全部 concat 会造成线路终点→下条起点之间的贯穿直线）
      if (busLines != null && busLines.isNotEmpty) {
        for (final bl in busLines) {
          if (bl is! Map) continue;
          final name = bl['name']?.toString() ?? '';
          final typeStr = bl['type']?.toString() ?? '';
          lines.add(TransitLine(
            name: name,
            type: _mapBusType(typeStr),
            stationCount: (bl['passStationNum'] as num?)?.toInt() ?? 0,
            departureStation: bl['departureStation']?.toString(),
            arrivalStation: bl['arrivalStation']?.toString(),
            duration: (bl['duration'] as num?)?.toDouble(),
            busLineId: bl['busLineId']?.toString(),
            basicPrice: (bl['basicPrice'] as num?)?.toDouble(),
            totalPrice: (bl['totalPrice'] as num?)?.toDouble(),
            firstBusTime: bl['firstBusTime']?.toString(),
            lastBusTime: bl['lastBusTime']?.toString(),
            originatingStation: bl['originatingStation']?.toString(),
            terminalStation: bl['terminalStation']?.toString(),
            busCompany: bl['busCompany']?.toString(),
            passStations: (bl['passStations'] as List<dynamic>?)
                ?.map((s) => BusLineStation.fromMap(s as Map<dynamic, dynamic>))
                .toList(),
          ));
        }

        // 仅取第一条线路的 polyline 渲染（备选线路的 polyline 在 _explodeAlternatives 中各自处理）
        final firstLine = busLines.first as Map<dynamic, dynamic>;
        final polyline = firstLine['polyline'] as List<dynamic>? ?? [];
        if (polyline.isEmpty) {
          Logs.map.warning('⚠️ Dart 侧公交线路 [${firstLine['name']}] polyline 为空');
        } else if (polyline.length <= 2) {
          Logs.map.warning('⚠️ Dart 侧公交线路 [${firstLine['name']}] polyline 仅 ${polyline.length} 个点，可能渲染为直线');
        } else {
          Logs.map.debug('✅ Dart 侧公交线路 [${firstLine['name']}] polyline 共 ${polyline.length} 个点');
        }
        for (final p in polyline) {
          segmentPoints.add(LatLng(
            (p['lat'] as num).toDouble(),
            (p['lng'] as num).toDouble(),
          ));
        }
      }

      // 地铁/铁路部分
      if (railway != null) {
        final name = railway['name']?.toString() ?? '';
        final stations = railway['stations'] as List<dynamic>? ?? [];
        // 解析详细站点
        final railwayStations = stations.map((s) {
          final sm = s as Map<dynamic, dynamic>;
          return RailwayStationDetail(
            id: sm['id']?.toString() ?? '',
            name: sm['name']?.toString() ?? '',
            lat: (sm['lat'] as num?)?.toDouble() ?? 0,
            lng: (sm['lng'] as num?)?.toDouble() ?? 0,
            time: sm['time']?.toString() ?? '',
            wait: (sm['wait'] as num?)?.toDouble() ?? 0,
            isStart: sm['isStart'] as bool? ?? false,
            isEnd: sm['isEnd'] as bool? ?? false,
          );
        }).toList();
        // 解析舱位/票价
        final spacesList = railway['spaces'] as List<dynamic>? ?? [];
        final spaces = spacesList.map((s) {
          final sm = s as Map<dynamic, dynamic>;
          return RailwaySpace(
            code: sm['code']?.toString() ?? '',
            cost: (sm['cost'] as num?)?.toDouble() ?? 0,
          );
        }).toList();
        if (name.isNotEmpty) {
          lines.add(TransitLine(
            name: name,
            type: TransitLineType.subway,
            stationCount: railwayStations.length,
            duration: (railway['time'] as num?)?.toDouble(),
            trip: railway['trip']?.toString(),
            railwayType: railway['type']?.toString(),
            railwayDistance: (railway['distance'] as num?)?.toDouble(),
            railwayStations: railwayStations.isNotEmpty ? railwayStations : null,
            spaces: spaces.isNotEmpty ? spaces : null,
          ));
        }
        // 用站点坐标拼地铁段 polyline
        segmentPoints.addAll(railwayStations.map((rs) => rs.latLng));
      }

      // 解析出入口
      StationEntrance? entrance;
      StationEntrance? exit;
      final entranceMap = stepMap['entrance'] as Map<dynamic, dynamic>?;
      if (entranceMap != null) {
        entrance = StationEntrance(
          name: entranceMap['name']?.toString() ?? '',
          lat: (entranceMap['lat'] as num?)?.toDouble() ?? 0,
          lng: (entranceMap['lng'] as num?)?.toDouble() ?? 0,
        );
      }
      final exitMap = stepMap['exit'] as Map<dynamic, dynamic>?;
      if (exitMap != null) {
        exit = StationEntrance(
          name: exitMap['name']?.toString() ?? '',
          lat: (exitMap['lat'] as num?)?.toDouble() ?? 0,
          lng: (exitMap['lng'] as num?)?.toDouble() ?? 0,
        );
      }

      // 解析打车段
      final taxiMap = stepMap['taxi'] as Map<dynamic, dynamic>?;
      TaxiSegment? taxi;
      if (taxiMap != null) {
        taxi = TaxiSegment(
          origin: taxiMap['origin'] != null
              ? LatLng(
                  (taxiMap['origin']['lat'] as num).toDouble(),
                  (taxiMap['origin']['lng'] as num).toDouble(),
                )
              : null,
          destination: taxiMap['destination'] != null
              ? LatLng(
                  (taxiMap['destination']['lat'] as num).toDouble(),
                  (taxiMap['destination']['lng'] as num).toDouble(),
                )
              : null,
          distance: (taxiMap['distance'] as num?)?.toDouble(),
          duration: (taxiMap['duration'] as num?)?.toDouble(),
          price: (taxiMap['price'] as num?)?.toDouble(),
          points: (taxiMap['polyline'] as List<dynamic>?)
                  ?.map((p) => LatLng(
                        (p['lat'] as num).toDouble(),
                        (p['lng'] as num).toDouble(),
                      ))
                  .toList() ??
              [],
        );
      }

      // 如果既有步行又有乘车，拆成两个 segment 以便分段渲染
      if (walkingDistance > 0 && lines.isNotEmpty) {
        final walkPtCount = _walkPointCount(walk);
        if (walkPtCount > 0 && walkPtCount < segmentPoints.length) {
          final walkPoints = List<LatLng>.of(segmentPoints.sublist(0, walkPtCount));
          final ridePoints = List<LatLng>.of(segmentPoints.sublist(walkPtCount));

          // 填充步行终点→乘车起点的间隙（防贯穿直线）
          if (walkPoints.isNotEmpty && ridePoints.isNotEmpty &&
              !_isNear(walkPoints.last, ridePoints.first)) {
            ridePoints.insert(0, walkPoints.last);
          }

          transitSegments.add(TransitSegment(
            lines: const [],
            walkingDistance: walkingDistance,
            points: walkPoints,
            walkSteps: parsedWalkSteps.isNotEmpty ? parsedWalkSteps : null,
          ));
          transitSegments.add(TransitSegment(
            lines: lines,
            walkingDistance: 0,
            points: ridePoints,
            entrance: entrance,
            exit: exit,
            taxi: taxi,
          ));
        } else {
          // 无法准确拆分时，整体作为一个 segment
          transitSegments.add(TransitSegment(
            lines: lines,
            walkingDistance: walkingDistance,
            points: segmentPoints,
            entrance: entrance,
            exit: exit,
            walkSteps: parsedWalkSteps.isNotEmpty ? parsedWalkSteps : null,
            taxi: taxi,
          ));
        }
      } else if (lines.isNotEmpty || walkingDistance > 0) {
        transitSegments.add(TransitSegment(
          lines: lines,
          walkingDistance: walkingDistance,
          points: segmentPoints,
          entrance: entrance,
          exit: exit,
          walkSteps: parsedWalkSteps.isNotEmpty ? parsedWalkSteps : null,
          taxi: taxi,
        ));
      }
    }

    // 填充 step 间的间隙（如 bus 终点→下一段 walk 起点），再拼接完整路线
    _fillSegmentGaps(transitSegments);

    final allPoints = <LatLng>[];
    for (final seg in transitSegments) {
      if (seg.points.isEmpty) continue;
      if (allPoints.isNotEmpty && !_isNear(allPoints.last, seg.points.first)) {
        allPoints.add(seg.points.first);
      }
      // 跳过与上一条重合的首点
      final start = (allPoints.isEmpty || !_isNear(allPoints.last, seg.points.first)) ? 0 : 1;
      if (start < seg.points.length) {
        allPoints.addAll(start == 0 ? seg.points : seg.points.sublist(start));
      }
    }

    return RouteOption(
      distance: (path['distance'] as num?)?.toDouble() ?? 0,
      duration: (path['duration'] as num?)?.toDouble() ?? 0,
      strategy: '公共交通',
      tolls: (path['cost'] as num?)?.toDouble() ?? 0,
      points: allPoints,
      routeType: RouteType.transit,
      transitSegments: transitSegments,
      userOrigin: userOrigin,
      userDest: userDest,
      walkDistance: (path['walkDistance'] as num?)?.toDouble(),
      busDistance: (path['busDistance'] as num?)?.toDouble(),
      isNightBus: path['isNightBus'] as bool?,
      taxiCost: taxiCost,
      strategyMode: mode,
    );
  }

  /// 将含多条线路的 step 拆分为独立的 RouteOption（每条线路一个）
  ///
  /// AMap API 返回的一个 step 中可能包含多条可选线路（如 0路/1路/2路都能直达），
  /// 该方法将每条线路拆分为独立的 RouteOption，使列表页每线路一个卡片。
  static List<RouteOption> _explodeAlternatives(RouteOption route) {
    final segments = route.transitSegments;
    if (segments == null || segments.isEmpty) return [route];

    // 找到第一个含多条线路的乘车段
    var multiLineIdx = -1;
    for (int i = 0; i < segments.length; i++) {
      if (segments[i].lines.length > 1) {
        multiLineIdx = i;
        break;
      }
    }

    if (multiLineIdx == -1) return [route];

    // 为每条线路创建独立的 RouteOption
    final seg = segments[multiLineIdx];
    return seg.lines.map((line) {
      final newSegments = segments.map((s) {
        if (identical(s, seg)) {
          return TransitSegment(
            lines: [line],
            walkingDistance: s.walkingDistance,
            points: s.points, // 复用首个线路的 polyline（备选线路 polyline 未单独存储）
            entrance: s.entrance,
            exit: s.exit,
            walkSteps: s.walkSteps,
            taxi: s.taxi,
          );
        }
        return s;
      }).toList();

      // 从 newSegments 重建 allPoints（含间隙填充），避免复用 route.points 里旧的首线 polyline
      final newAllPoints = <LatLng>[];
      for (final s in newSegments) {
        if (s.points.isEmpty) continue;
        if (newAllPoints.isNotEmpty && !_isNear(newAllPoints.last, s.points.first)) {
          newAllPoints.add(s.points.first);
        }
        final start = (newAllPoints.isEmpty || !_isNear(newAllPoints.last, s.points.first)) ? 0 : 1;
        if (start < s.points.length) {
          newAllPoints.addAll(start == 0 ? s.points : s.points.sublist(start));
        }
      }

      return RouteOption(
        distance: route.distance,
        duration: route.duration,
        strategy: '${line.typeText}${line.name}',
        tolls: line.totalPrice ?? route.tolls,
        points: newAllPoints,
        routeType: RouteType.transit,
        transitSegments: newSegments,
        walkDistance: route.walkDistance,
        busDistance: route.busDistance,
        isNightBus: route.isNightBus,
        taxiCost: route.taxiCost,
        strategyMode: route.strategyMode,
      );
    }).toList();
  }

  /// 判断两个坐标是否足够接近（~1 米），用于检测路段间是否需要填充连接点
  static bool _isNear(LatLng a, LatLng b) {
    const double epsilon = 1e-5;
    return (a.latitude - b.latitude).abs() < epsilon &&
        (a.longitude - b.longitude).abs() < epsilon;
  }

  /// 填充相邻 segment 间的间隙：若前一段终点 ≠ 后一段起点，插入连接点
  static void _fillSegmentGaps(List<TransitSegment> segments) {
    for (int i = 0; i < segments.length - 1; i++) {
      final cur = segments[i];
      final next = segments[i + 1];
      if (cur.points.isEmpty || next.points.isEmpty) continue;
      if (!_isNear(cur.points.last, next.points.first)) {
        final mutableNext = List<LatLng>.of(next.points);
        mutableNext.insert(0, cur.points.last);
        segments[i + 1] = TransitSegment(
          lines: next.lines,
          walkingDistance: next.walkingDistance,
          points: mutableNext,
          entrance: next.entrance,
          exit: next.exit,
          walkSteps: next.walkSteps,
          taxi: next.taxi,
        );
      }
    }
  }

  static int _walkPointCount(Map<dynamic, dynamic>? walk) {
    if (walk == null) return 0;
    final walkSteps = walk['steps'] as List<dynamic>?;
    if (walkSteps != null && walkSteps.isNotEmpty) {
      var count = 0;
      for (final ws in walkSteps) {
        if (ws is! Map) continue;
        count += (ws['polyline'] as List<dynamic>?)?.length ?? 0;
      }
      return count;
    }
    return (walk['polyline'] as List<dynamic>?)?.length ?? 0;
  }

  /// 搜索公交站台
  static Future<BusStationResult> searchBusStation(String keyword, {String city = ''}) async {
    try {
      Logs.ui.info('🔍 原生公交站搜索: $keyword, city=$city');
      final result = await _methodChannel.invokeMapMethod('searchBusStation', {
        'keyword': keyword,
        'city': city,
      });
      if (result == null) {
        Logs.ui.warning('⚠️ 原生公交站搜索返回为空');
        return const BusStationResult(stations: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
      }
      return BusStationResult.fromMap(result);
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 原生公交站搜索失败: ${e.message}');
      return const BusStationResult(stations: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
    } catch (e) {
      Logs.ui.warning('❌ 原生公交站搜索异常: $e');
      return const BusStationResult(stations: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
    }
  }

  /// 按名称搜索公交线路
  static Future<BusLineResult> searchBusLineByName(String keyword, {String city = ''}) async {
    try {
      Logs.ui.info('🔍 原生公交线路搜索: $keyword, city=$city');
      final result = await _methodChannel.invokeMapMethod('searchBusLineByName', {
        'keyword': keyword,
        'city': city,
      });
      if (result == null) {
        Logs.ui.warning('⚠️ 原生公交线路搜索返回为空');
        return const BusLineResult(lines: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
      }
      return BusLineResult.fromMap(result);
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 原生公交线路搜索失败: ${e.message}');
      return const BusLineResult(lines: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
    } catch (e) {
      Logs.ui.warning('❌ 原生公交线路搜索异常: $e');
      return const BusLineResult(lines: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
    }
  }

  /// 按ID查询公交线路详情
  static Future<BusLineDetail?> searchBusLineById(String lineId, {String city = ''}) async {
    try {
      Logs.ui.info('🔍 原生公交线路详情查询: $lineId, city=$city');
      final result = await _methodChannel.invokeMapMethod('searchBusLineById', {
        'lineId': lineId,
        'city': city,
      });
      if (result == null) {
        Logs.ui.warning('⚠️ 原生公交线路详情返回为空');
        return null;
      }
      final lines = (result['lines'] as List<dynamic>?) ?? [];
      if (lines.isEmpty) return null;
      return BusLineDetail.fromMap(lines[0] as Map<dynamic, dynamic>);
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 原生公交线路详情失败: ${e.message}');
      return null;
    } catch (e) {
      Logs.ui.warning('❌ 原生公交线路详情异常: $e');
      return null;
    }
  }

  static TransitLineType _mapBusType(String type) {
    switch (type) {
      case '地铁':
        return TransitLineType.subway;
      case '普通公交':
        return TransitLineType.bus;
      default:
        // 地铁类：地铁、轻轨、有轨电车、磁悬浮
        if (type.contains('地铁') || type.contains('轨') || type.contains('磁')) {
          return TransitLineType.subway;
        }
        // 郊区/市域/城际铁路
        if (type.contains('郊区') || type.contains('市域') || type.contains('城际')) {
          return TransitLineType.suburban;
        }
        return TransitLineType.bus;
    }
  }
}
