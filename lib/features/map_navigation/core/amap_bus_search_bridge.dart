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

  /// 搜索公交站
  ///
  /// [keyword] 搜索关键词（如"公交"、"天安门"）
  /// [city] 城市名称/编码（为空表示全国）
  static Future<BusStationResult> searchBusStation(
    String keyword, {
    String city = '',
  }) async {
    if (keyword.isEmpty) {
      return BusStationResult(stations: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
    }

    try {
      Logs.ui.info('🔍 搜索公交站: $keyword (city: $city)');
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'searchBusStation',
        {'keyword': keyword, 'city': city},
      );

      if (result != null) {
        final parsed = BusStationResult.fromMap(result);
        Logs.ui.info('✅ 搜索到 ${parsed.stations.length} 个公交站');
        return parsed;
      }
      return BusStationResult(stations: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 公交站搜索失败: ${e.message}');
      return BusStationResult(
        stations: [],
        pageCount: 0,
        suggestionKeywords: [],
        suggestionCities: [],
      );
    } catch (e) {
      Logs.ui.warning('❌ 公交站搜索异常: $e');
      return BusStationResult(
        stations: [],
        pageCount: 0,
        suggestionKeywords: [],
        suggestionCities: [],
      );
    }
  }

  /// 按名称搜索公交线路（返回详情，含站点和坐标）
  ///
  /// [keyword] 搜索关键词（如"100"、"特11路"）
  /// [city] 城市名称/编码
  static Future<BusLineResult> searchBusLineByName(
    String keyword, {
    String city = '',
  }) async {
    if (keyword.isEmpty) {
      return BusLineResult(lines: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
    }

    try {
      Logs.ui.info('🔍 搜索公交线路: $keyword (city: $city)');
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'searchBusLineByName',
        {'keyword': keyword, 'city': city},
      );

      if (result != null) {
        final parsed = BusLineResult.fromMap(result);
        Logs.ui.info('✅ 搜索到 ${parsed.lines.length} 条公交线路');
        return parsed;
      }
      return BusLineResult(lines: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 公交线路搜索失败: ${e.message}');
      return BusLineResult(lines: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
    } catch (e) {
      Logs.ui.warning('❌ 公交线路搜索异常: $e');
      return BusLineResult(lines: [], pageCount: 0, suggestionKeywords: [], suggestionCities: []);
    }
  }

  /// 按ID查询公交线路详情（含全部站点+polyline坐标）
  ///
  /// [lineId] 公交线路唯一ID（从 BusStationInfo.busLines 中获取）
  /// [city] 城市名称/编码
  static Future<BusLineDetail?> searchBusLineById(
    String lineId, {
    String city = '',
  }) async {
    if (lineId.isEmpty) {
      return null;
    }

    try {
      Logs.ui.info('🔍 查询公交线路详情: $lineId (city: $city)');
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'searchBusLineById',
        {'lineId': lineId, 'city': city},
      );

      if (result != null) {
        final lines = (result['lines'] as List<dynamic>?) ?? [];
        if (lines.isNotEmpty) {
          final detail = BusLineDetail.fromMap(lines[0] as Map<dynamic, dynamic>);
          Logs.ui.info('✅ 获取线路详情: ${detail.name} (${detail.stations.length}站)');
          return detail;
        }
      }
      return null;
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 公交线路详情查询失败: ${e.message}');
      return null;
    } catch (e) {
      Logs.ui.warning('❌ 公交线路详情查询异常: $e');
      return null;
    }
  }

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
        },
      );

      if (result == null) {
        Logs.ui.warning('⚠️ 原生公交算路返回为空');
        return [];
      }

      final paths = result['paths'] as List<dynamic>? ?? [];
      Logs.ui.info('✅ 原生公交算路: ${paths.length} 条方案');
      return paths.map((p) => _parseTransitPath(p as Map<dynamic, dynamic>)).toList();
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 原生公交算路失败: ${e.message}');
      return [];
    } catch (e) {
      Logs.ui.warning('❌ 原生公交算路异常: $e');
      return [];
    }
  }

  static RouteOption _parseTransitPath(Map<dynamic, dynamic> path) {
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
      if (walk != null) {
        walkingDistance = ((walk['distance'] as num?)?.toDouble() ?? 0).round();
        final walkSteps = walk['steps'] as List<dynamic>?;
        if (walkSteps != null && walkSteps.isNotEmpty) {
          for (final ws in walkSteps) {
            if (ws is! Map) continue;
            final stepPolyline = ws['polyline'] as List<dynamic>? ?? [];
            for (final p in stepPolyline) {
              segmentPoints.add(LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              ));
            }
          }
        } else {
          final walkPolyline = walk['polyline'] as List<dynamic>? ?? [];
          segmentPoints.addAll(walkPolyline.map((p) => LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              )));
        }
      }

      // 公交部分
      if (busLines != null && busLines.isNotEmpty) {
        for (final bl in busLines) {
          if (bl is! Map) continue;
          final name = bl['name']?.toString() ?? '';
          final typeStr = bl['type']?.toString() ?? '';
          lines.add(TransitLine(
            name: name,
            type: _mapBusType(typeStr),
            stationCount: (bl['passStationNum'] as num?)?.toInt() ?? 0,
          ));

          final polyline = bl['polyline'] as List<dynamic>? ?? [];
          for (final p in polyline) {
            segmentPoints.add(LatLng(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            ));
          }
        }
      }

      // 地铁/铁路部分
      if (railway != null) {
        final name = railway['name']?.toString() ?? '';
        if (name.isNotEmpty) {
          lines.add(TransitLine(
            name: name,
            type: TransitLineType.subway,
            stationCount: 0,
          ));
        }
        // 用站点坐标拼地铁段 polyline
        final stations = railway['stations'] as List<dynamic>? ?? [];
        segmentPoints.addAll(stations.map((p) => LatLng(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            )));
      }

      // 如果既有步行又有乘车，拆成两个 segment 以便分段渲染
      if (walkingDistance > 0 && lines.isNotEmpty) {
        final walkPtCount = _walkPointCount(walk);
        if (walkPtCount > 0 && walkPtCount < segmentPoints.length) {
          transitSegments.add(TransitSegment(
            lines: const [],
            walkingDistance: walkingDistance,
            points: segmentPoints.sublist(0, walkPtCount),
          ));
          transitSegments.add(TransitSegment(
            lines: lines,
            walkingDistance: 0,
            points: segmentPoints.sublist(walkPtCount),
          ));
        } else {
          // 无法准确拆分时，整体作为一个 segment
          transitSegments.add(TransitSegment(
            lines: lines,
            walkingDistance: walkingDistance,
            points: segmentPoints,
          ));
        }
      } else if (lines.isNotEmpty || walkingDistance > 0) {
        transitSegments.add(TransitSegment(
          lines: lines,
          walkingDistance: walkingDistance,
          points: segmentPoints,
        ));
      }
    }

    // 用所有 segment 的 points 拼接成完整路线
    final allPoints = <LatLng>[];
    for (final seg in transitSegments) {
      allPoints.addAll(seg.points);
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
    );
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

  static TransitLineType _mapBusType(String type) {
    switch (type) {
      case '地铁':
        return TransitLineType.subway;
      case '普通公交':
        return TransitLineType.bus;
      default:
        // "轻轨"、"有轨电车" 等都同样视为地铁类
        if (type.contains('地铁') || type.contains('轨') || type.contains('磁')) {
          return TransitLineType.subway;
        }
        return TransitLineType.bus;
    }
  }
}
