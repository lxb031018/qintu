import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qintu/constants/font_size_setting.dart';

/// ============================================
/// 设置管理器
///
/// 管理用户设置（字体大小等）
/// 通过 Riverpod 进行依赖注入，不使用单例模式
/// ============================================

class SettingsManager extends Notifier<SettingsState> {
  static const String _fontSizeKey = 'font_size_scale';
  static const String _doubleTapTabKey = 'double_tap_tab_switch';

  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  /// 异步加载设置
  Future<void> _loadSettings() async {
    final fontSizeScale = await loadFontSizeScale();
    final doubleTapTab = await loadDoubleTapTab();
    state = state.copyWith(
      fontSizeScale: fontSizeScale,
      doubleTapToSwitchTab: doubleTapTab,
    );
  }

  /// 加载字体大小设置
  static Future<double> loadFontSizeScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? FontSizeOption.standard.scale;
  }

  /// 加载 Tab 双击设置
  static Future<bool> loadDoubleTapTab() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_doubleTapTabKey) ?? true; // 默认开启双击
  }

  /// 设置 Tab 双击模式
  Future<void> setDoubleTapTab(bool value) async {
    if (state.doubleTapToSwitchTab == value) return;

    state = state.copyWith(doubleTapToSwitchTab: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_doubleTapTabKey, value);
  }

  /// 设置字体大小
  Future<void> setFontSizeScale(double scale) async {
    if (state.fontSizeScale == scale) return;

    state = state.copyWith(fontSizeScale: scale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, scale);
  }

  /// 获取字体大小选项名称（用于显示）
  String getFontSizeLabel(double scale) {
    final option = FontSizeOption.values.firstWhere(
      (option) => option.scale == scale,
      orElse: () => FontSizeOption.standard,
    );
    return option.label;
  }
}

/// 设置状态
class SettingsState {
  final double fontSizeScale;
  final bool doubleTapToSwitchTab;

  const SettingsState({
    this.fontSizeScale = 1.0, // FontSizeOption.standard.scale
    this.doubleTapToSwitchTab = true,
  });

  SettingsState copyWith({
    double? fontSizeScale,
    bool? doubleTapToSwitchTab,
  }) {
    return SettingsState(
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      doubleTapToSwitchTab: doubleTapToSwitchTab ?? this.doubleTapToSwitchTab,
    );
  }
}

final settingsManagerProvider = NotifierProvider<SettingsManager, SettingsState>(
  SettingsManager.new,
);
