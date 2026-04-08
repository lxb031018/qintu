import 'package:flutter/foundation.dart';
import 'package:qintu/models/binding.dart';
import 'package:qintu/models/async_state.dart';
import 'package:qintu/services/api_client.dart';
import 'package:qintu/utils/constants.dart';
import 'package:qintu/utils/logger.dart';

/// 绑定关系状态管理
///
/// 重构说明（2026-04-05）：
/// - 引入 AsyncState 统一状态管理
/// - 简化错误处理和成功消息管理
/// - 使用 `AsyncState<List<Binding>>` 替代散列状态
///
/// 重构说明（2026-04-07）：
/// - 迁移到 ApiClient（Dio），删除 ApiService（http）依赖
///
/// 重构说明（2026-04-08）：
/// - 移除绑定码机制，改为纯手机号绑定
/// - 新增 requestPhoneBinding() 方法
/// - 新增待确认请求管理方法

class BindingProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  AsyncState<List<Binding>> _bindingsState = const AsyncInitial();
  AsyncState<List<PendingRequest>> _pendingRequestsState = const AsyncInitial();
  BindingList? _bindingSummary;

  // Getters
  AsyncState<List<Binding>> get bindingsState => _bindingsState;
  List<Binding> get bindings => _bindingsState.data ?? [];
  BindingList? get bindingSummary => _bindingSummary;

  // 待确认请求
  AsyncState<List<PendingRequest>> get pendingRequestsState => _pendingRequestsState;
  List<PendingRequest> get pendingRequests => _pendingRequestsState.data ?? [];

  // 便捷访问器
  bool get isLoading => _bindingsState.isLoading;
  String? get error => _bindingsState.errorMessage;

  /// 待确认请求数量
  int get pendingRequestsCount => pendingRequests.length;

  /// 是否有待确认的绑定请求
  bool get hasPendingRequests => pendingRequests.isNotEmpty;

  /// 作为发送者的绑定数量
  int get asSenderCount => _bindingSummary?.asSender ?? 0;

  /// 作为接收者的绑定数量
  int get asReceiverCount => _bindingSummary?.asReceiver ?? 0;

  /// 发送者是否达到绑定上限
  bool get isSenderLimitReached => asSenderCount >= Constants.maxReceiversPerSender;

  /// 接收者是否达到绑定上限
  bool get isReceiverLimitReached => asReceiverCount >= Constants.maxSendersPerReceiver;

  /// 是否有活跃的绑定关系
  bool get hasActiveBindings => bindings.any((b) => b.isActive);

  /// 获取所有作为发送者的绑定关系
  List<Binding> get senderBindings =>
      bindings.where((b) => b.myRole == MyRole.sender).toList();

  /// 获取所有作为接收者的绑定关系
  List<Binding> get receiverBindings =>
      bindings.where((b) => b.myRole == MyRole.receiver).toList();

  /// 加载绑定列表
  Future<void> loadBindings() async {
    _bindingsState = AsyncLoading(bindings);
    notifyListeners();

    try {
      Logs.binding.info('加载绑定列表');

      final response = await _apiClient.get<Map<String, dynamic>>('/api/bindings/my');

      if (response.isSuccessful && response.data != null) {
        final data = response.data!;

        // 解析绑定摘要信息
        _bindingSummary = BindingList.fromJson(data);

        // 解析绑定列表
        final bindingsJson = data['bindings'] as List<dynamic>;
        final bindingsList = bindingsJson
            .map((json) => Binding.fromJson(json as Map<String, dynamic>))
            .toList();

        _bindingsState = AsyncSuccess(bindingsList);

        Logs.binding.info('绑定列表加载成功', data: {
          'total': bindingsList.length,
          'as_sender': asSenderCount,
          'as_receiver': asReceiverCount,
        });
      } else {
        _bindingsState = AsyncError(response.message ?? '加载失败');
        Logs.binding.warning('加载绑定列表失败: ${response.message}');
      }
    } catch (e, stackTrace) {
      _bindingsState = AsyncError('加载绑定列表失败: $e', e, stackTrace);
      Logs.binding.error('加载绑定列表异常: $e', stackTrace: stackTrace);
    }

    notifyListeners();
  }

  /// 加载待确认的绑定请求
  Future<void> loadPendingRequests() async {
    _pendingRequestsState = AsyncLoading(pendingRequests);
    notifyListeners();

    try {
      Logs.binding.info('加载待确认绑定请求');

      final response = await _apiClient.get<List<dynamic>>('/api/bindings/pending');

      if (response.isSuccessful && response.data != null) {
        final requestsList = response.data!
            .map((json) => PendingRequest.fromJson(json as Map<String, dynamic>))
            .toList();

        _pendingRequestsState = AsyncSuccess(requestsList);

        Logs.binding.info('待确认请求加载成功', data: {
          'count': requestsList.length,
        });
      } else {
        _pendingRequestsState = AsyncError(response.message ?? '加载失败');
        Logs.binding.warning('加载待确认请求失败: ${response.message}');
      }
    } catch (e, stackTrace) {
      _pendingRequestsState = AsyncError('加载待确认请求失败: $e', e, stackTrace);
      Logs.binding.error('加载待确认请求异常: $e', stackTrace: stackTrace);
    }

    notifyListeners();
  }

  /// 刷新绑定列表
  Future<void> refresh() async {
    await loadBindings();
  }

  /// 发送手机号绑定请求
  Future<bool> requestPhoneBinding({
    required String receiverPhone,
    String? senderName,
  }) async {
    _bindingsState = AsyncLoading(bindings);
    notifyListeners();

    try {
      Logs.binding.info('发送绑定请求', data: {
        'receiver_phone': receiverPhone,
      });

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/bindings/request-phone',
        data: {
          'receiver_phone': receiverPhone,
          if (senderName != null) 'sender_name': senderName,
        },
      );

      if (response.isSuccessful) {
        Logs.binding.info('绑定请求发送成功');
        // 刷新列表
        await loadBindings();
        return true;
      } else {
        _bindingsState = AsyncError(response.message ?? '请求失败');
        return false;
      }
    } catch (e) {
      _bindingsState = AsyncError('发送绑定请求失败: $e', e);
      return false;
    }
  }

  /// 确认绑定请求
  Future<bool> confirmRequest(int requestId) async {
    _bindingsState = AsyncLoading(bindings);
    notifyListeners();

    try {
      Logs.binding.info('确认绑定请求', data: {
        'request_id': requestId,
      });

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/bindings/confirm-request',
        data: {'request_id': requestId},
      );

      if (response.isSuccessful) {
        Logs.binding.info('确认绑定成功');
        // 刷新列表和待确认请求
        await loadBindings();
        await loadPendingRequests();
        return true;
      } else {
        _bindingsState = AsyncError(response.message ?? '确认失败');
        return false;
      }
    } catch (e) {
      _bindingsState = AsyncError('确认绑定失败: $e', e);
      return false;
    }
  }

  /// 拒绝绑定请求
  Future<bool> rejectRequest(int requestId) async {
    _bindingsState = AsyncLoading(bindings);
    notifyListeners();

    try {
      Logs.binding.info('拒绝绑定请求', data: {
        'request_id': requestId,
      });

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/bindings/reject-request',
        data: {'request_id': requestId},
      );

      if (response.isSuccessful) {
        Logs.binding.info('拒绝绑定成功');
        // 刷新待确认请求
        await loadPendingRequests();
        return true;
      } else {
        _bindingsState = AsyncError(response.message ?? '拒绝失败');
        return false;
      }
    } catch (e) {
      _bindingsState = AsyncError('拒绝绑定失败: $e', e);
      return false;
    }
  }

  /// 解除绑定
  Future<bool> revokeBinding(int bindingId) async {
    _bindingsState = AsyncLoading(bindings);
    notifyListeners();

    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '/api/bindings/$bindingId',
      );

      if (response.isSuccessful) {
        Logs.binding.info('解除绑定成功');
        await loadBindings();
        return true;
      } else {
        _bindingsState = AsyncError(response.message ?? '解除失败');
        return false;
      }
    } catch (e) {
      _bindingsState = AsyncError('解除绑定失败: $e', e);
      return false;
    }
  }

  /// 清除错误状态
  void clearError() {
    if (_bindingsState.isError && bindings.isNotEmpty) {
      _bindingsState = AsyncSuccess(bindings);
      notifyListeners();
    }
  }
}

/// 待确认的绑定请求
class PendingRequest {
  final int id;
  final String? senderName;
  final String? senderNickname;
  final String? senderPhone;
  final DateTime createdAt;

  const PendingRequest({
    required this.id,
    this.senderName,
    this.senderNickname,
    this.senderPhone,
    required this.createdAt,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    return PendingRequest(
      id: json['id'] as int,
      senderName: json['sender_name'] as String?,
      senderNickname: json['sender_nickname'] as String?,
      senderPhone: json['sender_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
