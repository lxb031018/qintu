import 'package:flutter/foundation.dart';
import '../models/user_state.dart';
import '../../services/secure_storage.dart';
import '../../utils/logger.dart';

/// 用户状态管理器
///
/// 使用 ChangeNotifier 管理用户认证状态
/// 负责：
/// - 初始化和检查登录状态
/// - 登录/登出操作
/// - Token 管理
/// - 状态同步
class UserStateManager extends ChangeNotifier {
  UserState _state = const UserState.initial();
  UserState get state => _state;

  /// 初始化用户状态（应用启动时调用）
  Future<void> initialize() async {
    Logs.auth.info('========== 开始初始化用户状态 ==========');
    Logs.auth.info('当前状态: ${_state.authStatus}');

    try {
      Logs.auth.info('正在检查 SecureStorage.isLoggedIn()...');
      final isLoggedIn = await SecureStorage.isLoggedIn();
      Logs.auth.info('isLoggedIn = $isLoggedIn');

      if (isLoggedIn) {
        Logs.auth.info('用户已登录，正在获取登录信息...');
        final loginInfo = await SecureStorage.getLoginInfo();
        Logs.auth.info('获取到 loginInfo: user_id=${loginInfo?.userId}, user_role=${loginInfo?.userRole}');

        _state = _state.copyWith(
          authStatus: AuthStatus.authenticated,
          userId: loginInfo?.userId,
          accessToken: loginInfo?.accessToken,
          refreshToken: loginInfo?.refreshToken,
          phoneNumber: loginInfo?.phoneNumber,
          userRole: loginInfo?.userRole,
          isLoading: false,
        );

        Logs.auth.info('✅ 用户状态初始化成功：已登录 (角色: ${_state.userRole})');
      } else {
        Logs.auth.info('用户未登录，设置为 unauthenticated');
        _state = const UserState(
          authStatus: AuthStatus.unauthenticated,
          isLoading: false,
        );

        Logs.auth.info('✅ 用户状态初始化成功：未登录');
      }

      Logs.auth.info('正在调用 notifyListeners()...');
      notifyListeners();
      Logs.auth.info('========== 用户状态初始化完成 ==========');
    } catch (e, stackTrace) {
      Logs.auth.info('❌ 用户状态初始化失败: $e');
      Logs.auth.info('堆栈: $stackTrace');
      _state = const UserState(
        authStatus: AuthStatus.unauthenticated,
        isLoading: false,
      );
      notifyListeners();
      Logs.auth.info('========== 用户状态初始化完成（异常路径） ==========');
    }
  }

  /// 登录成功，保存状态
  Future<void> setAuthenticated({
    required String userId,
    required String accessToken,
    required String refreshToken,
    required int accessTokenExpiresIn,
    required int refreshTokenExpiresIn,
    required String phoneNumber,
    String? userRole,
  }) async {
    Logs.auth.info('开始设置认证状态，用户ID: $userId');
    
    try {
      // 保存到安全存储
      await SecureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresIn: accessTokenExpiresIn,
        refreshTokenExpiresIn: refreshTokenExpiresIn,
        phoneNumber: phoneNumber,
        userId: userId,
        role: userRole,
      );
      
      // 更新状态
      _state = _state.copyWith(
        authStatus: AuthStatus.authenticated,
        userId: userId,
        accessToken: accessToken,
        refreshToken: refreshToken,
        phoneNumber: phoneNumber,
        userRole: userRole,
        isLoading: false,
        errorMessage: null,
      );
      
      Logs.auth.info('✅ 认证状态设置成功');
      notifyListeners();
    } catch (e, stackTrace) {
      Logs.auth.info('❌ 设置认证状态失败: $e\n$stackTrace');
      _state = _state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: '登录失败: ${e.toString()}',
      );
      notifyListeners();
      rethrow;
    }
  }

  /// 更新用户角色
  Future<void> updateUserRole(String role) async {
    Logs.auth.info('更新用户角色: $role');
    
    try {
      await SecureStorage.saveRole(role);
      
      _state = _state.copyWith(
        userRole: role,
        errorMessage: null,
      );
      
      Logs.auth.info('✅ 角色更新成功: $role');
      notifyListeners();
    } catch (e, stackTrace) {
      Logs.auth.info('❌ 更新角色失败: $e\n$stackTrace');
      _state = _state.copyWith(
        errorMessage: '更新角色失败: ${e.toString()}',
      );
      notifyListeners();
      rethrow;
    }
  }

  /// 登出，清除所有状态
  Future<void> logout() async {
    Logs.auth.info('开始退出登录...');
    
    try {
      // 设置为加载状态
      _state = _state.copyWith(
        isLoading: true,
        errorMessage: null,
      );
      notifyListeners();
      
      // 清除安全存储
      await SecureStorage.clearTokens();
      
      // 重置状态
      _state = const UserState(
        authStatus: AuthStatus.unauthenticated,
        isLoading: false,
      );
      
      Logs.auth.info('✅ 退出登录成功');
      notifyListeners();
    } catch (e, stackTrace) {
      Logs.auth.info('❌ 退出登录失败: $e\n$stackTrace');
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: '退出登录失败: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  /// 设置加载状态
  void setLoading(bool loading) {
    if (_state.isLoading != loading) {
      _state = _state.copyWith(isLoading: loading);
      notifyListeners();
    }
  }

  /// 设置错误消息
  void setError(String? error) {
    if (_state.errorMessage != error) {
      _state = _state.copyWith(errorMessage: error);
      notifyListeners();
    }
  }

  /// 清除错误消息
  void clearError() {
    if (_state.errorMessage != null) {
      _state = _state.copyWith(errorMessage: null);
      notifyListeners();
    }
  }

  /// 刷新 Token（用于 Token 过期时）
  Future<void> refreshTokens() async {
    Logs.auth.info('开始刷新 Token...');
    
    try {
      final refreshToken = _state.refreshToken;
      if (refreshToken == null) {
        throw Exception('没有可用的 Refresh Token');
      }
      
      // TODO: 实现 Token 刷新逻辑
      // 这里需要调用后端的 Token 刷新接口
      
      Logs.auth.info('⚠️ Token 刷新功能尚未实现');
    } catch (e, stackTrace) {
      Logs.auth.info('❌ Token 刷新失败: $e\n$stackTrace');
      // Token 刷新失败，需要重新登录
      await logout();
      rethrow;
    }
  }

  @override
  void dispose() {
    Logs.auth.info('UserStateManager 被销毁');
    super.dispose();
  }
}
