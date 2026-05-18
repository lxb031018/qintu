import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/binding_location_api.dart';
import 'location_category_service.dart';

/// ============================================
/// 绑定者位置 Service
///
/// 业务逻辑层，封装绑定者位置相关 API 调用
/// 不持有 UI 状态，只负责获取并转换绑定者位置数据
/// ============================================
class BindingLocationService {
  final BindingLocationApi _api;

  BindingLocationService({BindingLocationApi? api}) : _api = api ?? BindingLocationApi();

  /// 获取单个绑定者的位置信息
  Future<BindingLocationResult> getBinderLocation(String partnerUserID) async {
    return await _api.getBinderLocation(partnerUserID);
  }

  /// 批量获取多个绑定者的位置信息
  Future<Map<String, BindingLocationResult>> getBinderLocations(
    List<String> partnerUserIDs,
  ) async {
    return await _api.getBinderLocations(partnerUserIDs);
  }

  /// 将 API 返回的位置结果转换为前端使用的 BinderLocationData 列表
  ///
  /// [user_IDToNickname] - user_ID 到昵称的映射
  /// [locationResults] - user_ID 到位置结果的映射
  /// 仅保留成功获取到位置的数据，失败或无位置的数据会被过滤
  List<BinderLocationData> convertToBinderDataList(
    Map<String, String> user_IDToNickname,
    Map<String, BindingLocationResult> locationResults,
  ) {
    final results = <BinderLocationData>[];
    for (final entry in locationResults.entries) {
      final user_ID = entry.key;
      final result = entry.value;
      final nickname = user_IDToNickname[user_ID] ?? '绑定者';
      if (result.isSuccess && result.location != null) {
        results.add(BinderLocationData(
          user_ID: user_ID,
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