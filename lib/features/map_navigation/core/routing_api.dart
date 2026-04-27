import 'package:dio/dio.dart';
import '../../../core/http/third_party_api_client.dart';
import '../../../config/amap_web_config.dart';
import '../models/amap_routing_models.dart';
import '../../../utils/logger.dart';

/// ============================================
/// 高德路线规划 API
///
/// 纯 HTTP 调用，返回数据模型，无 Flutter 依赖
///
/// 依赖 ThirdPartyApiClient 统一管理第三方 HTTP 请求
/// ============================================

class RoutingApi {
  /// 使用统一的第三方 API 客户端
  final Dio _dio = ThirdPartyApiClient.instance.dio;

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
    final driveSteps = <DriveStep>[];

    if (path['steps'] != null) {
      for (final step in path['steps']) {
        final stepPolyline = step['polyline']?.toString() ?? '';
        final stepPoints = _parsePolyline(stepPolyline);

        // 累积坐标点
        points.addAll(stepPoints);

        // 解析驾车步骤详情
        final stepDistance = double.tryParse(step['distance']?.toString() ?? '0') ?? 0;
        final stepDuration = double.tryParse(step['duration']?.toString() ?? '0') ?? 0;
        final stepInstruction = step['instruction']?.toString() ?? '';
        final stepAction = step['action']?.toString() ?? '';
        final stepRoad = step['road']?.toString() ?? '';

        // 解析 TMC 交通状态
        String? tmcStatus;
        if (step['tmc'] != null && step['tmc'] is List && (step['tmc'] as List).isNotEmpty) {
          tmcStatus = step['tmc'][0]['status']?.toString();
        }

        driveSteps.add(DriveStep(
          instruction: stepInstruction,
          action: stepAction,
          road: stepRoad,
          distance: stepDistance,
          duration: stepDuration,
          points: stepPoints,
          driveAction: DriveStep.parseAction(stepAction),
          tmcStatus: tmcStatus,
        ));
      }
    }

    return RouteOption(
      distance: distance,
      duration: duration,
      strategy: strategy.toString(),
      tolls: double.tryParse(tolls) ?? 0,
      points: points,
      routeType: RouteType.driving,
      driveSteps: driveSteps.isNotEmpty ? driveSteps : null,
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
