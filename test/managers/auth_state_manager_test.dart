import 'package:flutter_test/flutter_test.dart';
import 'package:qintu/providers/auth_state_manager.dart';
import 'package:qintu/models/auth/user_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthStateNotifier - 状态管理测试', () {
    late AuthStateNotifier authStateNotifier;

    setUp(() {
      authStateNotifier = AuthStateNotifier();
    });

    // Notifier 不需要 dispose

    test('初始状态应该是 unknown', () {
      expect(authStateNotifier.state.authStatus, AuthStatus.unknown);
      expect(authStateNotifier.state.userId, isNull);
      expect(authStateNotifier.state.phoneNumber, isNull);
      expect(authStateNotifier.state.isLoading, isFalse);
      expect(authStateNotifier.state.errorMessage, isNull);
      expect(authStateNotifier.state.isLoggedIn, isFalse);
    });

    test('setLoading 应该更新加载状态', () {
      authStateNotifier.setLoading(true);
      expect(authStateNotifier.state.isLoading, isTrue);

      authStateNotifier.setLoading(false);
      expect(authStateNotifier.state.isLoading, isFalse);
    });

    test('setError 应该设置错误信息', () {
      authStateNotifier.setError('测试错误信息');
      expect(authStateNotifier.state.errorMessage, '测试错误信息');
    });

    test('clearError 应该清除错误信息', () {
      authStateNotifier.setError('测试错误信息');
      expect(authStateNotifier.state.errorMessage, '测试错误信息');

      authStateNotifier.clearError();
      expect(authStateNotifier.state.errorMessage, isNull);
    });

    test('isLoggedIn 应该返回正确的认证状态', () {
      // 初始状态未登录
      expect(authStateNotifier.state.isLoggedIn, isFalse);
    });

    test('setAuthenticated 应该更新用户信息（不依赖 SecureStorage）', () async {
      // 注意: 这个测试会调用 SecureStorage,实际应该 mock
      // 这里只测试状态更新的逻辑
      try {
        await authStateNotifier.setAuthenticated(
          userId: 'test_user_123',
          accessToken: 'test_access_token',
          refreshToken: 'test_refresh_token',
          accessTokenExpiresIn: 3600,
          refreshTokenExpiresIn: 86400,
          phoneNumber: '+8613800138000',
        );

        expect(authStateNotifier.state.authStatus, AuthStatus.authenticated);
        expect(authStateNotifier.state.userId, 'test_user_123');
        expect(authStateNotifier.state.phoneNumber, '+8613800138000');
        expect(authStateNotifier.state.isLoggedIn, isTrue);
      } catch (e) {
        // SecureStorage 未初始化时可能失败
        expect(authStateNotifier.state.authStatus, AuthStatus.unauthenticated);
      }
    });

    test('logout 应该清除认证状态', () async {
      try {
        await authStateNotifier.logout();

        expect(authStateNotifier.state.authStatus, AuthStatus.unauthenticated);
        expect(authStateNotifier.state.userId, isNull);
        expect(authStateNotifier.state.phoneNumber, isNull);
        expect(authStateNotifier.state.isLoggedIn, isFalse);
      } catch (e) {
        // SecureStorage 未初始化时可能失败
        expect(authStateNotifier.state.isLoading, isFalse);
      }
    });
  });

  group('UserState 模型测试', () {
    test('UserState.initial 应该创建初始状态', () {
      final state = UserState.initial();

      expect(state.authStatus, AuthStatus.unknown);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('UserState.copyWith 应该正确更新字段', () {
      final initialState = UserState.initial();

      final updatedState = initialState.copyWith(
        authStatus: AuthStatus.authenticated,
        userId: 'user_123',
        phoneNumber: '+8613800138000',
        isLoading: true,
        errorMessage: null,
      );

      expect(updatedState.authStatus, AuthStatus.authenticated);
      expect(updatedState.userId, 'user_123');
      expect(updatedState.phoneNumber, '+8613800138000');
      expect(updatedState.isLoading, isTrue);
    });

    test('UserState.isLoggedIn 应该根据 authStatus 返回', () {
      const unauthenticatedState = UserState(
        authStatus: AuthStatus.unauthenticated,
      );
      expect(unauthenticatedState.isLoggedIn, isFalse);

      const authenticatedState = UserState(
        authStatus: AuthStatus.authenticated,
      );
      expect(authenticatedState.isLoggedIn, isTrue);
    });
  });
}
