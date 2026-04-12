import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/font_size_setting.dart';

/// ============================================
/// 设置管理器
///
/// 管理用户设置（字体大小等）
/// 通过 Provider 进行依赖注入，不使用单例模式
/// ============================================

class SettingsManager extends ChangeNotifier {
  static const String _fontSizeKey = 'font_size_scale';
  static const String _doubleTapTabKey = 'double_tap_tab_switch';

  /// 当前字体大小乘数
  double _fontSizeScale = FontSizeOption.standard.scale;

  /// Tab 切换模式（默认双击）
  bool _doubleTapToSwitchTab = true;

  /// 获取当前字体大小乘数
  double get fontSizeScale => _fontSizeScale;

  /// 是否需要双击切换 Tab（默认 true）
  bool get doubleTapToSwitchTab => _doubleTapToSwitchTab;

  /// 初始化设置
  Future<void> init() async {
    _fontSizeScale = await loadFontSizeScale();
    _doubleTapToSwitchTab = await loadDoubleTapTab();
    notifyListeners();
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
    if (_doubleTapToSwitchTab == value) return;

    _doubleTapToSwitchTab = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_doubleTapTabKey, value);

    notifyListeners();
  }

  /// 设置字体大小
  Future<void> setFontSizeScale(double scale) async {
    if (_fontSizeScale == scale) return;

    _fontSizeScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, scale);

    notifyListeners();
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
