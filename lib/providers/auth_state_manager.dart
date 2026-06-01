import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/models/auth/user_state.dart';
import 'package:qintu/features/auth/core/secure_storage.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/config/auth_config.dart';
import 'package:qintu/core/http/api_client.dart';
import 'package:qintu/features/settings/core/user_profile_api.dart';

/// 安全存储 Provider
///
/// 上层（AuthStateNotifier / AuthService）通过此 Provider 注入 storage。
/// 测试里用 `overrideWithValue(MockSecureStorage())` 即可注入 mock，
/// 避免触碰 `flutter_secure_storage` 原生插件。
final secureStorageProvider = Provider<ISecureStorage>((ref) {
  return FlutterSecureStorageImpl();
});

/// ============================================
/// 认证状态管理器
///
/// Notifier，负责：
/// - 初始化和检查登录状态
/// - 登录/登出操作
/// - Token 管理
/// ============================================

class AuthStateNotifier extends Notifier<UserState> {
  late final ISecureStorage _storage;

  @override
  UserState build() {
    _storage = ref.read(secureStorageProvider);
    return const UserState();
  }

  /// 初始化认证状态（首次访问时自动调用）
  Future<void> initialize() async {
    Logs.auth.info('[AuthStateNotifier] initialize 开始, 当前状态: ${state.authStatus}');
    Logs.auth.info('开始初始化认证状态');

    ApiClient.registerSessionRevokedCallback(_handleSessionRevoked);

    try {
      final isLoggedIn = await _storage.isLoggedIn();
      Logs.auth.info('[AuthStateNotifier] isLoggedIn=$isLoggedIn');

      if (isLoggedIn) {
        final loginInfo = await _storage.getLoginInfo();

        if (loginInfo != null) {
          Logs.auth.info('[AuthStateNotifier] 已登录用户: ${loginInfo.userId}');
        }

        // 获取用户头像和昵称
        String? avatarUrl;
        String? nickname;
        try {
          final profile = await UserProfileApi.getCurrentUser();
          avatarUrl = profile?.avatarUrl;
          nickname = profile?.nickname;
          Logs.auth.info('[AuthStateNotifier] 获取到头像: $avatarUrl, 昵称: $nickname');
        } catch (e) {
          Logs.auth.warning('[AuthStateNotifier] 获取用户资料失败: $e');
        }

        state = state.copyWith(
          authStatus: AuthStatus.authenticated,
          userId: loginInfo?.userId,
          phoneNumber: loginInfo?.phoneNumber,
          avatarUrl: avatarUrl,
          nickname: nickname,
          isLoading: false,
        );
        Logs.auth.info('[AuthStateNotifier] 设置为 authenticated, userId=${loginInfo?.userId}');

        // 更新最后登录时间（冷启动）
        try {
          await UserProfileApi.updateLastLogin();
        } catch (e) {
          Logs.auth.warning('[AuthStateNotifier] 更新最后登录时间失败: $e');
        }
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

  void _handleSessionRevoked() {
    Logs.auth.warning('🔐 会话已被废弃，强制登出');
    state = const UserState(
      authStatus: AuthStatus.unauthenticated,
      isLoading: false,
      errorMessage: '您的账号已在另一设备登录',
    );
  }

  /// 更新头像
  void updateAvatar(String? avatarUrl) {
    state = state.copyWith(avatarUrl: avatarUrl);
    Logs.auth.info('[AuthStateNotifier] 头像已更新: $avatarUrl');
  }

  /// 更新昵称
  void updateNickname(String? nickname) {
    state = state.copyWith(nickname: nickname);
    Logs.auth.info('[AuthStateNotifier] 昵称已更新: $nickname');
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

      await _storage.saveTokens(
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

      await _storage.clearTokens();

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
      final refreshToken = await _storage.getRefreshToken();
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
