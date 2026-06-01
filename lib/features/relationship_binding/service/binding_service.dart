import '../../../utils/validation/validators.dart';
import '../../../constants/app_strings.dart';
import '../core/binding_api.dart';
import '../../../models/binding/binding.dart';
import '../models/binding_request_input.dart';

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

  /// 校验绑定请求输入
  ///
  /// 字段为空时返回中文错误信息（与 widget 之前 inline 校验的措辞一致）。
  /// 全部通过则返回 null。
  BindingValidationError? validateRequestInput(BindingRequestInput input) {
    String? partnerNameError;
    String? nameError;
    String? phoneError;

    if (input.partnerName.isEmpty) {
      partnerNameError = AppStrings.pleaseFillNameForPartner;
    }
    if (input.name.isEmpty) {
      nameError = AppStrings.pleaseFillName;
    }
    final phoneValidation = Validators.validatePhone(input.phone);
    if (phoneValidation != null) {
      phoneError = phoneValidation;
    }

    if (partnerNameError == null && nameError == null && phoneError == null) {
      return null;
    }
    return BindingValidationError(
      partnerNameError: partnerNameError,
      nameError: nameError,
      phoneError: phoneError,
    );
  }

  /// 提交绑定请求
  ///
  /// 自动处理：
  /// - 给 phone 加 +86 前缀
  /// - 字段名映射（partnerName → receiverName, name → senderName）
  Future<void> submitRequest(BindingRequestInput input) async {
    await _api.requestPhoneBinding(
      receiverPhone: '+86 ${input.phone}',
      senderName: input.name,
      receiverName: input.partnerName,
    );
  }

  /// 确认绑定请求
  Future<void> confirm(String partnerUserId) async {
    await _api.confirmRequest(partnerUserId);
  }

  /// 拒绝绑定请求
  Future<void> reject(String partnerUserId) async {
    await _api.rejectRequest(partnerUserId);
  }

  /// 解除绑定
  Future<void> revoke(String partnerUserId) async {
    await _api.revokeBinding(partnerUserId);
  }

  /// 修改我对对方的称呼
  Future<void> modifyBindingName(String partnerUserId, String newName) async {
    await _api.modifyBindingName(partnerUserId, newName);
  }

  /// 取消发出的请求
  Future<void> cancelRequest(String partnerUserId) async {
    await _api.cancelSentRequest(partnerUserId);
  }
}
