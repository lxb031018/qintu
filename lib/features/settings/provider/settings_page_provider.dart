import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/providers/auth_state_manager.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/widgets/common/logout_dialog.dart';

/// ============================================
/// 设置页面 Provider 层
///
/// 管理设置页面的 UI 状态（对话框确认等）
/// ============================================

/// 设置页面状态
class SettingsPageState {
  final bool isLoggingOut;

  const SettingsPageState({
    this.isLoggingOut = false,
  });

  SettingsPageState copyWith({
    bool? isLoggingOut,
  }) {
    return SettingsPageState(
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }
}

/// 设置页面 Provider
class SettingsPageNotifier extends Notifier<SettingsPageState> {
  @override
  SettingsPageState build() {
    return const SettingsPageState();
  }

  /// 处理退出登录
  ///
  /// [context] 用于显示对话框
  /// 返回 true 表示用户确认退出，false 表示用户取消
  Future<bool> handleLogout(BuildContext context) async {
    final confirmed = await LogoutDialog.show(context);

    if (!confirmed) {
      return false;
    }

    state = state.copyWith(isLoggingOut: true);

    try {
      Logs.auth.info('执行退出登录');
      await ref.read(authStateProvider.notifier).logout();
      Logs.auth.info('退出登录成功');
      return true;
    } catch (e, stackTrace) {
      Logs.auth.error('退出登录失败: $e', stackTrace: stackTrace);
      return false;
    } finally {
      state = state.copyWith(isLoggingOut: false);
    }
  }
}

/// Provider 导出
final settingsPageProvider = NotifierProvider<SettingsPageNotifier, SettingsPageState>(
  SettingsPageNotifier.new,
);
