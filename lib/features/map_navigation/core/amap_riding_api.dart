import 'package:dio/dio.dart';
import 'package:qintu/config/amap_web_config.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';

/// ============================================
/// 高德地图骑行路线规划 API
///
/// 调用高德地图 RESTful API 实现骑行路线规划
/// API: /v4/direction/bicycling (骑行API从v4开始)
/// ============================================
class AmapRidingApi {
  static final AmapRidingApi _instance = AmapRidingApi._internal();
  factory AmapRidingApi() => _instance;
  AmapRidingApi._internal();

  static AmapRidingApi get instance => _instance;

  /// 骑行路线 API 地址 (v4)
  static const String _ridingApiBaseUrl = 'https://restapi.amap.com/v4/direction/bicycling';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// 规划骑行路线
  ///
  /// [origin] 起点坐标
  /// [destination] 终点坐标
  /// [strategy] 策略（0-推荐路线, 1-最短距离）
  Future<List<RouteOption>> planRidingRoute({
    required LatLng origin,
    required LatLng destination,
    int strategy = 0,
  }) async {
    final apiKey = AmapWebConfig.webApiKey;
    if (apiKey.isEmpty) {
      throw const RoutingException('未配置高德地图 Web 服务 API Key');
    }

    Logs.ui.info('🚴 规划骑行路线: ${origin.latitude},${origin.longitude} → ${destination.latitude},${destination.longitude}');

    try {
      final response = await _dio.get(_ridingApiBaseUrl, queryParameters: {
        'key': apiKey,
        'origin': '${origin.longitude},${origin.latitude}',
        'destination': '${destination.longitude},${destination.latitude}',
        'output': 'json',
      });

      final data = response.data;
      Logs.ui.info('🚴 骑行 API 返回: $data');

      // v4 版本返回结构是 data 对象
      if (data['data'] == null) {
        final errorMsg = data['info'] ?? data['errmsg'] ?? '路线规划失败';
        final errcode = data['errcode'] ?? data['infocode'];
        Logs.ui.warning('❌ 骑行路线规划失败: $errorMsg (errcode: $errcode)');
        throw RoutingException(errorMsg);
      }

      final dataObj = data['data'];
      final paths = dataObj['paths'] as List?;

      if (paths == null || paths.isEmpty) {
        Logs.ui.warning('⚠️ 未找到骑行路线');
        return [];
      }

      Logs.ui.info('✅ 获取到 ${paths.length} 条骑行备选路线');

      return paths.map((path) => _parseRidingRoute(path)).toList();
    } on DioException catch (e) {
      Logs.ui.warning('🌐 网络请求失败: $e');
      throw RoutingException('网络请求失败: ${e.message}');
    } catch (e) {
      Logs.ui.warning('❌ 骑行路线规划异常: $e');
      throw RoutingException('骑行路线规划异常: $e');
    }
  }

  /// 解析骑行路线
  RouteOption _parseRidingRoute(Map<String, dynamic> path) {
    final distance = double.tryParse(path['distance']?.toString() ?? '0') ?? 0;
    final duration = double.tryParse(path['duration']?.toString() ?? '0') ?? 0;

    final points = <LatLng>[];
    if (path['steps'] != null) {
      for (final step in path['steps']) {
        if (step['polyline'] != null) {
          points.addAll(_parsePolyline(step['polyline']));
        }
      }
    }

    return RouteOption(
      distance: distance,
      duration: duration,
      strategy: '骑行路线',
      tolls: 0, // 骑行免费
      points: points,
      routeType: RouteType.riding,
    );
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
