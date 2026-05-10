import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/binding_location_api.dart';
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
  Future<BindingLocationResult> getBinderLocation(String partnerOpenid) async {
    return await _api.getBinderLocation(partnerOpenid);
  }

  /// 批量获取多个绑定者的位置信息
  Future<Map<String, BindingLocationResult>> getBinderLocations(
    List<String> partnerOpenids,
  ) async {
    return await _api.getBinderLocations(partnerOpenids);
  }

  /// 将 API 返回的位置结果转换为前端使用的 BinderLocationData 列表
  ///
  /// [openidToNickname] - openid 到昵称的映射
  /// [locationResults] - openid 到位置结果的映射
  /// 仅保留成功获取到位置的数据，失败或无位置的数据会被过滤
  List<BinderLocationData> convertToBinderDataList(
    Map<String, String> openidToNickname,
    Map<String, BindingLocationResult> locationResults,
  ) {
    final results = <BinderLocationData>[];
    for (final entry in locationResults.entries) {
      final openid = entry.key;
      final result = entry.value;
      final nickname = openidToNickname[openid] ?? '绑定者';
      if (result.isSuccess && result.location != null) {
        results.add(BinderLocationData(
          openid: openid,
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