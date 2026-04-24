import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_state_manager.dart';
import '../models/user_state.dart';
import '../utils/logger.dart';
import 'app_routes.dart';

/// 路由守卫和重定向逻辑
///
/// 职责：
/// - 检查用户认证状态
/// - 根据登录状态决定重定向目标
/// - 开发页面豁免认证
///
/// 注意：已删除角色选择机制，所有登录后用户都进入统一主页

class RouteGuards {
  /// 路由守卫核心逻辑
  ///
  /// 返回值说明：
  /// - `null`: 不重定向，停留在当前页面
  /// - `String`: 重定向到指定路径
  static Future<String?> redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    Logs.ui.info('🧭 [ROUTER] redirect 被调用, location=${state.matchedLocation}');

    // 确保 context 已挂载
    if (!context.mounted) return null;

    // 通过 ProviderScope.containerOf 获取 container
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authStateProvider);
    final authStatus = authState.authStatus;
    final isLoggedIn = authState.isLoggedIn;

    Logs.ui.info('🧭 [ROUTER] authStatus=$authStatus, isLoggedIn=$isLoggedIn');

    // 如果状态还在初始化中，停留在启动页
    if (authStatus == AuthStatus.unknown || authStatus == AuthStatus.loading) {
      Logs.ui.info('🧭 [ROUTER] 状态初始化中，停留在启动页');
      if (state.matchedLocation != AppRoutes.splash) {
        Logs.ui.info('🧭 [ROUTER] 重定向到启动页: ${AppRoutes.splash}');
        return AppRoutes.splash;
      }
      Logs.ui.info('🧭 [ROUTER] 返回 null (停留在启动页)');
      return null;
    }

    final isOnAuthPage = state.matchedLocation == AppRoutes.auth;
    final isOnSplashPage = state.matchedLocation == AppRoutes.splash;
    final isOnDevPage = state.matchedLocation.startsWith('/dev/');

    // 开发测试页面不需要登录，直接放行
    if (isOnDevPage) {
      Logs.ui.info('🧭 [ROUTER] 开发测试页面，不需要认证');
      return null;
    }

    Logs.ui.info('🧭 [ROUTER] isOnAuthPage=$isOnAuthPage, isOnSplashPage=$isOnSplashPage');

    // 如果未登录，重定向到认证页面
    if (!isLoggedIn) {
      if (!isOnAuthPage) {
        Logs.ui.info('🧭 [ROUTER] 未登录且不在认证页，重定向到: ${AppRoutes.auth}');
        return AppRoutes.auth;
      }
      Logs.ui.info('🧭 [ROUTER] 未登录但已在认证页，不需要重定向');
      return null;
    }

    // 如果已登录且在认证页面或启动页，重定向到统一主页
    if (isOnAuthPage || isOnSplashPage) {
      Logs.ui.info('🧭 [ROUTER] 已登录且在认证页/启动页，重定向到统一主页: ${AppRoutes.unifiedHome}');
      return AppRoutes.unifiedHome;
    }

    // 不需要重定向
    Logs.ui.info('🧭 [ROUTER] 不需要重定向，返回 null');
    return null;
  }
}
