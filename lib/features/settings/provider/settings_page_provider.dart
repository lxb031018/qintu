import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/providers/auth_state_manager.dart';
import 'package:qintu/utils/logger.dart';

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

/// 设置页面 Notifier
class SettingsPageNotifier extends Notifier<SettingsPageState> {
  @override
  SettingsPageState build() {
    return const SettingsPageState();
  }

  /// 执行退出登录（由 widget 层在确认对话框后调用）
  Future<void> logout() async {
    state = state.copyWith(isLoggingOut: true);

    try {
      Logs.auth.info('执行退出登录');
      await ref.read(authStateProvider.notifier).logout();
      Logs.auth.info('退出登录成功');
    } catch (e, stackTrace) {
      Logs.auth.error('退出登录失败: $e', stackTrace: stackTrace);
    } finally {
      state = state.copyWith(isLoggingOut: false);
    }
  }

  /// 处理退出登录确认
  ///
  /// 返回 true 表示用户确认退出，false 表示用户取消
  /// 注意：对话框逻辑应在 widget 层实现，此方法仅执行退出操作
  Future<bool> handleLogout() async {
    try {
      await ref.read(authStateProvider.notifier).logout();
      return true;
    } catch (e, stackTrace) {
      Logs.auth.error('退出登录失败: $e', stackTrace: stackTrace);
      return false;
    }
  }
}

/// Provider 导出
final settingsPageProvider = NotifierProvider<SettingsPageNotifier, SettingsPageState>(
  SettingsPageNotifier.new,
);