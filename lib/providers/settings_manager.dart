import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================
/// 设置管理器
///
/// 管理用户设置
/// 通过 Riverpod 进行依赖注入，不使用单例模式
/// ============================================

class SettingsManager extends Notifier<SettingsState> {
  static const String _doubleTapTabKey = 'double_tap_tab_switch';

  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  /// 异步加载设置
  Future<void> _loadSettings() async {
    final doubleTapTab = await loadDoubleTapTab();
    state = state.copyWith(
      doubleTapToSwitchTab: doubleTapTab,
    );
  }

  /// 加载 Tab 双击设置
  static Future<bool> loadDoubleTapTab() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_doubleTapTabKey) ?? true;
  }

  /// 设置 Tab 双击模式
  Future<void> setDoubleTapTab(bool value) async {
    if (state.doubleTapToSwitchTab == value) return;

    state = state.copyWith(doubleTapToSwitchTab: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_doubleTapTabKey, value);
  }
}

/// 设置状态
class SettingsState {
  final bool doubleTapToSwitchTab;

  const SettingsState({
    this.doubleTapToSwitchTab = true,
  });

  SettingsState copyWith({
    bool? doubleTapToSwitchTab,
  }) {
    return SettingsState(
      doubleTapToSwitchTab: doubleTapToSwitchTab ?? this.doubleTapToSwitchTab,
    );
  }
}

final settingsManagerProvider = NotifierProvider<SettingsManager, SettingsState>(
  SettingsManager.new,
);
