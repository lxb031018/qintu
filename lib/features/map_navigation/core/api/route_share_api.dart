import 'package:qintu/core/http/api_client.dart';
import 'package:qintu/constants/api_endpoints.dart';
import 'package:qintu/utils/logger.dart';

/// ============================================
/// 路由分享 API 层
///
/// 纯 HTTP 调用，返回数据模型，无 Flutter 依赖
/// ============================================

class RouteShareApi {
  final ApiClient _apiClient;

  RouteShareApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// 发送路由分享
  ///
  /// [receiverOpenid] - 接收者openid
  /// [originLat] - 起点纬度
  /// [originLng] - 起点经度
  /// [originName] - 起点名称
  /// [originAddress] - 起点地址
  /// [destLat] - 终点纬度
  /// [destLng] - 终点经度
  /// [destName] - 终点名称
  /// [destAddress] - 终点地址
  /// [routeType] - 出行方式 (driving/walking/riding/transit)
  Future<void> sendRouteShare({
    required String receiverOpenid,
    required double originLat,
    required double originLng,
    required String originName,
    required String originAddress,
    required double destLat,
    required double destLng,
    required String destName,
    required String destAddress,
    required String routeType,
  }) async {
    Logs.routeShare.info('API请求: POST ${ApiEndpoints.routeShareSend}');

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.routeShareSend,
      data: {
        'receiverOpenid': receiverOpenid,
        'origin': {
          'latitude': originLat,
          'longitude': originLng,
          'name': originName,
          'address': originAddress,
        },
        'destination': {
          'latitude': destLat,
          'longitude': destLng,
          'name': destName,
          'address': destAddress,
        },
        'routeType': routeType,
      },
    );

    if (!response.isSuccessful) {
      throw Exception(response.message ?? '发送路由分享失败');
    }

    Logs.routeShare.info('路由分享发送成功');
  }

  /// 获取待接收的路由分享
  Future<List<PendingRouteShare>> getPendingShares() async {
    Logs.routeShare.info('API请求: GET ${ApiEndpoints.routeSharePending}');

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.routeSharePending,
    );

    if (!response.isSuccessful) {
      throw Exception(response.message ?? '获取路由分享失败');
    }

    final data = response.data?['data'] as List<dynamic>? ?? [];
    Logs.routeShare.info('获取到 ${data.length} 条待接收路由分享');

    return data.map((json) => PendingRouteShare.fromJson(json as Map<String, dynamic>)).toList();
  }
}

/// 待接收的路由分享数据模型
class PendingRouteShare {
  final String id;
  final String senderOpenid;
  final String receiverOpenid;
  final double originLat;
  final double originLng;
  final String originName;
  final String originAddress;
  final double destLat;
  final double destLng;
  final String destName;
  final String destAddress;
  final String routeType;
  final String createdAt;

  PendingRouteShare({
    required this.id,
    required this.senderOpenid,
    required this.receiverOpenid,
    required this.originLat,
    required this.originLng,
    required this.originName,
    required this.originAddress,
    required this.destLat,
    required this.destLng,
    required this.destName,
    required this.destAddress,
    required this.routeType,
    required this.createdAt,
  });

  factory PendingRouteShare.fromJson(Map<String, dynamic> json) {
    final origin = json['origin'] as Map<String, dynamic>? ?? {};
    final destination = json['destination'] as Map<String, dynamic>? ?? {};

    return PendingRouteShare(
      id: json['id']?.toString() ?? '',
      senderOpenid: json['senderOpenid']?.toString() ?? '',
      receiverOpenid: json['receiverOpenid']?.toString() ?? '',
      originLat: (origin['latitude'] as num?)?.toDouble() ?? 0,
      originLng: (origin['longitude'] as num?)?.toDouble() ?? 0,
      originName: origin['name']?.toString() ?? '',
      originAddress: origin['address']?.toString() ?? '',
      destLat: (destination['latitude'] as num?)?.toDouble() ?? 0,
      destLng: (destination['longitude'] as num?)?.toDouble() ?? 0,
      destName: destination['name']?.toString() ?? '',
      destAddress: destination['address']?.toString() ?? '',
      routeType: json['routeType']?.toString() ?? 'driving',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}