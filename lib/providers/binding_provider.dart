import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncLoading, AsyncError;
import 'package:qintu/models/binding/binding.dart';
import 'package:qintu/models/common/async_state.dart';
import 'package:qintu/features/relationship_binding/service/binding_service.dart';
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
  List<Binding> get allBindings => bindings;

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
    state = state.copyWith(
      pendingRequestsState: AsyncLoading(previousData: pendingRequests),
    );

    try {
      final requests = await _bindingService.getPendingRequests();
      state = state.copyWith(
        pendingRequestsState: AsyncSuccess(requests),
      );
    } catch (e, stackTrace) {
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

  Future<bool> requestPhoneBinding({
    required String receiverPhone,
    String? senderName,
    String? receiverName,
  }) async {
    state = state.copyWith(lastErrorMessage: null);

    try {
      Logs.binding.info('发送绑定请求', data: {
        'receiver_phone': receiverPhone,
        'sender_name': senderName,
        'receiver_name': receiverName,
      });

      await _bindingService.requestBinding(
        receiverPhone: receiverPhone,
        senderName: senderName,
        receiverName: receiverName,
      );

      Logs.binding.info('绑定请求发送成功');
      await loadBindings();
      await loadSentRequests();
      return true;
    } catch (e) {
      final errorMessage = '发送绑定请求失败: $e';
      state = state.copyWith(
        lastErrorMessage: errorMessage,
        bindingsState: AsyncError(errorMessage),
      );
      return false;
    }
  }

  Future<bool> confirmRequest(int requestId) async {
    try {
      await _bindingService.confirm(requestId);
      await loadBindings();
      await loadPendingRequests();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectRequest(int requestId) async {
    try {
      await _bindingService.reject(requestId);
      await loadPendingRequests();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> revokeBinding(int bindingId) async {
    try {
      await _bindingService.revoke(bindingId);
      await loadBindings();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelSentRequest(int requestId) async {
    state = state.copyWith(lastErrorMessage: null);

    try {
      await _bindingService.cancelRequest(requestId);
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