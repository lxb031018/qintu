import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================
/// 设置管理器
///
/// 管理用户设置
/// 通过 Riverpod 进行依赖注入，不使用单例模式
/// ============================================

class SettingsManager extends Notifier<SettingsState> {
  static const String _antiCollisionModeKey = 'double_tap_tab_switch';

  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  /// 异步加载设置
  Future<void> _loadSettings() async {
    final doubleTapTab = await loadAntiCollisionMode();
    state = state.copyWith(
      isAntiCollisionEnabled: doubleTapTab,
    );
  }

  /// 加载 Tab 双击设置
  static Future<bool> loadAntiCollisionMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_antiCollisionModeKey) ?? true;
  }

  /// 设置 Tab 双击模式
  Future<void> setAntiCollisionMode(bool value) async {
    if (state.isAntiCollisionEnabled == value) return;

    state = state.copyWith(isAntiCollisionEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_antiCollisionModeKey, value);
  }
}

/// 设置状态
class SettingsState {
  final bool isAntiCollisionEnabled;

  /// 全局文本缩放锁定（仅开发人员可改，用户不可见）
  /// true = 锁定为 1.0（字号不随系统字体大小变化），false = 跟随系统
  static const bool lockTextScale = true;

  const SettingsState({
    this.isAntiCollisionEnabled = true,
  });

  SettingsState copyWith({
    bool? isAntiCollisionEnabled,
  }) {
    return SettingsState(
      isAntiCollisionEnabled: isAntiCollisionEnabled ?? this.isAntiCollisionEnabled,
    );
  }
}

final settingsManagerProvider = NotifierProvider<SettingsManager, SettingsState>(
  SettingsManager.new,
);
