import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/utils/logger.dart';
import '../service/binding_service.dart';

/// ============================================
/// 绑定页面 Provider 层
///
/// 管理绑定页面的 UI 状态（对话框、通知中心等）
/// ============================================

/// 绑定页面状态
class BindingPageState {
  final bool showPhoneDialog;
  final bool isLoading;
  final String? errorMessage;

  const BindingPageState({
    this.showPhoneDialog = false,
    this.isLoading = false,
    this.errorMessage,
  });

  BindingPageState copyWith({
    bool? showPhoneDialog,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BindingPageState(
      showPhoneDialog: showPhoneDialog ?? this.showPhoneDialog,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// 绑定页面 Provider
class BindingPageNotifier extends Notifier<BindingPageState> {
  final BindingService _service;

  BindingPageNotifier({BindingService? service})
      : _service = service ?? BindingService();

  @override
  BindingPageState build() {
    return const BindingPageState();
  }

  /// 显示手机号绑定对话框
  void showPhoneBindingDialog() {
    state = state.copyWith(showPhoneDialog: true);
  }

  /// 关闭手机号绑定对话框
  void hidePhoneBindingDialog() {
    state = state.copyWith(showPhoneDialog: false);
  }

  /// 发送绑定请求
  Future<bool> requestBinding({
    required String receiverPhone,
    String? senderName,
    String? receiverName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _service.requestBinding(
        receiverPhone: receiverPhone,
        senderName: senderName,
        receiverName: receiverName,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      Logs.binding.error('发送绑定请求失败: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 确认绑定请求
  Future<bool> confirmRequest(int requestId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _service.confirm(requestId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      Logs.binding.error('确认绑定请求失败: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 拒绝绑定请求
  Future<bool> rejectRequest(int requestId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _service.reject(requestId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      Logs.binding.error('拒绝绑定请求失败: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 解除绑定
  Future<bool> revokeBinding(int bindingId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _service.revoke(bindingId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      Logs.binding.error('解除绑定失败: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 取消发出的请求
  Future<bool> cancelSentRequest(int requestId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _service.cancelRequest(requestId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      Logs.binding.error('取消请求失败: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider 导出
final bindingPageProvider = NotifierProvider<BindingPageNotifier, BindingPageState>(
  BindingPageNotifier.new,
);
