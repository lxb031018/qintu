import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qintu/providers/auth_state_manager.dart';
import 'package:qintu/models/auth/user_state.dart';
import 'mock_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthStateNotifier - 状态管理测试', () {
    late ProviderContainer container;
    late MockSecureStorage mockStorage;
    late AuthStateNotifier notifier;
    late UserState Function() readState;

    setUp(() {
      mockStorage = MockSecureStorage();
      container = ProviderContainer(overrides: [
        secureStorageProvider.overrideWithValue(mockStorage),
      ]);
      notifier = container.read(authStateProvider.notifier);
      readState = () => container.read(authStateProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('初始状态应该是 unknown', () {
      expect(readState().authStatus, AuthStatus.unknown);
      expect(readState().userId, isNull);
      expect(readState().phoneNumber, isNull);
      expect(readState().isLoading, isFalse);
      expect(readState().errorMessage, isNull);
      expect(readState().isLoggedIn, isFalse);
    });

    test('setLoading 应该更新加载状态', () {
      notifier.setLoading(true);
      expect(readState().isLoading, isTrue);

      notifier.setLoading(false);
      expect(readState().isLoading, isFalse);
    });

    test('setError 应该设置错误信息', () {
      notifier.setError('测试错误信息');
      expect(readState().errorMessage, '测试错误信息');
    });

    test('clearError 应该清除错误信息', () {
      notifier.setError('测试错误信息');
      expect(readState().errorMessage, '测试错误信息');

      notifier.clearError();
      expect(readState().errorMessage, isNull);
    });

    test('isLoggedIn 应该返回正确的认证状态', () {
      // 初始状态未登录
      expect(readState().isLoggedIn, isFalse);
    });

    test('setAuthenticated 应该更新用户信息（用 mock storage）', () async {
      // mock storage 默认 saveTokens 成功（不抛），所以能走到 state 更新
      await notifier.setAuthenticated(
        userId: 'test_user_123',
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        accessTokenExpiresIn: 3600,
        refreshTokenExpiresIn: 86400,
        phoneNumber: '+8613800138000',
      );

      expect(readState().authStatus, AuthStatus.authenticated);
      expect(readState().userId, 'test_user_123');
      expect(readState().phoneNumber, '+8613800138000');
      expect(readState().isLoggedIn, isTrue);

      // 验证 mock 收到正确参数
      expect(mockStorage.saveTokensCallCount, 1);
      expect(mockStorage.lastAccessToken, 'test_access_token');
      expect(mockStorage.lastRefreshToken, 'test_refresh_token');
      expect(mockStorage.lastUserId, 'test_user_123');
      expect(mockStorage.lastPhoneNumber, '+8613800138000');
    });

    test('logout 应该清除认证状态（用 mock storage）', () async {
      // 先设置认证
      await notifier.setAuthenticated(
        userId: 'test_user',
        accessToken: 'a',
        refreshToken: 'r',
        accessTokenExpiresIn: 3600,
        refreshTokenExpiresIn: 86400,
        phoneNumber: '+8613800138000',
      );
      expect(readState().authStatus, AuthStatus.authenticated);

      // 退出
      await notifier.logout();
      expect(readState().authStatus, AuthStatus.unauthenticated);
      expect(readState().userId, isNull);
      expect(readState().phoneNumber, isNull);
      expect(readState().isLoggedIn, isFalse);

      // 验证 clearTokens 被调用
      expect(mockStorage.clearTokensCallCount, 1);
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
