/// 绑定请求输入模型
///
/// widget 收集用户输入后构造此模型交给 service 层处理，
/// service 负责：
/// - 字段级校验（[BindingService.validateRequestInput]）
/// - 自动拼接国际区号 +86
/// - 字段名映射（前端用 partnerName/name，服务端用 receiverName/senderName）
class BindingRequestInput {
  /// 我对对方的称呼（前端语义），提交时映射为 receiver_name
  final String partnerName;

  /// 对方对我的称呼（前端语义），提交时映射为 sender_name
  final String name;

  /// 对方手机号（11 位原始数字），提交时自动加 +86 前缀
  final String phone;

  const BindingRequestInput({
    required this.partnerName,
    required this.name,
    required this.phone,
  });
}

/// 字段级校验错误
///
/// 哪个字段错就把错误信息挂到对应字段，未出错字段保持 null。
/// [hasError] 为 true 表示至少有一个字段校验失败。
class BindingValidationError {
  final String? partnerNameError;
  final String? nameError;
  final String? phoneError;

  const BindingValidationError({
    this.partnerNameError,
    this.nameError,
    this.phoneError,
  });

  bool get hasError =>
      partnerNameError != null || nameError != null || phoneError != null;
}
