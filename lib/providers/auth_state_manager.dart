import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/models/auth/user_state.dart';
import 'package:qintu/features/auth/api/secure_storage.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/config/auth_config.dart';

/// ============================================
/// 认证状态管理器
///
/// Riverpod Notifier，负责：
/// - 初始化和检查登录状态
/// - 登录/登出操作
/// - Token 管理
/// ============================================

class AuthStateNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    return const UserState();
  }

  /// 初始化认证状态（应用启动时调用）
  Future<void> initialize() async {
    Logs.auth.info('[AuthStateNotifier] initialize 开始, 当前状态: ${state.authStatus}');
    Logs.auth.info('开始初始化认证状态');

    try {
      final isLoggedIn = await SecureStorage.isLoggedIn();
      Logs.auth.info('[AuthStateNotifier] isLoggedIn=$isLoggedIn');

      if (isLoggedIn) {
        final loginInfo = await SecureStorage.getLoginInfo();

        if (loginInfo != null) {
          Logs.auth.info('[AuthStateNotifier] 已登录用户: ${loginInfo.userId}');
        }

        state = state.copyWith(
          authStatus: AuthStatus.authenticated,
          userId: loginInfo?.userId,
          phoneNumber: loginInfo?.phoneNumber,
          isLoading: false,
        );
        Logs.auth.info('[AuthStateNotifier] 设置为 authenticated, userId=${loginInfo?.userId}');
      } else {
        Logs.auth.info('[AuthStateNotifier] 未登录，设置 authStatus=unauthenticated');
        state = const UserState(
          authStatus: AuthStatus.unauthenticated,
          isLoading: false,
        );
      }
    } catch (e, stackTrace) {
      Logs.auth.error('[AuthStateNotifier] 认证状态初始化失败:', stackTrace: stackTrace);
      state = const UserState(
        authStatus: AuthStatus.unauthenticated,
        isLoading: false,
      );
    }
  }

  /// 登录成功，保存认证状态
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
      final effectiveRefreshTokenExpiresIn = refreshTokenExpiresIn > 0
          ? refreshTokenExpiresIn
          : AuthConfig.refreshTokenExpiresIn;

      Logs.auth.info('RefreshToken 有效期: ${refreshTokenExpiresIn > 0 ? "从API获取" : "使用默认值"} = $effectiveRefreshTokenExpiresIn秒 (${effectiveRefreshTokenExpiresIn ~/ 86400}天)');

      await SecureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresIn: accessTokenExpiresIn,
        refreshTokenExpiresIn: effectiveRefreshTokenExpiresIn,
        phoneNumber: phoneNumber,
        userId: userId,
      );

      state = state.copyWith(
        authStatus: AuthStatus.authenticated,
        userId: userId,
        phoneNumber: phoneNumber,
        isLoading: false,
        errorMessage: null,
        pendingBindingCount: pendingBindingCount,
      );

      Logs.auth.info('✅ 认证状态设置成功');
    } catch (e, stackTrace) {
      Logs.auth.info('❌ 设置认证状态失败: $e\n$stackTrace');
      state = state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: '登录失败: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// 登出，清除所有认证状态
  Future<void> logout() async {
    Logs.auth.info('开始退出登录...');

    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      await SecureStorage.clearTokens();

      state = const UserState(
        authStatus: AuthStatus.unauthenticated,
        isLoading: false,
      );

      Logs.auth.info('✅ 退出登录成功');
    } catch (e, stackTrace) {
      Logs.auth.info('❌ 退出登录失败: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '退出登录失败: ${e.toString()}',
      );
    }
  }

  /// 设置加载状态
  void setLoading(bool loading) {
    if (state.isLoading != loading) {
      state = state.copyWith(isLoading: loading);
    }
  }

  /// 设置错误消息
  void setError(String? error) {
    if (state.errorMessage != error) {
      state = state.copyWith(errorMessage: error);
    }
  }

  /// 清除错误消息
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// 刷新 Token
  Future<void> refreshTokens() async {
    Logs.auth.info('开始刷新 Token...');

    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('没有可用的 Refresh Token');
      }

      Logs.auth.info('⚠️ Token 刷新功能尚未实现');
    } catch (e, stackTrace) {
      Logs.auth.info('❌ Token 刷新失败: $e\n$stackTrace');
      await logout();
      rethrow;
    }
  }
}

final authStateProvider = NotifierProvider<AuthStateNotifier, UserState>(
  AuthStateNotifier.new,
);
