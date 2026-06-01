import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncLoading, AsyncError;
import 'package:qintu/models/binding/binding.dart';
import 'package:qintu/models/async_state.dart';
import 'package:qintu/features/relationship_binding/service/binding_service.dart';
import 'package:qintu/features/relationship_binding/models/binding_request_input.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/constants/binding_limits.dart';

/// ============================================
/// 绑定关系状态管理
///
/// Notifier，统一状态管理
/// ============================================

class BindingNotifier extends Notifier<BindingListState> {
  late final BindingService _bindingService;

  @override
  BindingListState build() {
    _bindingService = BindingService();
    return const BindingListState();
  }

  // ==================== Getters ====================

  List<Binding> get bindings => state.bindingsState.data ?? [];
  BindingList? get bindingSummary => state.bindingSummary;
  List<PendingRequest> get pendingRequests => state.pendingRequestsState.data ?? [];
  List<SentRequest> get sentRequests => state.sentRequestsState.data ?? [];

  bool get isLoading => state.bindingsState.isLoading;
  String? get error => state.bindingsState.errorMessage;
  String? get lastErrorMessage => state.lastErrorMessage;
  int get pendingRequestsCount => pendingRequests.length;
  int get sentRequestsCount => sentRequests.length;
  bool get hasPendingRequests => pendingRequests.isNotEmpty;
  bool get hasSentRequests => sentRequests.isNotEmpty;
  int get asSenderCount => state.bindingSummary?.asSender ?? 0;
  int get asReceiverCount => state.bindingSummary?.asReceiver ?? 0;
  int get totalBindings => asSenderCount + asReceiverCount;
  bool get isBindingLimitReached => totalBindings >= BindingLimits.maxBindingsPerUser;
  bool get hasActiveBindings => bindings.any((b) => b.isActive);

  // ==================== 加载操作 ====================

  Future<void> loadBindings() async {
    state = state.copyWith(
      bindingsState: AsyncLoading(previousData: bindings),
    );

    try {
      Logs.binding.info('加载绑定列表');

      final result = await _bindingService.getBindings();
      state = state.copyWith(
        bindingSummary: result,
        bindingsState: AsyncSuccess(result.bindings),
      );
      Logs.binding.info('绑定列表加载成功: ${bindings.length}');
    } catch (e, stackTrace) {
      state = state.copyWith(
        bindingsState: AsyncError('加载绑定列表失败: $e', e, stackTrace),
      );
      Logs.binding.error('加载绑定列表异常', stackTrace: stackTrace);
    }
  }

  Future<void> loadPendingRequests() async {
    Logs.binding.info('loadPendingRequests: start');
    state = state.copyWith(
      pendingRequestsState: AsyncLoading(previousData: pendingRequests),
    );

    try {
      Logs.binding.info('loadPendingRequests: calling service');
      final requests = await _bindingService.getPendingRequests();
      Logs.binding.info('loadPendingRequests: got ${requests.length} requests');
      state = state.copyWith(
        pendingRequestsState: AsyncSuccess(requests),
      );
      Logs.binding.info('loadPendingRequests: state updated');
    } catch (e, stackTrace) {
      Logs.binding.error('loadPendingRequests: error $e');
      state = state.copyWith(
        pendingRequestsState: AsyncError('加载待确认请求失败: $e', e, stackTrace),
      );
    }
  }

  Future<void> loadSentRequests() async {
    state = state.copyWith(
      sentRequestsState: AsyncLoading(previousData: sentRequests),
    );

    try {
      final requests = await _bindingService.getSentRequests();
      state = state.copyWith(
        sentRequestsState: AsyncSuccess(requests),
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        sentRequestsState: AsyncError('加载已发出请求失败: $e', e, stackTrace),
      );
    }
  }

  Future<void> refresh() async {
    await loadBindings();
  }

  // ==================== 绑定操作 ====================

  /// 字段级校验（无副作用）
  ///
  /// widget 收集用户输入后调用，根据返回的 [BindingValidationError] 路由到对应字段。
  BindingValidationError? validateRequestInput(BindingRequestInput input) {
    return _bindingService.validateRequestInput(input);
  }

  /// 提交绑定请求
  ///
  /// service 负责 +86 前缀拼接和字段名映射，notifier 负责状态更新。
  /// 成功时刷新绑定列表和已发送请求列表。
  Future<bool> submitBindingRequest(BindingRequestInput input) async {
    state = state.copyWith(lastErrorMessage: null);

    try {
      Logs.binding.info('发送绑定请求', data: {
        'receiver_phone': '+86 ${input.phone}',
        'sender_name': input.name,
        'receiver_name': input.partnerName,
      });

      await _bindingService.submitRequest(input);

      Logs.binding.info('绑定请求发送成功');
      await loadBindings();
      await loadSentRequests();
      return true;
    } catch (e, stackTrace) {
      final errorMessage = '发送绑定请求失败: $e';
      state = state.copyWith(
        lastErrorMessage: errorMessage,
        bindingsState: AsyncError(errorMessage, e, stackTrace),
      );
      return false;
    }
  }

  Future<bool> confirmRequest(String partnerUserId) async {
    try {
      await _bindingService.confirm(partnerUserId);
      await loadBindings();
      await loadPendingRequests();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectRequest(String partnerUserId) async {
    try {
      await _bindingService.reject(partnerUserId);
      await loadPendingRequests();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> revokeBinding(String partnerUserId) async {
    try {
      await _bindingService.revoke(partnerUserId);
      await loadBindings();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelSentRequest(String partnerUserId) async {
    state = state.copyWith(lastErrorMessage: null);

    try {
      await _bindingService.cancelRequest(partnerUserId);
      await loadSentRequests();
      return true;
    } catch (e) {
      state = state.copyWith(
        lastErrorMessage: '取消请求失败: $e',
        sentRequestsState: AsyncError('取消请求失败: $e', e),
      );
      return false;
    }
  }

  void clearError() {
    if (state.bindingsState.isError && bindings.isNotEmpty) {
      state = state.copyWith(bindingsState: AsyncSuccess(bindings));
    }
  }
}

/// 绑定列表综合状态
class BindingListState {
  final AsyncState<List<Binding>> bindingsState;
  final AsyncState<List<PendingRequest>> pendingRequestsState;
  final AsyncState<List<SentRequest>> sentRequestsState;
  final BindingList? bindingSummary;
  final String? lastErrorMessage;

  const BindingListState({
    this.bindingsState = const AsyncInitial(),
    this.pendingRequestsState = const AsyncInitial(),
    this.sentRequestsState = const AsyncInitial(),
    this.bindingSummary,
    this.lastErrorMessage,
  });

  List<Binding> get bindings => bindingsState.data ?? [];
  List<PendingRequest> get pendingRequests => pendingRequestsState.data ?? [];
  List<SentRequest> get sentRequests => sentRequestsState.data ?? [];
  int get pendingRequestsCount => pendingRequests.length;
  bool get hasActiveBindings => bindings.any((b) => b.isActive);

  BindingListState copyWith({
    AsyncState<List<Binding>>? bindingsState,
    AsyncState<List<PendingRequest>>? pendingRequestsState,
    AsyncState<List<SentRequest>>? sentRequestsState,
    BindingList? bindingSummary,
    String? lastErrorMessage,
  }) {
    return BindingListState(
      bindingsState: bindingsState ?? this.bindingsState,
      pendingRequestsState: pendingRequestsState ?? this.pendingRequestsState,
      sentRequestsState: sentRequestsState ?? this.sentRequestsState,
      bindingSummary: bindingSummary ?? this.bindingSummary,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    );
  }
}

final bindingProvider = NotifierProvider<BindingNotifier, BindingListState>(
  BindingNotifier.new,
);