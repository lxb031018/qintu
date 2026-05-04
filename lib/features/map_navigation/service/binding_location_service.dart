import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/binding_location_api.dart';
import 'location_category_service.dart';
import '../../relationship_binding/service/binding_service.dart';

class BindingLocationService {
  final BindingLocationApi _api;

  BindingLocationService({BindingLocationApi? api}) : _api = api ?? BindingLocationApi();

  Future<BindingLocationResult> getBinderLocation(String partnerOpenid) async {
    return await _api.getBinderLocation(partnerOpenid);
  }

  Future<Map<String, BindingLocationResult>> getBinderLocations(
    List<String> partnerOpenids,
  ) async {
    return await _api.getBinderLocations(partnerOpenids);
  }

  /// 获取所有绑定者的位置数据（封装跨 feature 调用）
  Future<List<BinderLocationData>> fetchBinderDataList() async {
    final bindingService = BindingService();
    final bindings = await bindingService.getBindingsList();

    final binderDataList = <BinderLocationData>[];
    for (final binding in bindings) {
      final openid = binding.partnerOpenid;
      if (openid == null) continue;

      try {
        final result = await getBinderLocation(openid);
        if (result.isSuccess && result.location != null) {
          binderDataList.add(BinderLocationData(
            openid: openid,
            nickname: binding.partnerNickname ?? '绑定者',
            address: result.location!.address,
            lat: result.location!.latitude,
            lng: result.location!.longitude,
          ));
        }
      } catch (_) {
        // 单个绑定者获取失败不影响其他
      }
    }

    return binderDataList;
  }
}

final bindingLocationServiceProvider = Provider<BindingLocationService>((ref) => BindingLocationService());