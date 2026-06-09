import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_page.dart';
import '../features/app_shell/unified_home_page.dart';
import '../features/settings/settings_page.dart';
import '../features/settings/profile_page.dart';
import '../features/settings/user_agreement_page.dart';
import '../features/settings/privacy_policy_page.dart';
import '../features/app_shell/splash_screen.dart';
import 'app_routes.dart';
import 'route_guards.dart';

/// 应用路由配置
class AppRouter {
  static GoRouter? _router;

  /// 重置路由单例（用于测试）
  static void resetRouter() {
    _router = null;
  }

  static GoRouter getRouter() {
    // 如果已经初始化，直接返回（避免重复初始化）
    if (_router != null) {
      return _router!;
    }

    _router = GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      redirect: RouteGuards.redirect,
      routes: [
        // 启动页
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // 认证页面
        GoRoute(
          path: AppRoutes.auth,
          name: 'auth',
          builder: (context, state) => const AuthPage(),
        ),

        // 统一主页（所有用户登录后进入此页面）
        GoRoute(
          path: AppRoutes.unifiedHome,
          name: 'unified-home',
          builder: (context, state) {
            // userId 从 authStateProvider 获取，不再通过构造参数传递
            return const UnifiedHomePage(userId: '');
          },
        ),

        // 设置页面
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),

        // 个人信息编辑页
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),

        // 用户协议
        GoRoute(
          path: AppRoutes.userAgreement,
          name: 'user-agreement',
          builder: (context, state) => const UserAgreementPage(),
        ),

        // 隐私政策
        GoRoute(
          path: AppRoutes.privacyPolicy,
          name: 'privacy-policy',
          builder: (context, state) => const PrivacyPolicyPage(),
        ),
      ],
    );

    return _router!;
  }
}

/// 路由扩展方法
extension RouterExtension on BuildContext {
  /// 跳转到认证页面
  void goToAuth() {
    goNamed('auth');
  }

  /// 跳转到统一主页
  void goToUnifiedHome() {
    goNamed('unified-home');
  }

  /// 跳转到设置页面
  void goToSettings() {
    goNamed('settings');
  }

  /// 跳转到个人信息编辑页
  void goToProfile() {
    goNamed('profile');
  }

  /// 跳转到个人信息编辑页（push 模式，保留导航栈）
  void pushToProfile() {
    pushNamed('profile');
  }

  /// 跳转到用户协议页（push 模式）
  void pushToUserAgreement() {
    pushNamed('user-agreement');
  }

  /// 跳转到隐私政策页（push 模式）
  void pushToPrivacyPolicy() {
    pushNamed('privacy-policy');
  }

  /// 跳转到云函数调用测试页面
  void goToHelloApiTest() {
    goNamed('hello-api-test');
  }

  /// 返回上一页
  void goBack() {
    if (canPop()) {
      pop();
    }
  }

  /// 导航到指定路由（不留历史记录）
  void navigateTo(String routeName) {
    goNamed(routeName);
  }
}
