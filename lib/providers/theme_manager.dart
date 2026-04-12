import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

/// ============================================
/// 主题管理器
///
/// 管理应用主题的持久化和切换
/// 通过 Provider 进行依赖注入,不使用单例模式
/// ============================================

class ThemeManager extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  /// 当前主题模式
  ThemeMode _themeMode = ThemeMode.system;

  /// 获取当前主题模式
  ThemeMode get themeMode => _themeMode;

  /// 是否是深色主题
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// 是否是浅色主题
  bool get isLightMode => _themeMode == ThemeMode.light;

  /// 是否跟随系统
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// 初始化主题设置
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    // 如果用户没有设置过主题，默认跟随系统
    final themeIndex = prefs.getInt(_themeModeKey);
    return themeIndex != null
        ? ThemeMode.values[themeIndex]
        : ThemeMode.system;
  }

  /// 初始化
  Future<void> init() async {
    _themeMode = await loadThemeMode();
    notifyListeners();
  }

  /// 切换主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);

    notifyListeners();
  }

  /// 切换深色/浅色模式（快捷切换）
  Future<void> toggleDarkMode() async {
    if (_themeMode == ThemeMode.system) {
      // 如果当前是跟随系统，切换为深色
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      // 如果当前是深色，切换为浅色
      await setThemeMode(ThemeMode.light);
    } else {
      // 如果当前是浅色，切换为深色
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// 获取主题模式名称（用于显示）
  String getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppStrings.themeLight;
      case ThemeMode.dark:
        return AppStrings.themeDark;
      case ThemeMode.system:
        return AppStrings.themeSystem;
    }
  }

  /// 获取主题模式图标
  IconData getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
