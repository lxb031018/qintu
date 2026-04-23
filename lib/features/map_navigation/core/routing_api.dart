import 'package:dio/dio.dart';
import '../../../config/amap_web_config.dart';
import '../models/amap_routing_models.dart';
import '../../../utils/logger.dart';

/// ============================================
/// 高德路线规划 API
///
/// 纯 HTTP 调用，返回数据模型，无 Flutter 依赖
/// ============================================

class RoutingApi {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// 规划驾车路线
  Future<List<RouteOption>> planDrivingRoute({
    required LatLng origin,
    required LatLng destination,
    int strategy = 0,
  }) async {
    final apiKey = AmapWebConfig.webApiKey;
    if (apiKey.isEmpty) {
      throw const RoutingException('未配置高德地图 Web 服务 API Key');
    }

    final url = '${AmapWebConfig.routingApiBaseUrl}/driving';

    try {
      final response = await _dio.get(url, queryParameters: {
        'key': apiKey,
        'origin': '${origin.longitude},${origin.latitude}',
        'destination': '${destination.longitude},${destination.latitude}',
        'strategy': strategy,
        'extensions': 'base',
        'output': 'json',
      });

      final data = response.data;
      if (data['status'] != '1') {
        throw RoutingException(data['info'] ?? '路线规划失败');
      }

      if (data['count'] == '0' || data['route'] == null) {
        return [];
      }

      final paths = data['route']['paths'] as List;
      return paths.map((path) => _parseDrivingRoute(path)).toList();
    } on DioException catch (e) {
      throw RoutingException('网络请求失败: ${e.message}');
    }
  }

  /// 解析驾车路线
  RouteOption _parseDrivingRoute(Map<String, dynamic> path) {
    final distance = double.tryParse(path['distance']?.toString() ?? '0') ?? 0;
    final duration = double.tryParse(path['duration']?.toString() ?? '0') ?? 0;
    final strategy = path['strategy'] ?? '未知策略';
    final tolls = path['tolls']?.toString() ?? '0';

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
      strategy: strategy.toString(),
      tolls: double.tryParse(tolls) ?? 0,
      points: points,
      routeType: RouteType.driving,
    );
  }

  /// 解析 polyline 坐标串
  List<LatLng> _parsePolyline(String polyline) {
    try {
      return polyline.split(';').map((coord) {
        return LatLng.fromAmapString(coord);
      }).toList();
    } catch (e) {
      Logs.ui.warning('Polyline 解析失败: $e');
      return [];
    }
  }
}
