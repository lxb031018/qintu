import 'package:dio/dio.dart';
import 'package:qintu/config/amap_web_config.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
import 'package:qintu/core/http/third_party_api_client.dart';
import '../utils/polyline_service.dart';

/// ============================================
/// 高德地图骑行路线规划 API
///
/// 调用高德地图 RESTful API 实现骑行路线规划
/// API: /v4/direction/bicycling (骑行API从v4开始)
///
/// 依赖 ThirdPartyApiClient 统一管理第三方 HTTP 请求
/// ============================================
class AmapRidingApi {
  static final AmapRidingApi _instance = AmapRidingApi._internal();
  factory AmapRidingApi() => _instance;
  AmapRidingApi._internal();

  static AmapRidingApi get instance => _instance;

  /// 骑行路线 API 路径 (v4)
  /// 注意：这是完整 URL，因为 ThirdPartyApiClient 的 baseUrl 是 https://restapi.amap.com
  static const String _ridingApiPath = '/v4/direction/bicycling';

  /// 使用统一的第三方 API 客户端
  final Dio _dio = ThirdPartyApiClient.instance.dio;

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
      final response = await _dio.get(_ridingApiPath, queryParameters: {
        'key': apiKey,
        'origin': '${origin.longitude},${origin.latitude}',
        'destination': '${destination.longitude},${destination.latitude}',
        'output': 'json',
      });

      final data = response.data;
      Logs.ui.info('🚴 骑行 API 返回: $data');

      // 检查返回的数据结构
      Logs.ui.info('🚴 [DEBUG] data keys: ${data.keys.toList()}');
      if (data['data'] != null) {
        Logs.ui.info('🚴 [DEBUG] data.data keys: ${(data['data'] as Map).keys.toList()}');
      }

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

    Logs.ui.info('🚴 [_parseRidingRoute] 原始数据: distance=$distance, duration=$duration');

    final points = <LatLng>[];
    final rideSteps = <WalkStep>[];

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
          rideSteps.add(WalkStep(
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
      strategy: '骑行路线',
      tolls: 0,
      points: points,
      routeType: RouteType.riding,
      rideSteps: rideSteps.isNotEmpty ? rideSteps : null,
    );
  }

  /// 解析 polyline 坐标串
  /// 格式: "lon1,lat1;lon2,lat2;lon3,lat3"
  List<LatLng> _parsePolyline(String polyline) => parsePolyline(polyline);
}
