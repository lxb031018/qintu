import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

/// 设置页面 Provider
class SettingsPageNotifier extends ChangeNotifier {
  /// 处理退出登录
  ///
  /// [context] 用于显示对话框
  /// 返回 true 表示用户确认退出，false 表示用户取消
  Future<bool> handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return false;
    }

    _state = _state.copyWith(isLoggingOut: true);
    notifyListeners();

    try {
      Logs.auth.info('执行退出登录');
      await context.read<AuthStateNotifier>().logout();
      Logs.auth.info('退出登录成功');
      return true;
    } catch (e, stackTrace) {
      Logs.auth.error('退出登录失败: $e', stackTrace: stackTrace);
      return false;
    } finally {
      _state = _state.copyWith(isLoggingOut: false);
      notifyListeners();
    }
  }

  SettingsPageState _state = const SettingsPageState();

  SettingsPageState get state => _state;
}

/// Provider 导出
final settingsPageProvider = ChangeNotifierProvider<SettingsPageNotifier>(
  create: (_) => SettingsPageNotifier(),
);
