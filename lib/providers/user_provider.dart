import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/logger.dart';

/// 用户状态管理
class UserProvider extends ChangeNotifier {
  User? _user;
  ApiService? _apiService;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  ApiService? get apiService => _apiService;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null && _apiService != null;

  /// 初始化用户（从本地存储加载 openid）
  Future<void> init() async {
    try {
      Logs.auth.info('初始化用户状态');
      
      // TODO: 从本地存储加载 openid
      // final openid = await storage.read(key: Constants.storageKeyOpenid);
      
      // 模拟：暂无本地数据
      _user = null;
      _apiService = null;
      
      notifyListeners();
    } catch (e, stackTrace) {
      Logs.auth.error('初始化用户失败', data: {'error': e.toString()}, stackTrace: stackTrace);
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 登录/注册
  Future<bool> login({
    required String openid,
    String? phone,
    String? nickname,
    String userType = 'both',
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Logs.auth.info('开始登录', data: {'openid': openid});

      // 创建 API Service
      _apiService = ApiService(
        baseUrl: Constants.baseUrl,
        openid: openid,
      );

      // 调用注册/登录接口
      final response = await _apiService!.registerUser(
        openid: openid,
        phone: phone,
        nickname: nickname,
        userType: userType,
      );

      if (response.isSuccess) {
        // 保存用户信息
        _user = User.fromJson(response.data as Map<String, dynamic>);
        
        // TODO: 保存 openid 到本地存储
        // await storage.write(key: Constants.storageKeyOpenid, value: openid);
        
        Logs.auth.info('登录成功', data: {
          'openid': _user!.openid,
          'user_type': _user!.userType.name,
        });
        
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        Logs.auth.warning('登录失败', data: {'message': response.message});
        return false;
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      Logs.auth.error('登录异常', data: {'error': e.toString()}, stackTrace: stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 更新用户信息
  Future<bool> updateUser({
    String? nickname,
    String? userType,
  }) async {
    if (_apiService == null || _user == null) {
      _error = '未登录';
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService!.updateUser(
        nickname: nickname,
        userType: userType,
      );

      if (response.isSuccess) {
        _user = User.fromJson(response.data as Map<String, dynamic>);
        Logs.auth.info('用户信息更新成功');
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 退出登录
  Future<void> logout() async {
    Logs.auth.info('退出登录');
    
    _user = null;
    _apiService = null;
    _error = null;
    
    // TODO: 清除本地存储
    // await storage.delete(key: Constants.storageKeyOpenid);
    
    _apiService?.dispose();
    _apiService = null;
    
    notifyListeners();
  }

  /// 清除错误状态
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
