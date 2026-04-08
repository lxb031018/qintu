import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qintu/models/user_state.dart';
import 'package:qintu/router/app_router.dart';
import 'package:qintu/managers/auth_state_manager.dart';

/// 简化的路由守卫测试
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppRouter - 路由定义测试', () {
    late GoRouter router;

    setUp(() {
      // 每次测试前重置路由
      AppRouter.resetRouter();
    });

    test('路由应该正确定义', () {
      router = AppRouter.getRouter();

      // 验证路由数量
      expect(router.configuration.routes.length, greaterThan(4));

      // 验证路由路径
      final routePaths = router.configuration.routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toList();

      expect(routePaths, contains('/'));
      expect(routePaths, contains('/auth'));
      expect(routePaths, contains('/role-selection'));
      expect(routePaths, contains('/receiver-home'));
      expect(routePaths, contains('/sender-home'));
    });

    test('路由应该有名称', () {
      router = AppRouter.getRouter();

      final routeNames = router.configuration.routes
          .whereType<GoRoute>()
          .map((r) => r.name)
          .whereType<String>()
          .toList();

      expect(routeNames, contains('splash'));
      expect(routeNames, contains('auth'));
      expect(routeNames, contains('role-selection'));
      expect(routeNames, contains('receiver-home'));
      expect(routeNames, contains('sender-home'));
    });
  });

  group('UserState 模型测试', () {
    test('UserState.initial 应该创建初始状态', () {
      const state = UserState.initial();

      expect(state.authStatus, AuthStatus.unknown);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.isLoggedIn, isFalse);
    });

    test('UserState.authenticated 应该创建已认证状态', () {
      const state = UserState(
        authStatus: AuthStatus.authenticated,
        userId: 'test_user',
        phoneNumber: '+8613800138000',
        userRole: 'receiver',
        isLoading: false,
      );

      expect(state.authStatus, AuthStatus.authenticated);
      expect(state.userId, 'test_user');
      expect(state.phoneNumber, '+8613800138000');
      expect(state.userRole, 'receiver');
      expect(state.isLoading, isFalse);
      expect(state.isLoggedIn, isTrue);
    });

    test('UserState.unauthenticated 应该创建未认证状态', () {
      const state = UserState(
        authStatus: AuthStatus.unauthenticated,
        isLoading: false,
      );

      expect(state.authStatus, AuthStatus.unauthenticated);
      expect(state.isLoggedIn, isFalse);
    });

    test('UserState.copyWith 应该正确更新字段', () {
      const initialState = UserState.initial();

      final updatedState = initialState.copyWith(
        authStatus: AuthStatus.authenticated,
        userId: 'user_123',
        phoneNumber: '+8613800138000',
        userRole: 'receiver',
        isLoading: true,
      );

      expect(updatedState.authStatus, AuthStatus.authenticated);
      expect(updatedState.userId, 'user_123');
      expect(updatedState.phoneNumber, '+8613800138000');
      expect(updatedState.userRole, 'receiver');
      expect(updatedState.isLoading, isTrue);
    });

    test('UserState.copyWith 应该保持未修改的字段', () {
      const initialState = UserState(
        authStatus: AuthStatus.authenticated,
        userId: 'original_user',
        phoneNumber: '+8613800138000',
        userRole: 'receiver',
        isLoading: false,
        errorMessage: 'original error',
      );

      final updatedState = initialState.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      expect(updatedState.authStatus, AuthStatus.authenticated);
      expect(updatedState.userId, 'original_user');
      expect(updatedState.phoneNumber, '+8613800138000');
      expect(updatedState.userRole, 'receiver');
      expect(updatedState.isLoading, isTrue);
      expect(updatedState.errorMessage, isNull);
    });
  });

  group('AuthStateManager 基础测试', () {
    late AuthStateManager authStateManager;

    setUp(() {
      authStateManager = AuthStateManager();
    });

    tearDown(() {
      authStateManager.dispose();
    });

    test('初始状态应该是 unknown', () {
      expect(authStateManager.state.authStatus, AuthStatus.unknown);
      expect(authStateManager.state.isLoggedIn, isFalse);
    });

    test('setLoading 应该更新加载状态', () {
      authStateManager.setLoading(true);
      expect(authStateManager.state.isLoading, isTrue);

      authStateManager.setLoading(false);
      expect(authStateManager.state.isLoading, isFalse);
    });

    test('setError 和 clearError 应该正常工作', () {
      authStateManager.setError('测试错误');
      expect(authStateManager.state.errorMessage, '测试错误');

      authStateManager.clearError();
      expect(authStateManager.state.errorMessage, isNull);
    });
  });
}
