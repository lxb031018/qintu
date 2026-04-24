import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncLoading, AsyncError;
import 'package:qintu/models/binding/binding.dart';
import 'package:qintu/models/common/async_state.dart';
import 'package:qintu/core/http/api_client.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/constants/api_endpoints.dart';
import 'package:qintu/constants/binding_limits.dart';
import 'package:qintu/constants/app_strings.dart';

/// ============================================
/// 绑定关系状态管理
///
/// Notifier，统一状态管理
/// ============================================

class BindingNotifier extends Notifier<BindingListState> {
  ApiClient get _apiClient => ApiClient();

  @override
  BindingListState build() {
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

      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.getMyBindings);

      if (response.isSuccessful && response.data != null) {
        final responseData = response.data!;
        final bindingData = responseData['data'] as Map<String, dynamic>? ?? responseData;
        state = state.copyWith(
          bindingSummary: BindingList.fromJson(bindingData),
          bindingsState: AsyncSuccess(
            (bindingData['bindings'] as List<dynamic>? ?? [])
                .map((json) => Binding.fromJson(json as Map<String, dynamic>))
                .toList(),
          ),
        );
        Logs.binding.info('绑定列表加载成功: ${bindings.length}');
      } else {
        state = state.copyWith(
          bindingsState: AsyncError(response.message ?? '加载失败'),
        );
      }
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
      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.getPendingRequests);

      if (response.isSuccessful && response.data != null) {
        final responseData = response.data!;
        final requestsData = responseData['data'] as List<dynamic>? ?? [];
        state = state.copyWith(
          pendingRequestsState: AsyncSuccess(
            requestsData.map((json) => PendingRequest.fromJson(json as Map<String, dynamic>)).toList(),
          ),
        );
      } else {
        state = state.copyWith(
          pendingRequestsState: AsyncError(response.message ?? '加载失败'),
        );
      }
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
      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.getSentRequests);

      if (response.isSuccessful && response.data != null) {
        final responseData = response.data!;
        final requestsData = responseData['data'] as List<dynamic>? ?? [];
        state = state.copyWith(
          sentRequestsState: AsyncSuccess(
            requestsData.map((json) => SentRequest.fromJson(json as Map<String, dynamic>)).toList(),
          ),
        );
      } else {
        state = state.copyWith(
          sentRequestsState: AsyncError(response.message ?? '加载失败'),
        );
      }
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

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.requestPhoneBinding,
        data: {
          'receiver_phone': receiverPhone,
          'sender_name': senderName,
          'receiver_name': receiverName,
        },
      );

      if (response.isSuccessful) {
        Logs.binding.info('绑定请求发送成功');
        await loadBindings();
        await loadSentRequests();
        return true;
      } else {
        final errorMessage = response.message ?? '请求失败';
        state = state.copyWith(
          lastErrorMessage: errorMessage,
          bindingsState: AsyncError(errorMessage),
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        lastErrorMessage: '发送绑定请求失败: $e',
        bindingsState: AsyncError('发送绑定请求失败: $e', e),
      );
      return false;
    }
  }

  Future<bool> confirmRequest(int requestId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.confirmRequest,
        data: {'request_id': requestId},
      );

      if (response.isSuccessful) {
        await loadBindings();
        await loadPendingRequests();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectRequest(int requestId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.rejectRequest,
        data: {'request_id': requestId},
      );

      if (response.isSuccessful) {
        await loadPendingRequests();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> revokeBinding(int bindingId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiEndpoints.revokeBinding}/$bindingId',
      );

      if (response.isSuccessful) {
        await loadBindings();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelSentRequest(int requestId) async {
    state = state.copyWith(lastErrorMessage: null);

    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        ApiEndpoints.cancelSentRequest(requestId),
      );

      if (response.isSuccessful) {
        await loadSentRequests();
        return true;
      } else {
        state = state.copyWith(
          lastErrorMessage: response.message ?? '取消失败',
          sentRequestsState: AsyncError(response.message ?? '取消失败'),
        );
        return false;
      }
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

/// 待确认的绑定请求
class PendingRequest {
  final int id;
  final String? senderName;
  final String? senderPhone;
  final DateTime createdAt;
  final DateTime expiredAt;

  const PendingRequest({
    required this.id,
    this.senderName,
    this.senderPhone,
    required this.createdAt,
    required this.expiredAt,
  });

  Duration get timeRemaining => expiredAt.difference(DateTime.now());
  bool get isExpiringSoon => timeRemaining.inHours > 0 && timeRemaining.inHours < 24;
  bool get isExpired => timeRemaining.isNegative;

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    return PendingRequest(
      id: json['id'] as int,
      senderName: json['sender_name'] as String?,
      senderPhone: json['sender_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiredAt: json['expired_at'] != null
          ? DateTime.parse(json['expired_at'] as String)
          : DateTime.parse(json['created_at'] as String).add(const Duration(days: 7)),
    );
  }
}

/// 我发出的绑定请求
class SentRequest {
  final int id;
  final String status;
  final String? receiverNickname;
  final String? receiverPhone;
  final DateTime createdAt;
  final DateTime? expiredAt;
  final DateTime? rejectedAt;

  const SentRequest({
    required this.id,
    required this.status,
    this.receiverNickname,
    this.receiverPhone,
    required this.createdAt,
    this.expiredAt,
    this.rejectedAt,
  });

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'revoked' && rejectedAt != null;
  bool get isUnbound => status == 'revoked' && rejectedAt == null;
  bool get isExpired => status == 'expired';
  bool get isActive => status == 'active';

  String get statusText {
    switch (status) {
      case 'pending':
        return AppStrings.waitingForConfirmation;
      case 'revoked':
        return isRejected ? AppStrings.requestRejected : AppStrings.bindingUnbound;
      case 'expired':
        return AppStrings.requestExpired;
      case 'active':
        return AppStrings.requestActive;
      default:
        return AppStrings.unknownStatus;
    }
  }

  Duration get timeRemaining {
    if (expiredAt == null) return Duration.zero;
    return expiredAt!.difference(DateTime.now());
  }

  bool get isExpiringSoon => isPending && timeRemaining.inHours > 0 && timeRemaining.inHours < 24;
  bool get isTimeExpired => isPending && timeRemaining.isNegative;

  String get expiredAtText {
    if (isTimeExpired) return AppStrings.requestExpired;
    if (!isPending) return statusText;
    if (expiredAt == null) return AppStrings.requestExpired;
    final hours = timeRemaining.inHours;
    if (hours < 1) return AppStrings.lessThanOneHour;
    if (hours < 24) return AppStrings.hoursUntilExpire(hours);
    final days = (hours / 24).ceil();
    return AppStrings.daysUntilExpire(days);
  }

  factory SentRequest.fromJson(Map<String, dynamic> json) {
    return SentRequest(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'pending',
      receiverNickname: json['receiver_nickname'] as String?,
      receiverPhone: json['receiver_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiredAt: json['expired_at'] != null
          ? DateTime.parse(json['expired_at'] as String)
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : null,
    );
  }
}

final bindingProvider = NotifierProvider<BindingNotifier, BindingListState>(
  BindingNotifier.new,
);