import 'package:flutter/foundation.dart';
import '../models/binding.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

/// 绑定关系状态管理
class BindingProvider extends ChangeNotifier {
  ApiService? _apiService;
  
  List<Binding> _bindings = [];
  BindingList? _bindingSummary;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Getters
  List<Binding> get bindings => _bindings;
  BindingList? get bindingSummary => _bindingSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  /// 作为发送者的绑定数量
  int get asSenderCount => _bindingSummary?.asSender ?? 0;
  
  /// 作为接收者的绑定数量
  int get asReceiverCount => _bindingSummary?.asReceiver ?? 0;
  
  /// 发送者是否达到绑定上限
  bool get isSenderLimitReached => asSenderCount >= Constants.maxReceiversPerSender;
  
  /// 接收者是否达到绑定上限
  bool get isReceiverLimitReached => asReceiverCount >= Constants.maxSendersPerReceiver;
  
  /// 是否有活跃的绑定关系
  bool get hasActiveBindings => _bindings.any((b) => b.isActive);
  
  /// 获取所有作为发送者的绑定关系
  List<Binding> get senderBindings => 
      _bindings.where((b) => b.myRole == MyRole.sender).toList();
  
  /// 获取所有作为接收者的绑定关系
  List<Binding> get receiverBindings => 
      _bindings.where((b) => b.myRole == MyRole.receiver).toList();

  BindingProvider();

  /// 初始化 API Service（登录后调用）
  void init(ApiService apiService) {
    _apiService = apiService;
    Logs.binding.info('BindingProvider 初始化');
  }

  /// 加载绑定列表
  Future<void> loadBindings() async {
    if (_apiService == null) {
      _error = '未初始化 API 服务，请先调用 init() 方法';
      Logs.binding.warning('加载绑定列表失败: $_error');
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      Logs.binding.info('加载绑定列表');

      final response = await _apiService!.getMyBindings();

      if (response.isSuccess) {
        final data = response.data!;
        
        // 解析绑定摘要信息
        _bindingSummary = BindingList.fromJson(data);
        
        // 解析绑定列表
        final bindingsJson = data['bindings'] as List<dynamic>;
        _bindings = bindingsJson
            .map((json) => Binding.fromJson(json as Map<String, dynamic>))
            .toList();

        Logs.binding.info('绑定列表加载成功', data: {
          'total': _bindings.length,
          'as_sender': asSenderCount,
          'as_receiver': asReceiverCount,
        });
      } else {
        _error = response.message;
        Logs.binding.warning('加载绑定列表失败', data: {'message': response.message});
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      Logs.binding.error('加载绑定列表异常', data: {'error': e.toString()}, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 生成绑定码
  Future<String?> generateBindCode({
    String? receiverPhone,
    String? remark,
  }) async {
    if (_apiService == null) {
      _error = '未初始化 API 服务，请先调用 init() 方法';
      Logs.binding.warning('生成绑定码失败: $_error');
      notifyListeners();
      return null;
    }

    if (isSenderLimitReached) {
      _error = '绑定人数已达上限（最多${Constants.maxReceiversPerSender}个接收者）';
      Logs.binding.warning('生成绑定码失败: $_error');
      notifyListeners();
      return null;
    }

    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      Logs.binding.info('生成绑定码', data: {
        'receiver_phone': receiverPhone,
        'remark': remark,
      });

      final response = await _apiService!.generateBindCode(
        receiverPhone: receiverPhone,
        remark: remark,
      );

      if (response.isSuccess) {
        final bindCode = response.data!['bind_code'] as String;
        
        _successMessage = response.data!['message'] as String? ?? '绑定码生成成功';
        
        Logs.binding.info('绑定码生成成功', data: {'bind_code': bindCode});
        
        // 刷新绑定列表
        await loadBindings();
        
        return bindCode;
      } else {
        _error = response.message;
        Logs.binding.warning('生成绑定码失败', data: {'message': response.message});
        return null;
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      Logs.binding.error('生成绑定码异常', data: {'error': e.toString()}, stackTrace: stackTrace);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 确认绑定（接收者输入绑定码）
  Future<bool> confirmBinding(String bindCode) async {
    if (_apiService == null) {
      _error = '未初始化 API 服务，请先调用 init() 方法';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      Logs.binding.info('确认绑定', data: {'bind_code': bindCode});

      final response = await _apiService!.confirmBinding(bindCode: bindCode);

      if (response.isSuccess) {
        _successMessage = response.data!['message'] as String? ?? '绑定成功';
        
        Logs.binding.info('绑定成功');
        
        // 刷新绑定列表
        await loadBindings();
        
        return true;
      } else {
        _error = response.message;
        Logs.binding.warning('绑定失败', data: {'message': response.message});
        return false;
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      Logs.binding.error('确认绑定异常', data: {'error': e.toString()}, stackTrace: stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 解除绑定
  Future<bool> revokeBinding(int bindingId) async {
    if (_apiService == null) {
      _error = '未初始化 API 服务，请先调用 init() 方法';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      Logs.binding.info('解除绑定', data: {'binding_id': bindingId});

      final response = await _apiService!.revokeBinding(bindingId);

      if (response.isSuccess) {
        _successMessage = '已成功解除绑定';
        
        Logs.binding.info('解除绑定成功');
        
        // 刷新绑定列表
        await loadBindings();
        
        return true;
      } else {
        _error = response.message;
        Logs.binding.warning('解除绑定失败', data: {'message': response.message});
        return false;
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      Logs.binding.error('解除绑定异常', data: {'error': e.toString()}, stackTrace: stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 检查绑定码是否有效
  Future<Map<String, dynamic>?> checkBindCode(String bindCode) async {
    if (_apiService == null) {
      _error = '未初始化 API 服务，请先调用 init() 方法';
      Logs.binding.warning('检查绑定码失败: $_error');
      notifyListeners();
      return null;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Logs.binding.info('检查绑定码有效性', data: {'bind_code': bindCode});

      final response = await _apiService!.checkBindCode(bindCode);

      if (response.isSuccess) {
        Logs.binding.info('绑定码有效', data: {'bind_code': bindCode});
        return response.data;
      } else {
        _error = response.message;
        Logs.binding.warning('绑定码无效', data: {'bind_code': bindCode, 'message': response.message});
        return null;
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      Logs.binding.error('检查绑定码异常', data: {'error': e.toString()}, stackTrace: stackTrace);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 清除错误状态
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 清除成功消息
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  /// 刷新绑定数据
  Future<void> refresh() async {
    await loadBindings();
  }
}
