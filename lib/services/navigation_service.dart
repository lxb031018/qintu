import 'package:flutter/material.dart';
import '../constants/app_roles.dart';
import '../features/auth/auth_page.dart';
import '../features/role/role_selection_page.dart';
import '../features/receiver/receiver_home_page.dart';
import '../features/sender/sender_main_screen.dart';
import '../models/user_credentials.dart';
import '../utils/logger.dart';

/// 导航服务
///
/// 封装所有页面跳转逻辑，提供统一的导航 API
/// 便于维护和扩展

class NavigationService {
  /// 跳转到认证页面
  static Future<void> goToAuth(BuildContext context) async {
    Logs.ui.info('跳转到认证页面');
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  /// 跳转到角色选择页面
  static Future<void> goToRoleSelection(
    BuildContext context,
    UserCredentials credentials,
  ) async {
    Logs.ui.info('跳转到角色选择页面');
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => RoleSelectionPage(
          userId: credentials.userId,
          phone: credentials.phone,
          accessToken: credentials.accessToken,
        ),
      ),
      (route) => false, // 清除所有旧路由
    );
  }

  /// 跳转到接收者主页
  static Future<void> goToReceiverHome(
    BuildContext context,
    UserCredentials credentials,
  ) async {
    Logs.ui.info('跳转到接收者主页');
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => ReceiverHomePage(
          userId: credentials.userId,
          phone: credentials.phone,
          accessToken: credentials.accessToken,
        ),
      ),
      (route) => false, // 清除所有旧路由
    );
  }

  /// 跳转到发送者主页（三Tab架构）
  static Future<void> goToSenderHome(
    BuildContext context,
    UserCredentials credentials,
  ) async {
    Logs.ui.info('跳转到发送者主页');
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => SenderMainScreen(
          userId: credentials.userId,
          accessToken: credentials.accessToken,
        ),
      ),
      (route) => false, // 清除所有旧路由
    );
  }

  /// 根据用户角色跳转到对应主页
  ///
  /// [context] BuildContext
  /// [credentials] 用户凭据
  /// [userRole] 用户角色（receiver/sender），如果为 null 则跳转到角色选择页面
  static Future<void> goToHomeByRole(
    BuildContext context,
    UserCredentials credentials, {
    String? userRole,
  }) async {
    Logs.ui.info('根据角色跳转到主页: $userRole');

    switch (userRole) {
      case AppRoles.receiver:
        await goToReceiverHome(context, credentials);
        break;
      case AppRoles.sender:
        await goToSenderHome(context, credentials);
        break;
      default:
        // 未选择角色：进入角色选择页面
        await goToRoleSelection(context, credentials);
    }
  }

  /// 清除页面栈并跳转到指定页面
  ///
  /// 用于退出登录等需要完全清除页面历史的场景
  static Future<void> clearAndGo(
    BuildContext context,
    Widget page,
  ) async {
    Logs.ui.info('清除页面栈并跳转');
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (route) => false, // 清除所有旧路由
    );
  }

  /// 清除页面栈并跳转到登录页
  static Future<void> clearAndGoToAuth(BuildContext context) async {
    Logs.ui.info('清除页面栈并跳转到登录页');
    await clearAndGo(context, const AuthPage());
  }
}
