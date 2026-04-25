import 'package:dio/dio.dart';
import 'package:qintu/config/amap_web_config.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
import 'package:qintu/core/http/third_party_api_client.dart';

/// ============================================
/// 高德地图步行路线规划 API
///
/// 调用高德地图 RESTful API 实现步行路线规划
/// API: /v3/direction/walking
///
/// 依赖 ThirdPartyApiClient 统一管理第三方 HTTP 请求
/// ============================================
class AmapWalkingApi {
  static final AmapWalkingApi _instance = AmapWalkingApi._internal();
  factory AmapWalkingApi() => _instance;
  AmapWalkingApi._internal();

  static AmapWalkingApi get instance => _instance;

  /// 使用统一的第三方 API 客户端
  final Dio _dio = ThirdPartyApiClient.instance.dio;

  /// 规划步行路线
  ///
  /// [origin] 起点坐标
  /// [destination] 终点坐标
  Future<List<RouteOption>> planWalkingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final apiKey = AmapWebConfig.webApiKey;
    if (apiKey.isEmpty) {
      throw const RoutingException('未配置高德地图 Web 服务 API Key');
    }

    final url = '${AmapWebConfig.routingApiBaseUrl}/walking';
    Logs.ui.info('🚶 规划步行路线: ${origin.latitude},${origin.longitude} → ${destination.latitude},${destination.longitude}');

    try {
      final response = await _dio.get(url, queryParameters: {
        'key': apiKey,
        'origin': '${origin.longitude},${origin.latitude}',
        'destination': '${destination.longitude},${destination.latitude}',
        'output': 'json',
      });

      final data = response.data;
      if (data['status'] != '1') {
        final errorMsg = data['info'] ?? '路线规划失败';
        Logs.ui.warning('❌ 步行路线规划失败: $errorMsg (infocode: ${data['infocode']})');
        throw RoutingException(errorMsg);
      }

      if (data['count'] == '0' || data['route'] == null || data['route']['paths'] == null) {
        Logs.ui.warning('⚠️ 未找到步行路线');
        return [];
      }

      final paths = data['route']['paths'] as List;
      Logs.ui.info('✅ 获取到 ${paths.length} 条步行备选路线');

      return paths.map((path) => _parseWalkingRoute(path)).toList();
    } on DioException catch (e) {
      Logs.ui.warning('🌐 网络请求失败: $e');
      throw RoutingException('网络请求失败: ${e.message}');
    } catch (e) {
      Logs.ui.warning('❌ 步行路线规划异常: $e');
      throw RoutingException('步行路线规划异常: $e');
    }
  }

  /// 解析步行路线
  RouteOption _parseWalkingRoute(Map<String, dynamic> path) {
    final distance = double.tryParse(path['distance']?.toString() ?? '0') ?? 0;
    final duration = double.tryParse(path['duration']?.toString() ?? '0') ?? 0;

    final points = <LatLng>[];
    final walkSteps = <WalkStep>[];

    if (path['steps'] != null) {
      for (final step in path['steps']) {
        // 解析每一步的坐标点
        List<LatLng> stepPoints = [];
        if (step['polyline'] != null) {
          stepPoints = _parsePolyline(step['polyline']);
          points.addAll(stepPoints);
        }

        // 解析 step 详情
        final stepDistance = double.tryParse(step['distance']?.toString() ?? '0') ?? 0;
        final stepDuration = double.tryParse(step['duration']?.toString() ?? '0') ?? 0;
        final stepInstruction = step['instruction']?.toString() ?? '';
        final stepAction = step['action']?.toString() ?? '';
        final stepRoad = step['road']?.toString() ?? '';

        if (stepInstruction.isNotEmpty) {
          walkSteps.add(WalkStep(
            instruction: stepInstruction,
            action: stepAction,
            road: stepRoad,
            distance: stepDistance,
            duration: stepDuration,
            points: stepPoints,
            walkAction: WalkStep.parseAction(stepAction),
          ));
        }
      }
    }

    return RouteOption(
      distance: distance,
      duration: duration,
      strategy: '步行',
      tolls: 0,
      points: points,
      routeType: RouteType.walking,
      walkSteps: walkSteps.isNotEmpty ? walkSteps : null,
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
