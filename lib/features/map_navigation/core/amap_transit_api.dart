import 'package:dio/dio.dart';
import 'package:qintu/config/amap_web_config.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
import 'package:qintu/core/http/third_party_api_client.dart';

/// ============================================
/// 高德地图公共交通路线规划 API
///
/// 调用高德地图 RESTful API 实现公共交通换乘路线规划
/// API: /v3/direction/transit/integrated
///
/// 依赖 ThirdPartyApiClient 统一管理第三方 HTTP 请求
/// ============================================
class AmapTransitApi {
  static final AmapTransitApi _instance = AmapTransitApi._internal();
  factory AmapTransitApi() => _instance;
  AmapTransitApi._internal();

  static AmapTransitApi get instance => _instance;

  /// 公共交通 API 地址 (v3)
  /// 注意：这是完整 URL，因为 ThirdPartyApiClient 的 baseUrl 是 https://restapi.amap.com
  static const String _transitApiPath = '/v3/direction/transit/integrated';

  /// 使用统一的第三方 API 客户端
  final Dio _dio = ThirdPartyApiClient.instance.dio;

  /// 规划公共交通路线
  ///
  /// [origin] 起点坐标
  /// [destination] 终点坐标
  /// [strategy] 策略（0-较快捷,1-较少换乘,2-较少步行,3-最短时间,4-不乘地铁）
  /// [city] 城市名称
  Future<List<RouteOption>> planTransitRoute({
    required LatLng origin,
    required LatLng destination,
    int strategy = 0,
    required String city,
  }) async {
    final apiKey = AmapWebConfig.webApiKey;
    if (apiKey.isEmpty) {
      throw const RoutingException('未配置高德地图 Web 服务 API Key');
    }

    Logs.ui.info('🚌 规划公共交通路线: ${origin.latitude},${origin.longitude} → ${destination.latitude},${destination.longitude} (城市: $city)');

    try {
      final response = await _dio.get(_transitApiPath, queryParameters: {
        'key': apiKey,
        'origin': '${origin.longitude},${origin.latitude}',
        'destination': '${destination.longitude},${destination.latitude}',
        'city': city,
        'strategy': strategy,
        'show_fields': 'cost,duration,polyline',
        'output': 'json',
      });

      final data = response.data;
      if (data['status'] != '1') {
        final errorMsg = data['info'] ?? '路线规划失败';
        Logs.ui.warning('❌ 公共交通路线规划失败: $errorMsg (infocode: ${data['infocode']})');
        throw RoutingException(errorMsg);
      }

      if (data['count'] == '0' || data['route'] == null || data['route']['transits'] == null) {
        Logs.ui.warning('⚠️ 未找到公共交通路线');
        return [];
      }

      final transits = data['route']['transits'] as List;
      Logs.ui.info('✅ 获取到 ${transits.length} 条公共交通备选路线');

      return transits.map((transit) => _parseTransitRoute(transit)).toList();
    } on DioException catch (e) {
      Logs.ui.warning('🌐 网络请求失败: $e');
      throw RoutingException('网络请求失败: ${e.message}');
    } catch (e) {
      Logs.ui.warning('❌ 公共交通路线规划异常: $e');
      throw RoutingException('公共交通路线规划异常: $e');
    }
  }

  /// 解析公共交通路线
  RouteOption _parseTransitRoute(Map<String, dynamic> transit) {
    try {
      final cost = transit['cost']?.toString() ?? '0';
      final duration = double.tryParse(transit['duration']?.toString() ?? '0') ?? 0;
      final distance = double.tryParse(transit['distance']?.toString() ?? '0') ?? 0;

      // 公交路线的解析较复杂，segments 包含步行+公交+地铁的混合
      final points = <LatLng>[];
      final transitSegments = <TransitSegment>[];
      final segments = transit['segments'];

      if (segments is! List) {
        Logs.ui.warning('⚠️ transit segments 不是 List 类型: ${segments?.runtimeType}');
        return RouteOption(
          distance: distance,
          duration: duration,
          strategy: '公共交通',
          tolls: double.tryParse(cost) ?? 0,
          points: points,
          routeType: RouteType.transit,
          transitSegments: transitSegments,
        );
      }

      for (final segment in segments) {
        if (segment is! Map) continue;

        // 解析公共交通线路
        final lines = <TransitLine>[];
        final buslines = segment['buslines'];
        if (buslines is List) {
          for (final busline in buslines) {
            if (busline is! Map) continue;
            final name = busline['name']?.toString() ?? '';
            // type 可能是 int 或 String，统一转为 int
            final typeValue = busline['type'];
            final type = typeValue is int ? typeValue : (int.tryParse(typeValue?.toString() ?? '') ?? 0);
            // via_num 可能是 int 或 String
            final stationCountValue = busline['via_num'];
            final stationCount = stationCountValue is int
                ? stationCountValue
                : (int.tryParse(stationCountValue?.toString() ?? '') ?? 0);

            if (name.isNotEmpty) {
              lines.add(TransitLine(
                name: name,
                type: _parseTransitLineType(type),
                stationCount: stationCount,
              ));
            }

            // 公交线路的 polyline
            final polyline = busline['polyline'];
            if (polyline is String) {
              points.addAll(_parsePolyline(polyline));
            }

            // 公交线路的 steps 中的 polyline
            final busSteps = busline['steps'];
            if (busSteps is List) {
              for (final step in busSteps) {
                if (step is! Map) continue;
                final stepPolyline = step['polyline'];
                if (stepPolyline is String) {
                  points.addAll(_parsePolyline(stepPolyline));
                }
              }
            }
          }
        }

        // 解析地铁/铁路
        final railway = segment['railway'];
        if (railway is Map) {
          final name = railway['name']?.toString() ?? '';
          final time = double.tryParse(railway['time']?.toString() ?? '0') ?? 0;
          final stationCount = (time / 180).round(); // 估算站数

          if (name.isNotEmpty) {
            lines.add(TransitLine(
              name: name,
              type: TransitLineType.subway,
              stationCount: stationCount,
            ));
          }

          final polyline = railway['polyline'];
          if (polyline is String) {
            points.addAll(_parsePolyline(polyline));
          }

          // 火车的 steps 中的 polyline
          final railSteps = railway['steps'];
          if (railSteps is List) {
            for (final step in railSteps) {
              if (step is! Map) continue;
              final stepPolyline = step['polyline'];
              if (stepPolyline is String) {
                points.addAll(_parsePolyline(stepPolyline));
              }
            }
          }
        }

        // 解析步行
        final walking = segment['walking'];
        final walkingDistance = walking is Map
            ? double.tryParse(walking['distance']?.toString() ?? '0') ?? 0
            : 0;

        if (walking is Map) {
          // 步行的 polyline
          final walkingPolyline = walking['polyline'];
          if (walkingPolyline is String) {
            points.addAll(_parsePolyline(walkingPolyline));
          }

          // 步行的 steps 中的 polyline
          final walkSteps = walking['steps'];
          if (walkSteps is List) {
            for (final step in walkSteps) {
              if (step is! Map) continue;
              final stepPolyline = step['polyline'];
              if (stepPolyline is String) {
                points.addAll(_parsePolyline(stepPolyline));
              }
            }
          }
        }

        if (lines.isNotEmpty || walkingDistance > 0) {
          transitSegments.add(TransitSegment(
            lines: lines,
            walkingDistance: walkingDistance.round(),
          ));
        }
      }

      // 如果没有解析到任何点，尝试使用 walking_distance 构建简单连接
      if (points.isEmpty && distance > 0) {
        Logs.ui.warning('⚠️ 公交路线未解析到 polyline，使用起终点直线代替');
      }

      return RouteOption(
        distance: distance,
        duration: duration,
        strategy: '公共交通',
        tolls: double.tryParse(cost) ?? 0,
        points: points,
        routeType: RouteType.transit,
        transitSegments: transitSegments,
      );
    } catch (e, stack) {
      Logs.ui.warning('⚠️ 解析公交路线异常: $e\n$stack');
      // 返回空路线而不崩溃
      return RouteOption(
        distance: 0,
        duration: 0,
        strategy: '公共交通',
        tolls: 0,
        points: [],
        routeType: RouteType.transit,
        transitSegments: [],
      );
    }
  }

  /// 解析公共交通线路类型
  TransitLineType _parseTransitLineType(int type) {
    switch (type) {
      case 0:
        return TransitLineType.bus;
      case 1:
        return TransitLineType.subway;
      case 2:
        return TransitLineType.suburban;
      default:
        return TransitLineType.bus;
    }
  }

  /// 解析 polyline 坐标串
  /// 格式: "lon1,lat1;lon2,lat2;lon3,lat3"
  List<LatLng> _parsePolyline(String polyline) {
    try {
      return polyline.split(';').map((coord) {
        return LatLng.fromAmapString(coord);
      }).toList();
    } catch (e) {
      Logs.ui.warning('⚠️ Polyline 解析失败: $e');
      return [];
    }
  }
}
