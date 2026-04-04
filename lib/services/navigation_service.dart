import 'package:flutter/material.dart';
import '../pages/auth_page.dart';
import '../pages/role_selection_page.dart';
import '../pages/receiver_home_page.dart';
import '../pages/sender_home_page.dart';

/// 导航服务
///
/// 封装所有页面跳转逻辑，提供统一的导航 API
/// 便于维护和扩展

class NavigationService {
  /// 跳转到认证页面
  static Future<void> goToAuth(BuildContext context) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  /// 跳转到角色选择页面
  static Future<void> goToRoleSelection(
    BuildContext context, {
    required String userId,
    required String accessToken,
  }) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RoleSelectionPage(
          userId: userId,
          accessToken: accessToken,
        ),
      ),
    );
  }

  /// 跳转到接收者主页
  static Future<void> goToReceiverHome(
    BuildContext context, {
    required String userId,
    required String accessToken,
  }) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ReceiverHomePage(
          userId: userId,
          accessToken: accessToken,
        ),
      ),
    );
  }

  /// 跳转到发送者主页
  static Future<void> goToSenderHome(
    BuildContext context, {
    required String userId,
    required String accessToken,
  }) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SenderHomePage(
          userId: userId,
          accessToken: accessToken,
        ),
      ),
    );
  }

  /// 根据用户角色跳转到对应主页
  ///
  /// [context] BuildContext
  /// [userId] 用户 ID
  /// [accessToken] 访问令牌
  /// [userRole] 用户角色（receiver/sender），如果为 null 则跳转到角色选择页面
  static Future<void> goToHomeByRole(
    BuildContext context, {
    required String userId,
    required String accessToken,
    String? userRole,
  }) async {
    switch (userRole) {
      case 'receiver':
        await goToReceiverHome(
          context,
          userId: userId,
          accessToken: accessToken,
        );
        break;
      case 'sender':
        await goToSenderHome(
          context,
          userId: userId,
          accessToken: accessToken,
        );
        break;
      default:
        // 未选择角色：进入角色选择页面
        await goToRoleSelection(
          context,
          userId: userId,
          accessToken: accessToken,
        );
    }
  }
}
