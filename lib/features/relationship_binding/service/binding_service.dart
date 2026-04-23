import '../core/binding_api.dart';
import '../../../models/binding/binding.dart';

/// ============================================
/// 绑定关系 Service 层
///
/// 纯业务逻辑，调用 API 层编排流程
/// 不持有状态，不继承 ChangeNotifier
/// ============================================

class BindingService {
  final BindingApi _api;

  BindingService({BindingApi? api}) : _api = api ?? BindingApi();

  /// 获取绑定列表（含摘要）
  Future<BindingList> getBindings() async {
    return await _api.getMyBindings();
  }

  /// 获取绑定列表（不含摘要）
  Future<List<Binding>> getBindingsList() async {
    final result = await _api.getMyBindings();
    return result.bindings;
  }

  /// 获取待确认请求
  Future<List<PendingRequest>> getPendingRequests() async {
    return await _api.getPendingRequests();
  }

  /// 获取我发出的请求
  Future<List<SentRequest>> getSentRequests() async {
    return await _api.getSentRequests();
  }

  /// 发送手机号绑定请求
  Future<void> requestBinding({
    required String receiverPhone,
    String? senderName,
    String? receiverName,
  }) async {
    await _api.requestPhoneBinding(
      receiverPhone: receiverPhone,
      senderName: senderName,
      receiverName: receiverName,
    );
  }

  /// 确认绑定请求
  Future<void> confirm(int requestId) async {
    await _api.confirmRequest(requestId);
  }

  /// 拒绝绑定请求
  Future<void> reject(int requestId) async {
    await _api.rejectRequest(requestId);
  }

  /// 解除绑定
  Future<void> revoke(int bindingId) async {
    await _api.revokeBinding(bindingId);
  }

  /// 取消发出的请求
  Future<void> cancelRequest(int requestId) async {
    await _api.cancelSentRequest(requestId);
  }
}
