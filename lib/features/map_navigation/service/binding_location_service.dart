import '../core/binding_location_api.dart';

/// ============================================
/// 绑定者位置 Service
///
/// 业务逻辑层，封装 BindingLocationApi 调用
/// 不持有 UI 状态，只负责获取绑定者位置的业务逻辑
/// ============================================

class BindingLocationService {
  final BindingLocationApi _api = BindingLocationApi();

  /// 获取绑定者的位置
  Future<BindingLocationResult> getBinderLocation(String partnerOpenid) async {
    return await _api.getBinderLocation(partnerOpenid);
  }

  /// 批量获取多个绑定者的位置
  Future<Map<String, BindingLocationResult>> getBinderLocations(
    List<String> partnerOpenids,
  ) async {
    return await _api.getBinderLocations(partnerOpenids);
  }
}

/// 全局单例
final bindingLocationService = BindingLocationService();
