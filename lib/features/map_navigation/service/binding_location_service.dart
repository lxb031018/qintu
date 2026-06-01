import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/binding_location_api.dart';
import 'location_category_service.dart';

/// ============================================
/// 绑定者位置 Service
///
/// 业务逻辑层。批量获取与转换在 [BindingLocationApi] 中完成，
/// 本 service 只承担"过滤成功项并组装 BinderLocationData"的业务价值
/// ============================================
class BindingLocationService {
  final BindingLocationApi _api;

  BindingLocationService({BindingLocationApi? api}) : _api = api ?? BindingLocationApi();

  /// 批量获取多个绑定者的位置信息（透传 api）
  Future<Map<String, BindingLocationResult>> getBinderLocations(
    List<String> partnerUserIDs,
  ) =>
      _api.getBinderLocations(partnerUserIDs);

  /// 将 API 返回的位置结果转换为前端使用的 BinderLocationData 列表
  ///
  /// [userIdToNickname] - userId 到昵称的映射
  /// [locationResults] - userId 到位置结果的映射
  /// 仅保留成功获取到位置的数据，失败或无位置的数据会被过滤
  List<BinderLocationData> convertToBinderDataList(
    Map<String, String> userIdToNickname,
    Map<String, BindingLocationResult> locationResults,
  ) {
    final results = <BinderLocationData>[];
    for (final entry in locationResults.entries) {
      final userId = entry.key;
      final result = entry.value;
      final nickname = userIdToNickname[userId] ?? '绑定者';
      if (result.isSuccess && result.location != null) {
        results.add(BinderLocationData(
          userId: userId,
          nickname: nickname,
          address: result.location!.address,
          lat: result.location!.latitude,
          lng: result.location!.longitude,
        ));
      }
    }
    return results;
  }
}

final bindingLocationServiceProvider = Provider<BindingLocationService>((ref) => BindingLocationService());