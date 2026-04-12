import 'package:flutter/foundation.dart';
import 'package:qintu/models/binding.dart';
import 'package:qintu/models/async_state.dart';
import 'package:qintu/services/api_client.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/constants/app_strings.dart';
import 'package:qintu/constants/api_endpoints.dart';
import 'package:qintu/constants/binding_limits.dart';

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
  final ApiClient _apiClient;

  /// 构造函数注入 ApiClient，提升可测试性
  /// 
  /// 参数说明：
  /// - [apiClient]: 可选的 ApiClient 实例，用于单元测试时注入 Mock 客户端
  ///   如果不传，则默认使用 ApiClient.instance（生产环境）
  BindingProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  AsyncState<List<Binding>> _bindingsState = const AsyncInitial();
  AsyncState<List<PendingRequest>> _pendingRequestsState = const AsyncInitial();
  AsyncState<List<SentRequest>> _sentRequestsState = const AsyncInitial();
  BindingList? _bindingSummary;
  String? _lastErrorMessage;

  // Getters
  AsyncState<List<Binding>> get bindingsState => _bindingsState;
  List<Binding> get bindings => _bindingsState.data ?? [];
  BindingList? get bindingSummary => _bindingSummary;

  // 待确认请求
  AsyncState<List<PendingRequest>> get pendingRequestsState => _pendingRequestsState;
  List<PendingRequest> get pendingRequests => _pendingRequestsState.data ?? [];

  // 我发出的请求
  AsyncState<List<SentRequest>> get sentRequestsState => _sentRequestsState;
  List<SentRequest> get sentRequests => _sentRequestsState.data ?? [];

  // 便捷访问器
  bool get isLoading => _bindingsState.isLoading;
  String? get error => _bindingsState.errorMessage;

  /// 最后一次操作的错误信息（用于显示具体的错误提示）
  String? get lastErrorMessage => _lastErrorMessage;

  /// 待确认请求数量
  int get pendingRequestsCount => pendingRequests.length;

  /// 我发出的请求数量
  int get sentRequestsCount => sentRequests.length;

  /// 是否有待确认的绑定请求
  bool get hasPendingRequests => pendingRequests.isNotEmpty;

  /// 是否有我发出的请求
  bool get hasSentRequests => sentRequests.isNotEmpty;

  /// 作为发送者的绑定数量
  int get asSenderCount => _bindingSummary?.asSender ?? 0;

  /// 作为接收者的绑定数量
  int get asReceiverCount => _bindingSummary?.asReceiver ?? 0;

  /// 总绑定数量
  int get totalBindings => asSenderCount + asReceiverCount;

  /// 是否达到绑定上限
  bool get isBindingLimitReached => totalBindings >= BindingLimits.maxBindingsPerUser;

  /// 是否有活跃的绑定关系
  bool get hasActiveBindings => bindings.any((b) => b.isActive);

  /// 统一绑定列表（不区分角色）
  List<Binding> get allBindings => bindings;

  /// 加载绑定列表
  Future<void> loadBindings() async {
    _bindingsState = AsyncLoading(previousData: bindings);
    notifyListeners();

    try {
      Logs.binding.info('加载绑定列表');

      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.getMyBindings);

      Logs.binding.debug('绑定列表响应', data: {
        'statusCode': response.statusCode,
        'isSuccessful': response.isSuccessful,
        'message': response.message,
        'hasData': response.data != null,
      });

      if (response.isSuccessful && response.data != null) {
        final responseData = response.data!;
        
        // 后端返回格式: {code, message, data: {total, as_sender, as_receiver, bindings: []}}
        final bindingData = responseData['data'] as Map<String, dynamic>? ?? responseData;

        // 解析绑定摘要信息
        _bindingSummary = BindingList.fromJson(bindingData);

        // 解析绑定列表
        final bindingsJson = bindingData['bindings'] as List<dynamic>? ?? [];
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
        Logs.binding.warning('加载绑定列表失败', data: {
          'statusCode': response.statusCode,
          'message': response.message,
        });
      }
    } catch (e, stackTrace) {
      _bindingsState = AsyncError('加载绑定列表失败: $e', e, stackTrace);
      Logs.binding.error('加载绑定列表异常', data: {
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      }, stackTrace: stackTrace);
    }

    notifyListeners();
  }

  /// 加载待确认的绑定请求
  Future<void> loadPendingRequests() async {
    _pendingRequestsState = AsyncLoading(previousData: pendingRequests);
    notifyListeners();

    try {
      Logs.binding.info('加载待确认绑定请求');

      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.getPendingRequests);

      if (response.isSuccessful && response.data != null) {
        final responseData = response.data!;
        // 后端返回格式: {code, message, data: [...]}
        final requestsData = responseData['data'] as List<dynamic>? ?? responseData as List<dynamic>? ?? [];
        
        final requestsList = requestsData
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

  /// 加载我发出的绑定请求
  Future<void> loadSentRequests() async {
    _sentRequestsState = AsyncLoading(previousData: sentRequests);
    notifyListeners();

    try {
      Logs.binding.info('📤 开始加载已发出绑定请求');

      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.getSentRequests);

      if (response.isSuccessful && response.data != null) {
        final responseData = response.data!;
        // 后端返回格式: {code, message, data: [...]}
        final requestsData = responseData['data'] as List<dynamic>? ?? responseData as List<dynamic>? ?? [];

        Logs.binding.debug('📥 已发出请求原始数据', data: {
          'count': requestsData.length,
          'data': requestsData.map((e) => e.toString()).toList(),
        });

        final requestsList = requestsData
            .map((json) => SentRequest.fromJson(json as Map<String, dynamic>))
            .toList();

        // 统计各状态的请求数量
        final pendingCount = requestsList.where((r) => r.isPending).length;
        final rejectedCount = requestsList.where((r) => r.isRejected).length;
        final expiredCount = requestsList.where((r) => r.isExpired).length;
        final activeCount = requestsList.where((r) => r.isActive).length;

        _sentRequestsState = AsyncSuccess(requestsList);

        Logs.binding.info('✅ 已发出请求加载成功', data: {
          'total': requestsList.length,
          'pending': pendingCount,
          'rejected': rejectedCount,
          'expired': expiredCount,
          'active': activeCount,
        });

        // 打印每个请求的详细信息
        for (final request in requestsList) {
          Logs.binding.debug('📋 请求详情', data: {
            'id': request.id,
            'status': request.status,
            'statusText': request.statusText,
            'receiver': request.receiverNickname ?? '未知',
            'isRejected': request.isRejected,
          });
        }
      } else {
        _sentRequestsState = AsyncError(response.message ?? '加载失败');
        Logs.binding.warning('⚠️ 加载已发出请求失败: ${response.message}');
      }
    } catch (e, stackTrace) {
      _sentRequestsState = AsyncError('加载已发出请求失败: $e', e, stackTrace);
      Logs.binding.error('❌ 加载已发出请求异常: $e', stackTrace: stackTrace);
    }

    notifyListeners();
  }

  /// 刷新绑定列表
  Future<void> refresh() async {
    await loadBindings();
  }

  /// 发送手机号绑定请求
  ///
  /// 返回说明：
  /// - `true`: 请求发送成功
  /// - `false`: 请求失败，可通过 [lastErrorMessage] 获取具体错误信息
  Future<bool> requestPhoneBinding({
    required String receiverPhone,
    String? senderName,
    String? receiverName,
  }) async {
    _lastErrorMessage = null;
    _bindingsState = AsyncLoading(previousData: bindings);
    notifyListeners();

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

      Logs.binding.debug('绑定请求响应', data: {
        'statusCode': response.statusCode,
        'isSuccessful': response.isSuccessful,
        'message': response.message,
      });

      if (response.isSuccessful) {
        Logs.binding.info('绑定请求发送成功');
        // 刷新列表
        await loadBindings();
        await loadSentRequests();
        return true;
      } else {
        // 提取后端返回的具体错误信息
        final errorMessage = response.message ?? '请求失败';
        _lastErrorMessage = errorMessage;
        _bindingsState = AsyncError(errorMessage);
        Logs.binding.warning('发送绑定请求失败', data: {
          'statusCode': response.statusCode,
          'message': errorMessage,
          'receiver_phone': receiverPhone,
        });
        return false;
      }
    } catch (e, stackTrace) {
      _lastErrorMessage = '发送绑定请求失败: $e';
      _bindingsState = AsyncError(_lastErrorMessage!, e);
      Logs.binding.error('发送绑定请求异常', data: {
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
        'receiver_phone': receiverPhone,
      }, stackTrace: stackTrace);
      return false;
    }
  }

  /// 确认绑定请求
  Future<bool> confirmRequest(int requestId) async {
    _bindingsState = AsyncLoading(previousData: bindings);
    notifyListeners();

    try {
      Logs.binding.info('确认绑定请求', data: {
        'request_id': requestId,
      });

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.confirmRequest,
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
    _bindingsState = AsyncLoading(previousData: bindings);
    notifyListeners();

    try {
      Logs.binding.info('❌ 拒绝绑定请求', data: {
        'request_id': requestId,
      });

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.rejectRequest,
        data: {'request_id': requestId},
      );

      if (response.isSuccessful) {
        Logs.binding.info('✅ 拒绝绑定成功，接收方已拒绝');
        // 刷新待确认请求
        await loadPendingRequests();
        return true;
      } else {
        Logs.binding.warning('⚠️ 拒绝绑定请求失败: ${response.message}');
        _bindingsState = AsyncError(response.message ?? '拒绝失败');
        return false;
      }
    } catch (e) {
      Logs.binding.error('❌ 拒绝绑定请求异常: $e');
      _bindingsState = AsyncError('拒绝绑定失败: $e', e);
      return false;
    }
  }

  /// 解除绑定
  Future<bool> revokeBinding(int bindingId) async {
    _bindingsState = AsyncLoading(previousData: bindings);
    notifyListeners();

    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiEndpoints.revokeBinding}/$bindingId',
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

  /// 取消我发出的绑定请求
  ///
  /// 返回说明：
  /// - `true`: 取消成功
  /// - `false`: 取消失败，可通过 [lastErrorMessage] 获取具体错误信息
  Future<bool> cancelSentRequest(int requestId) async {
    _lastErrorMessage = null;
    _sentRequestsState = AsyncLoading(previousData: sentRequests);
    notifyListeners();

    try {
      Logs.binding.info('取消已发出请求', data: {
        'request_id': requestId,
      });

      final response = await _apiClient.delete<Map<String, dynamic>>(
        ApiEndpoints.cancelSentRequest(requestId),
      );

      if (response.isSuccessful) {
        Logs.binding.info('取消请求成功');
        // 刷新已发出请求列表
        await loadSentRequests();
        return true;
      } else {
        final errorMessage = response.message ?? '取消失败';
        _lastErrorMessage = errorMessage;
        _sentRequestsState = AsyncError(errorMessage);
        Logs.binding.warning('取消请求失败', data: {
          'message': errorMessage,
          'request_id': requestId,
        });
        return false;
      }
    } catch (e, stackTrace) {
      _lastErrorMessage = '取消请求失败: $e';
      _sentRequestsState = AsyncError(_lastErrorMessage!, e);
      Logs.binding.error('取消请求异常', data: {
        'error': e.toString(),
        'request_id': requestId,
      }, stackTrace: stackTrace);
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
  final DateTime expiredAt;

  const PendingRequest({
    required this.id,
    this.senderName,
    this.senderNickname,
    this.senderPhone,
    required this.createdAt,
    required this.expiredAt,
  });

  /// 剩余时间
  Duration get timeRemaining => expiredAt.difference(DateTime.now());

  /// 是否即将过期（少于 24 小时）
  bool get isExpiringSoon => timeRemaining.inHours > 0 && timeRemaining.inHours < 24;

  /// 是否已过期
  bool get isExpired => timeRemaining.isNegative;

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    return PendingRequest(
      id: json['id'] as int,
      senderName: json['sender_name'] as String?,
      senderNickname: json['sender_nickname'] as String?,
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
  final String status; // pending, rejected, expired, active
  final String? senderName;
  final String? receiverNickname;
  final String? receiverPhone;
  final DateTime createdAt;
  final DateTime expiredAt;

  const SentRequest({
    required this.id,
    required this.status,
    this.senderName,
    this.receiverNickname,
    this.receiverPhone,
    required this.createdAt,
    required this.expiredAt,
  });

  /// 是否等待确认
  bool get isPending => status == 'pending';

  /// 是否被拒绝
  bool get isRejected => status == 'revoked';

  /// 是否已过期
  bool get isExpired => status == 'expired';

  /// 是否已激活（对方已确认）
  bool get isActive => status == 'active';

  /// 状态显示文本
  String get statusText {
    switch (status) {
      case 'pending':
        return AppStrings.waitingForConfirmation;
      case 'revoked':
        return AppStrings.requestRejected;
      case 'expired':
        return AppStrings.requestExpired;
      case 'active':
        return AppStrings.requestActive;
      default:
        return AppStrings.unknownStatus;
    }
  }

  /// 状态颜色
  // Color get statusColor {
  //   switch (status) {
  //     case 'pending':
  //       return Colors.orange;
  //     case 'revoked':
  //       return Colors.red;
  //     case 'expired':
  //       return Colors.grey;
  //     case 'active':
  //       return Colors.green;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  /// 剩余时间（仅对 pending 状态有意义）
  Duration get timeRemaining => expiredAt.difference(DateTime.now());

  /// 是否即将过期（少于 24 小时）
  bool get isExpiringSoon => isPending && timeRemaining.inHours > 0 && timeRemaining.inHours < 24;

  /// 是否已过期（时间上）
  bool get isTimeExpired => isPending && timeRemaining.isNegative;

  /// 过期时间显示文本
  String get expiredAtText {
    if (isTimeExpired) {
      return AppStrings.requestExpired;
    }
    if (!isPending) {
      return statusText;
    }
    final hours = timeRemaining.inHours;
    if (hours < 1) {
      return AppStrings.lessThanOneHour;
    }
    if (hours < 24) {
      return AppStrings.hoursUntilExpire(hours);
    }
    final days = (hours / 24).ceil();
    return AppStrings.daysUntilExpire(days);
  }

  factory SentRequest.fromJson(Map<String, dynamic> json) {
    return SentRequest(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'pending',
      senderName: json['sender_name'] as String?,
      receiverNickname: json['receiver_nickname'] as String?,
      receiverPhone: json['receiver_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiredAt: DateTime.parse(json['expired_at'] as String),
    );
  }
}
