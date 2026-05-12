import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/route_share_api.dart';
import '../models/poi_models.dart';
import '../models/route_option_model.dart';

/// ============================================
/// 路由分享 Service
///
/// 业务逻辑层，封装路由分享相关 API 调用
/// 不持有 UI 状态，只负责发送路由分享数据
/// ============================================
class RouteShareService {
  final RouteShareApi _api;

  RouteShareService({RouteShareApi? api}) : _api = api ?? RouteShareApi();

  /// 发送路由分享
  ///
  /// [binderOpenid] - 绑定者openid（接收者）
  /// [origin] - 起点POI
  /// [destination] - 终点POI
  /// [routeType] - 出行方式
  Future<void> shareRoute({
    required String binderOpenid,
    required PoiSuggestion origin,
    required PoiSuggestion destination,
    required RouteType routeType,
  }) async {
    if (binderOpenid.isEmpty) {
      throw Exception('请选择要分享的绑定者');
    }

    final originLatLng = origin.latLng;
    final destLatLng = destination.latLng;

    if (originLatLng == null) {
      throw Exception('起点坐标无效');
    }
    if (destLatLng == null) {
      throw Exception('终点坐标无效');
    }

    // 公交类型不支持分享
    if (routeType == RouteType.transit) {
      throw Exception('公共交通暂不支持分享');
    }

    await _api.sendRouteShare(
      receiverOpenid: binderOpenid,
      originLat: originLatLng.latitude,
      originLng: originLatLng.longitude,
      originName: origin.name,
      originAddress: origin.address,
      destLat: destLatLng.latitude,
      destLng: destLatLng.longitude,
      destName: destination.name,
      destAddress: destination.address,
      routeType: _routeTypeToString(routeType),
    );
  }

  String _routeTypeToString(RouteType type) {
    switch (type) {
      case RouteType.driving:
        return 'driving';
      case RouteType.walking:
        return 'walking';
      case RouteType.riding:
        return 'riding';
      case RouteType.transit:
        return 'transit';
    }
  }

  /// 将 routeType 字符串转换为 RouteType 枚举
  RouteType stringToRouteType(String type) {
    switch (type) {
      case 'driving':
        return RouteType.driving;
      case 'walking':
        return RouteType.walking;
      case 'riding':
        return RouteType.riding;
      case 'transit':
        return RouteType.transit;
      default:
        return RouteType.driving;
    }
  }

  /// 获取待接收的路由分享
  Future<List<PendingRouteShare>> getPendingShares() async {
    return await _api.getPendingShares();
  }
}

final routeShareServiceProvider = Provider<RouteShareService>((ref) => RouteShareService());