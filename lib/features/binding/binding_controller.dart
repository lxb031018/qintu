import 'package:flutter/material.dart';
import '../../providers/binding_provider.dart';
import '../../constants/app_strings.dart';
import '../../utils/app_snackbar.dart';
import 'widgets/phone_binding_dialog.dart';
import 'requests/notification_center_page.dart';

/// ============================================
/// 绑定页面业务逻辑控制器
///
/// 职责：
/// - 处理绑定/解绑相关的业务逻辑
/// - 显示操作反馈（SnackBar、对话框）
/// - 封装复杂交互流程
///
/// 设计原则：
/// - 不直接操作 UI（由 binding_page.dart 负责）
/// - 不包含 HTTP 细节（由 ApiClient 负责）
/// - 可被单元测试独立 mock
/// ============================================

class BindingController {
  final BuildContext context;
  final BindingProvider provider;

  BindingController({
    required this.context,
    required this.provider,
  });

  /// 刷新数据（绑定列表 + 通知）
  Future<void> refreshData() async {
    await provider.loadBindings();
    await provider.loadPendingRequests();
    await provider.loadSentRequests();
  }

  /// 确认解除绑定（带二次确认对话框）
  Future<bool> confirmRevoke(int bindingId) async {
    final confirmed = await _showRevokeDialog();
    if (confirmed != true) return false;

    if (!context.mounted) return false;

    final success = await provider.revokeBinding(bindingId);

    if (!context.mounted) return false;

    if (success) {
      AppSnackbar.showPrimary(context, AppStrings.revokeBindingSuccess);
    } else {
      AppSnackbar.showErrorTheme(context, provider.error ?? AppStrings.revokeBindingFailed);
    }

    return success;
  }

  /// 显示手机号绑定对话框
  Future<void> showPhoneBindingDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => PhoneBindingDialog(parentContext: context),
    );
  }

  /// 显示通知中心
  Future<void> showNotificationCenter() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationCenterPage(),
      ),
    );
  }

  /// 显示"我发出的请求"页面（已废弃，使用通知中心代替）
  @Deprecated('使用 showNotificationCenter 代替')
  Future<void> showSentRequests() async {
    await showNotificationCenter();
  }

  // ==========================================
  // 私有方法
  // ==========================================

  /// 显示解除绑定确认对话框
  Future<bool?> _showRevokeDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.revokeBinding),
          content: const Text(AppStrings.revokeBindingConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.revokeBinding),
            ),
          ],
        );
      },
    );
  }
}
