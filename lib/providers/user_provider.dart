import 'package:flutter/foundation.dart';
import 'package:qintu/models/user.dart';
import 'package:qintu/models/async_state.dart';
import 'package:qintu/services/api_service.dart';
import 'package:qintu/utils/constants.dart';
import 'package:qintu/utils/logger.dart';

/// 用户状态管理
///
/// 重构说明（2026-04-05）：
/// - 引入 AsyncState 统一状态管理
/// - 解耦 ApiService 创建逻辑
/// - 简化错误处理

class UserProvider extends ChangeNotifier {
  User? _user;
  ApiService? _apiService;
  AsyncState<User> _userState = const AsyncInitial();

  User? get user => _user;
  ApiService? get apiService => _apiService;
  AsyncState<User> get userState => _userState;

  // 便捷访问器
  bool get isLoading => _userState.isLoading;
  String? get error => _userState.errorMessage;
  bool get isLoggedIn => _user != null && _apiService != null;

  /// 初始化用户（从本地存储加载 openid）
  Future<void> init() async {
    _userState = const AsyncLoading();
    notifyListeners();

    try {
      Logs.auth.info('初始化用户状态');

      // TODO: 从本地存储加载 openid
      _user = null;
      _apiService = null;

      _userState = const AsyncInitial();
      notifyListeners();
    } catch (e, stackTrace) {
      Logs.auth.error('初始化用户失败: $e', stackTrace: stackTrace);
      _userState = AsyncError('初始化用户失败: $e', e, stackTrace);
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
    _userState = AsyncLoading(_user);
    notifyListeners();

    try {
      Logs.auth.info('开始登录');

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
        _userState = AsyncSuccess(_user!);

        Logs.auth.info('登录成功');
        notifyListeners();
        return true;
      } else {
        _userState = AsyncError(response.message);
        Logs.auth.warning('登录失败: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _userState = AsyncError('登录失败: $e', e, stackTrace);
      Logs.auth.error('登录异常: $e', stackTrace: stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// 更新用户信息
  Future<bool> updateUser({
    String? nickname,
    String? userType,
  }) async {
    if (_apiService == null || _user == null) {
      _userState = const AsyncError('未登录');
      notifyListeners();
      return false;
    }

    _userState = AsyncLoading(_user);
    notifyListeners();

    try {
      final response = await _apiService!.updateUser(
        nickname: nickname,
        userType: userType,
      );

      if (response.isSuccess) {
        _user = User.fromJson(response.data as Map<String, dynamic>);
        _userState = AsyncSuccess(_user!);
        Logs.auth.info('用户信息更新成功');
        notifyListeners();
        return true;
      } else {
        _userState = AsyncError(response.message);
        return false;
      }
    } catch (e) {
      _userState = AsyncError('更新用户信息失败: $e', e);
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    Logs.auth.info('退出登录');

    _user = null;
    _apiService?.dispose();
    _apiService = null;
    _userState = const AsyncInitial();

    notifyListeners();
  }

  /// 清除错误状态
  void clearError() {
    if (_userState.isError) {
      _userState = _user != null
          ? AsyncSuccess(_user!)
          : const AsyncInitial();
      notifyListeners();
    }
  }
}
