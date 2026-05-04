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
  static const String _drivingStrategyKey = 'driving_strategy';

  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  /// 异步加载设置
  Future<void> _loadSettings() async {
    final doubleTapTab = await loadAntiCollisionMode();
    final strategy = await loadDrivingStrategy();
    state = state.copyWith(
      isAntiCollisionEnabled: doubleTapTab,
      drivingStrategy: strategy,
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

  /// 加载驾车策略
  static Future<int> loadDrivingStrategy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_drivingStrategyKey) ?? 10;
  }

  /// 设置驾车策略
  Future<void> setDrivingStrategy(int value) async {
    if (state.drivingStrategy == value) return;

    state = state.copyWith(drivingStrategy: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_drivingStrategyKey, value);
  }
}

/// 设置状态
class SettingsState {
  final bool isAntiCollisionEnabled;
  final int drivingStrategy;

  /// 全局文本缩放锁定（仅开发人员可改，用户不可见）
  /// true = 锁定为 1.0（字号不随系统字体大小变化），false = 跟随系统
  static const bool lockTextScale = true;

  const SettingsState({
    this.isAntiCollisionEnabled = true,
    this.drivingStrategy = 10,
  });

  SettingsState copyWith({
    bool? isAntiCollisionEnabled,
    int? drivingStrategy,
  }) {
    return SettingsState(
      isAntiCollisionEnabled: isAntiCollisionEnabled ?? this.isAntiCollisionEnabled,
      drivingStrategy: drivingStrategy ?? this.drivingStrategy,
    );
  }
}

final settingsManagerProvider = NotifierProvider<SettingsManager, SettingsState>(
  SettingsManager.new,
);
