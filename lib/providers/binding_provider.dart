import 'package:flutter/foundation.dart';
import 'package:qintu/models/binding.dart';
import 'package:qintu/models/async_state.dart';
import 'package:qintu/services/api_service.dart';
import 'package:qintu/utils/constants.dart';
import 'package:qintu/utils/logger.dart';

/// 绑定关系状态管理
///
/// 重构说明（2026-04-05）：
/// - 引入 AsyncState 统一状态管理
/// - 简化错误处理和成功消息管理
/// - 使用 `AsyncState<List<Binding>>` 替代散列状态

class BindingProvider extends ChangeNotifier {
  ApiService? _apiService;
  AsyncState<List<Binding>> _bindingsState = const AsyncInitial();
  BindingList? _bindingSummary;

  // Getters
  AsyncState<List<Binding>> get bindingsState => _bindingsState;
  List<Binding> get bindings => _bindingsState.data ?? [];
  BindingList? get bindingSummary => _bindingSummary;

  // 便捷访问器
  bool get isLoading => _bindingsState.isLoading;
  String? get error => _bindingsState.errorMessage;

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

  /// 初始化 API Service（登录后调用）
  void init(ApiService apiService) {
    _apiService = apiService;
    Logs.binding.info('BindingProvider 初始化');
  }

  /// 加载绑定列表
  Future<void> loadBindings() async {
    if (_apiService == null) {
      _bindingsState = const AsyncError('未初始化 API 服务');
      Logs.binding.warning('加载绑定列表失败: 未初始化 API 服务');
      notifyListeners();
      return;
    }

    _bindingsState = AsyncLoading(bindings);
    notifyListeners();

    try {
      Logs.binding.info('加载绑定列表');

      final response = await _apiService!.getMyBindings();

      if (response.isSuccess) {
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
        _bindingsState = AsyncError(response.message);
        Logs.binding.warning('加载绑定列表失败: ${response.message}');
      }
    } catch (e, stackTrace) {
      _bindingsState = AsyncError('加载绑定列表失败: $e', e, stackTrace);
      Logs.binding.error('加载绑定列表异常: $e', stackTrace: stackTrace);
    }

    notifyListeners();
  }

  /// 刷新绑定列表
  Future<void> refresh() async {
    await loadBindings();
  }

  /// 生成绑定码
  Future<bool> generateBindCode({
    String? receiverPhone,
    String? remark,
  }) async {
    if (_apiService == null) return false;

    _bindingsState = AsyncLoading(bindings);
    notifyListeners();

    try {
      final response = await _apiService!.generateBindCode(
        receiverPhone: receiverPhone,
        remark: remark,
      );

      if (response.isSuccess) {
        Logs.binding.info('生成绑定码成功');
        // 刷新列表
        await loadBindings();
        return true;
      } else {
        _bindingsState = AsyncError(response.message);
        return false;
      }
    } catch (e) {
      _bindingsState = AsyncError('生成绑定码失败: $e', e);
      return false;
    }
  }

  /// 确认绑定
  Future<bool> confirmBinding(String bindCode) async {
    if (_apiService == null) return false;

    _bindingsState = AsyncLoading(bindings);
    notifyListeners();

    try {
      final response = await _apiService!.confirmBinding(bindCode: bindCode);

      if (response.isSuccess) {
        Logs.binding.info('确认绑定成功');
        await loadBindings();
        return true;
      } else {
        _bindingsState = AsyncError(response.message);
        return false;
      }
    } catch (e) {
      _bindingsState = AsyncError('确认绑定失败: $e', e);
      return false;
    }
  }

  /// 解除绑定
  Future<bool> revokeBinding(int bindingId) async {
    if (_apiService == null) return false;

    _bindingsState = AsyncLoading(bindings);
    notifyListeners();

    try {
      final response = await _apiService!.revokeBinding(bindingId);

      if (response.isSuccess) {
        Logs.binding.info('解除绑定成功');
        await loadBindings();
        return true;
      } else {
        _bindingsState = AsyncError(response.message);
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

  /// 释放资源
  @override
  void dispose() {
    _apiService = null;
    super.dispose();
  }
}
