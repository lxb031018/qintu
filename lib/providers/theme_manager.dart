import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qintu/constants/app_strings.dart';

/// ============================================
/// 主题管理器
///
/// 管理应用主题的持久化和切换
/// 通过 Riverpod 进行依赖注入,不使用单例模式
/// ============================================

class ThemeManager extends Notifier<ThemeMode> {
  static const String _themeModeKey = 'theme_mode';

  @override
  ThemeMode build() {
    _initTheme();
    return ThemeMode.system;
  }

  /// 异步初始化主题
  Future<void> _initTheme() async {
    state = await loadThemeMode();
  }

  /// 获取当前主题模式
  ThemeMode get themeMode => state;

  /// 是否是深色主题
  bool get isDarkMode => state == ThemeMode.dark;

  /// 是否是浅色主题
  bool get isLightMode => state == ThemeMode.light;

  /// 是否跟随系统
  bool get isSystemMode => state == ThemeMode.system;

  /// 初始化主题设置
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    // 如果用户没有设置过主题，默认跟随系统
    final themeIndex = prefs.getInt(_themeModeKey);
    return themeIndex != null
        ? ThemeMode.values[themeIndex]
        : ThemeMode.system;
  }

  /// 切换主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;

    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  /// 切换深色/浅色模式（快捷切换）
  Future<void> toggleDarkMode() async {
    if (state == ThemeMode.system) {
      // 如果当前是跟随系统，切换为深色
      await setThemeMode(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
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

final themeManagerProvider = NotifierProvider<ThemeManager, ThemeMode>(
  ThemeManager.new,
);
