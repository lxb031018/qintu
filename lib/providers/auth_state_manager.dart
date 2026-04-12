import 'package:flutter/foundation.dart';
import '../models/user_state.dart';
import '../services/secure_storage.dart';
import '../utils/logger.dart';
import '../config/auth_config.dart';

/// 认证状态管理器
///
/// 使用 ChangeNotifier 管理用户认证状态
/// 负责：
/// - 初始化和检查登录状态
/// - 登录/登出操作
/// - Token 管理
/// - 状态同步
class AuthStateManager extends ChangeNotifier {
  UserState _state = UserState.initial();
  UserState get state => _state;

  /// 初始化认证状态（应用启动时调用）
  Future<void> initialize() async {
    Logs.auth.info('========================================');
    Logs.auth.info('========== 开始初始化认证状态 ==========');
    Logs.auth.info('========================================');
    Logs.auth.info('当前状态: ${_state.authStatus}');

    try {
      Logs.auth.info('步骤 1/4: 正在检查 SecureStorage.isLoggedIn()...');
      final isLoggedIn = await SecureStorage.isLoggedIn();
      Logs.auth.info('步骤 1/4 完成: isLoggedIn = $isLoggedIn');

      if (isLoggedIn) {
        Logs.auth.info('步骤 2/4: 用户已登录，正在获取登录信息...');
        final loginInfo = await SecureStorage.getLoginInfo();
        Logs.auth.info('步骤 2/4 完成: 获取到 loginInfo');
        
        if (loginInfo != null) {
          Logs.auth.info('  - user_id: ${loginInfo.userId}');
          Logs.auth.info('  - phone_number: ${loginInfo.phoneNumber}');
          Logs.auth.info('  - has_access_token: ${loginInfo.accessToken.isNotEmpty}');
          Logs.auth.info('  - has_refresh_token: ${loginInfo.refreshToken != null && loginInfo.refreshToken!.isNotEmpty}');
        } else {
          Logs.auth.warning('步骤 2/4 警告: loginInfo 为 null，但 isLoggedIn 返回 true');
        }

        Logs.auth.info('步骤 3/4: 正在更新状态为 authenticated...');
        _state = _state.copyWith(
          authStatus: AuthStatus.authenticated,
          userId: loginInfo?.userId,
          phoneNumber: loginInfo?.phoneNumber,
          isLoading: false,
        );

        Logs.auth.info('步骤 3/4 完成: 状态已更新为 authenticated');
        Logs.auth.info('✅ 认证状态初始化成功：已登录');
      } else {
        Logs.auth.info('步骤 2/4: 用户未登录，正在设置为 unauthenticated...');
        _state = const UserState(
          authStatus: AuthStatus.unauthenticated,
          isLoading: false,
        );

        Logs.auth.info('步骤 2/4 完成: 状态已设置为 unauthenticated');
        Logs.auth.info('✅ 认证状态初始化成功：未登录');
      }

      Logs.auth.info('步骤 4/4: 正在调用 notifyListeners()...');
      notifyListeners();
      Logs.auth.info('步骤 4/4 完成: notifyListeners() 已调用');
      Logs.auth.info('========================================');
      Logs.auth.info('========== 认证状态初始化完成 ==========');
      Logs.auth.info('========================================');
    } catch (e, stackTrace) {
      Logs.auth.info('❌❌❌ 认证状态初始化失败 ❌❌❌');
      Logs.auth.info('错误类型: ${e.runtimeType}');
      Logs.auth.info('错误信息: $e');
      Logs.auth.info('堆栈跟踪:');
      Logs.auth.info('$stackTrace');
      
      _state = const UserState(
        authStatus: AuthStatus.unauthenticated,
        isLoading: false,
      );
      
      Logs.auth.info('正在调用 notifyListeners()...');
      notifyListeners();
      Logs.auth.info('========================================');
      Logs.auth.info('========== 认证状态初始化完成（异常路径） ==========');
      Logs.auth.info('========================================');
    }
  }

  /// 登录成功，保存认证状态
  ///
  /// 注意：Token 仅保存到 SecureStorage 中，不保存到 Provider 状态
  Future<void> setAuthenticated({
    required String userId,
    required String accessToken,
    required String refreshToken,
    required int accessTokenExpiresIn,
    required int refreshTokenExpiresIn,
    required String phoneNumber,
    int pendingBindingCount = 0,
  }) async {
    Logs.auth.info('开始设置认证状态，用户ID: $userId');

    try {
      // 如果 refreshTokenExpiresIn 为 0（CloudBase Auth v2 不返回此字段），使用默认值
      final effectiveRefreshTokenExpiresIn = refreshTokenExpiresIn > 0
          ? refreshTokenExpiresIn
          : AuthConfig.refreshTokenExpiresIn;

      Logs.auth.info('RefreshToken 有效期: ${refreshTokenExpiresIn > 0 ? "从API获取" : "使用默认值"} = $effectiveRefreshTokenExpiresIn秒 (${effectiveRefreshTokenExpiresIn ~/ 86400}天)');

      // 保存到安全存储（Token 仅存储在这里）
      await SecureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresIn: accessTokenExpiresIn,
        refreshTokenExpiresIn: effectiveRefreshTokenExpiresIn,
        phoneNumber: phoneNumber,
        userId: userId,
      );

      // 更新认证状态（不包含 Token）
      _state = _state.copyWith(
        authStatus: AuthStatus.authenticated,
        userId: userId,
        phoneNumber: phoneNumber,
        isLoading: false,
        errorMessage: null,
        pendingBindingCount: pendingBindingCount,
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

  /// 登出，清除所有认证状态
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

      // 重置认证状态
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
      // 从 SecureStorage 读取（而不是从状态中读取）
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
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
    Logs.auth.info('AuthStateManager 被销毁');
    super.dispose();
  }
}
