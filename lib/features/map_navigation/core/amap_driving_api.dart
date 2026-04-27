import 'package:dio/dio.dart';
import 'package:qintu/config/amap_web_config.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
import 'package:qintu/core/http/third_party_api_client.dart';

/// ============================================
/// 高德地图驾车路线规划 API
///
/// 调用高德地图 RESTful API 实现驾车路线规划
/// API: /v3/direction/driving
///
/// 依赖 ThirdPartyApiClient 统一管理第三方 HTTP 请求
/// ============================================
class AmapDrivingApi {
  static final AmapDrivingApi _instance = AmapDrivingApi._internal();
  factory AmapDrivingApi() => _instance;
  AmapDrivingApi._internal();

  static AmapDrivingApi get instance => _instance;

  /// 使用统一的第三方 API 客户端
  final Dio _dio = ThirdPartyApiClient.instance.dio;

  /// 规划驾车路线
  ///
  /// [origin] 起点坐标
  /// [destination] 终点坐标
  /// [strategy] 策略：0=速度最快, 1=费用优先, 2=距离最短
  /// [extensions] 返回结果类型：'base'=基本路线信息, 'all'=完整信息(含打车费用)
  Future<List<RouteOption>> planDrivingRoute({
    required LatLng origin,
    required LatLng destination,
    int strategy = 0,
    String extensions = 'base',
  }) async {
    final apiKey = AmapWebConfig.webApiKey;
    if (apiKey.isEmpty) {
      throw const RoutingException('未配置高德地图 Web 服务 API Key');
    }

    final url = '${AmapWebConfig.routingApiBaseUrl}/driving';
    Logs.ui.info('🚗 规划驾车路线: ${origin.latitude},${origin.longitude} → ${destination.latitude},${destination.longitude}, 策略: $strategy');

    try {
      final response = await _dio.get(url, queryParameters: {
        'key': apiKey,
        'origin': '${origin.longitude},${origin.latitude}',
        'destination': '${destination.longitude},${destination.latitude}',
        'strategy': strategy,
        'extensions': extensions,
        'output': 'json',
      });

      final data = response.data;
      if (data['status'] != '1') {
        final errorMsg = data['info'] ?? '路线规划失败';
        Logs.ui.warning('❌ 驾车路线规划失败: $errorMsg (infocode: ${data['infocode']})');
        throw RoutingException(errorMsg);
      }

      if (data['count'] == '0' || data['route'] == null) {
        Logs.ui.warning('⚠️ 未找到驾车路线');
        return [];
      }

      final paths = data['route']['paths'] as List;
      Logs.ui.info('✅ 获取到 ${paths.length} 条驾车备选路线');

      // 如果使用 extensions=all，尝试获取打车费用
      double? taxiCost;
      if (extensions == 'all' && data['route']['taxi_cost'] != null) {
        taxiCost = double.tryParse(data['route']['taxi_cost'].toString());
        Logs.ui.info('🚕 打车费用: ¥$taxiCost');
      }

      return paths.map((path) => _parseDrivingRoute(path, taxiCost)).toList();
    } on DioException catch (e) {
      Logs.ui.warning('🌐 网络请求失败: $e');
      throw RoutingException('网络请求失败: ${e.message}');
    } catch (e) {
      Logs.ui.warning('❌ 驾车路线规划异常: $e');
      throw RoutingException('驾车路线规划异常: $e');
    }
  }

  /// 解析驾车路线
  RouteOption _parseDrivingRoute(Map<String, dynamic> path, double? defaultTaxiCost) {
    final distance = double.tryParse(path['distance']?.toString() ?? '0') ?? 0;
    final duration = double.tryParse(path['duration']?.toString() ?? '0') ?? 0;
    final strategy = path['strategy'] ?? '未知策略';
    // 优先使用当前路线的过路费，否则使用默认的打车费用
    final tolls = double.tryParse(path['tolls']?.toString() ?? '') ?? defaultTaxiCost ?? 0;

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
      tolls: tolls,
      points: points,
      routeType: RouteType.driving,
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
