import 'package:dio/dio.dart';
import 'package:qintu/config/amap_web_config.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
import 'package:qintu/features/map_navigation/api/routing_api.dart';
import 'package:qintu/features/map_navigation/api/amap_walking_api.dart';
import 'package:qintu/features/map_navigation/api/amap_transit_api.dart';
import 'package:qintu/features/map_navigation/api/amap_riding_api.dart';

export 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
export 'package:qintu/features/map_navigation/api/amap_walking_api.dart';
export 'package:qintu/features/map_navigation/api/amap_transit_api.dart';
export 'package:qintu/features/map_navigation/api/amap_riding_api.dart';

/// ============================================
/// 高德地图路线规划服务（统一入口）
///
/// 拆分后各服务：
/// - RoutingApi: 驾车路线规划
/// - AmapWalkingApi: 步行路线规划
/// - AmapRidingApi: 骑行路线规划
/// - AmapTransitApi: 公交/地铁路线规划
///
/// 本文件作为统一入口，根据出行方式分发到各服务
/// ============================================
class AmapRoutingService {
  static final AmapRoutingService _instance = AmapRoutingService._internal();
  factory AmapRoutingService() => _instance;
  AmapRoutingService._internal();

  static AmapRoutingService get instance => _instance;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// 各服务实例
  final _routingApi = RoutingApi();
  final _walkingService = AmapWalkingApi.instance;
  final _ridingService = AmapRidingApi.instance;
  final _transitService = AmapTransitApi.instance;

  /// 规划路线（统一入口）
  ///
  /// [type] 出行方式（驾车/步行/骑行/公交）
  /// [origin] 起点坐标
  /// [destination] 终点坐标
  /// [strategy] 策略（驾车:0-速度最快,1-费用优先,2-距离最短; 公交:0-较快捷,1-较少换乘,2-较少步行,3-最短时间,4-不乘地铁）
  /// [city] 城市名称，用于公交/地铁路线规划（自动从 origin 坐标逆地理编码获取）
  Future<List<RouteOption>> planRoute({
    required RouteType type,
    required LatLng origin,
    required LatLng destination,
    int strategy = 0,
    String? city,
  }) async {
    // 公交/地铁路线需要城市参数
    String routeCity = city ?? '';

    switch (type) {
      case RouteType.driving:
        return _routingApi.planDrivingRoute(
          origin: origin,
          destination: destination,
          strategy: strategy,
        );
      case RouteType.walking:
        return _walkingService.planWalkingRoute(
          origin: origin,
          destination: destination,
        );
      case RouteType.riding:
        return _ridingService.planRidingRoute(
          origin: origin,
          destination: destination,
          strategy: strategy,
        );
      case RouteType.transit:
        // 如果没有提供城市，尝试从起点坐标逆地理编码获取
        if (routeCity.isEmpty) {
          routeCity = await _getCityFromLocation(origin);
        }
        if (routeCity.isEmpty) {
          throw const RoutingException('公交/地铁路线需要城市参数，请开启定位权限或手动输入城市');
        }
        return _transitService.planTransitRoute(
          origin: origin,
          destination: destination,
          strategy: strategy,
          city: routeCity,
        );
    }
  }

  /// 从坐标逆地理编码获取城市名称
  Future<String> _getCityFromLocation(LatLng location) async {
    try {
      final apiKey = AmapWebConfig.webApiKey;
      if (apiKey.isEmpty) return '';

      final url = '${AmapWebConfig.routingApiBaseUrl}/geocode/regeo';
      final response = await _dio.get(url, queryParameters: {
        'key': apiKey,
        'location': '${location.longitude},${location.latitude}',
        'extensions': 'base',
        'output': 'json',
      });

      final data = response.data;
      if (data['status'] == '1' && data['regeocode'] != null) {
        final addressComponent = data['regeocode']['addressComponent'];
        return addressComponent['city'] as String? ?? '';
      }
    } catch (e) {
      Logs.ui.warning('⚠️ 逆地理编码获取城市失败: $e');
    }
    return '';
  }
}
