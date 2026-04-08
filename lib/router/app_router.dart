import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../managers/auth_state_manager.dart';
import '../models/user_state.dart';
import '../features/auth/auth_page.dart';
import '../features/role/role_selection_page.dart';
import '../features/receiver/receiver_home_page.dart';
import '../features/sender/sender_main_screen.dart';
import '../features/settings/settings_page.dart';
import '../features/common/splash_screen.dart';
import '../utils/logger.dart';
import '../constants/app_roles.dart';

/// 路由路径常量
class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String roleSelection = '/role-selection';
  static const String receiverHome = '/receiver-home';
  static const String senderHome = '/sender-home';
  static const String settings = '/settings';
}

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
      redirect: _redirect,
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
        
        // 角色选择页面
        GoRoute(
          path: AppRoutes.roleSelection,
          name: 'role-selection',
          builder: (context, state) {
            final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
            return RoleSelectionPage(
              userId: authStateManager.state.userId ?? '',
              phone: authStateManager.state.phoneNumber ?? '',
            );
          },
        ),

        // 接收者主页
        GoRoute(
          path: AppRoutes.receiverHome,
          name: 'receiver-home',
          builder: (context, state) {
            final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
            return ReceiverHomePage(
              userId: authStateManager.state.userId ?? '',
              phone: authStateManager.state.phoneNumber ?? '',
            );
          },
        ),

        // 发送者主页
        GoRoute(
          path: AppRoutes.senderHome,
          name: 'sender-home',
          builder: (context, state) {
            final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
            return SenderMainScreen(
              userId: authStateManager.state.userId ?? '',
            );
          },
        ),
        
        // 设置页面
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    );

    return _router!;
  }

  /// 路由守卫和重定向逻辑
  static Future<String?> _redirect(BuildContext context, GoRouterState state) async {
    Logs.ui.info('🧭 [ROUTER] redirect 被调用, location=${state.matchedLocation}');

    // 确保 Provider 已经初始化
    if (!context.mounted) return null;

    final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
    final authStatus = authStateManager.state.authStatus;
    final isLoggedIn = authStateManager.state.isLoggedIn;
    final userRole = authStateManager.state.userRole;

    Logs.ui.info('🧭 [ROUTER] authStatus=$authStatus, isLoggedIn=$isLoggedIn, userRole=$userRole');

    // 如果状态还在初始化中，停留在启动页
    if (authStatus == AuthStatus.unknown || authStatus == AuthStatus.loading) {
      Logs.ui.info('🧭 [ROUTER] 状态初始化中，停留在启动页');
      // 如果当前不在启动页，重定向到启动页
      if (state.matchedLocation != AppRoutes.splash) {
        Logs.ui.info('🧭 [ROUTER] 重定向到启动页: ${AppRoutes.splash}');
        return AppRoutes.splash;
      }
      Logs.ui.info('🧭 [ROUTER] 返回 null (停留在启动页)');
      return null; // 停留在当前页面（启动页）
    }

    final isOnAuthPage = state.matchedLocation == AppRoutes.auth;
    final isOnSplashPage = state.matchedLocation == AppRoutes.splash;

    Logs.ui.info('🧭 [ROUTER] isOnAuthPage=$isOnAuthPage, isOnSplashPage=$isOnSplashPage');

    // 如果未登录，重定向到认证页面（无论在哪个页面）
    if (!isLoggedIn) {
      if (!isOnAuthPage) {
        Logs.ui.info('🧭 [ROUTER] 未登录且不在认证页，重定向到: ${AppRoutes.auth}');
        return AppRoutes.auth;
      }
      Logs.ui.info('🧭 [ROUTER] 未登录但已在认证页，不需要重定向');
      return null;
    }

    // 如果已登录且在认证页面或启动页，重定向到对应的主页
    if (isOnAuthPage || isOnSplashPage) {
      Logs.ui.info('🧭 [ROUTER] 已登录且在认证页/启动页');

      // 如果角色未设置，重定向到角色选择页面
      if (userRole == null || userRole.isEmpty) {
        Logs.ui.info('🧭 [ROUTER] 角色未设置，重定向到角色选择页面: ${AppRoutes.roleSelection}');
        return AppRoutes.roleSelection;
      }

      String targetRoute;
      switch (userRole) {
        case AppRoles.receiver:
          targetRoute = AppRoutes.receiverHome;
          break;
        case AppRoles.sender:
          targetRoute = AppRoutes.senderHome;
          break;
        default:
          targetRoute = AppRoutes.roleSelection;
      }
      Logs.ui.info('🧭 [ROUTER] 根据角色重定向到: $targetRoute');
      return targetRoute;
    }

    // 不需要重定向
    Logs.ui.info('🧭 [ROUTER] 不需要重定向，返回 null');
    return null;
  }
}

/// 路由扩展方法
extension RouterExtension on BuildContext {
  /// 跳转到认证页面
  void goToAuth() {
    goNamed('auth');
  }

  /// 跳转到角色选择页面
  void goToRoleSelection() {
    goNamed('role-selection');
  }

  /// 跳转到接收者主页
  void goToReceiverHome() {
    goNamed('receiver-home');
  }

  /// 跳转到发送者主页
  void goToSenderHome() {
    goNamed('sender-home');
  }

  /// 跳转到设置页面
  void goToSettings() {
    goNamed('settings');
  }

  /// 返回上一页
  void goBack() {
    if (canPop()) {
      pop();
    }
  }

  /// 替换当前页面
  void replaceWith(String routeName) {
    goNamed(routeName);
  }
}
