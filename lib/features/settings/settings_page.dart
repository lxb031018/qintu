import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/secure_storage.dart';
import '../../managers/theme_manager.dart';
import 'widgets/role_switch_card.dart';
import 'widgets/theme_selector_card.dart';
import 'widgets/logout_card.dart';

/// ============================================
/// 设置页面
///
/// 包含主题切换、角色切换、退出登录等功能
/// 已重构：将 UI 组件拆分为独立的 widget
/// ============================================

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  String _currentRole = '';
  ThemeMode _currentThemeMode = ThemeMode.system;
  final ThemeManager _themeManager = ThemeManager.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _themeManager.addListener(_onThemeChanged);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  /// 主题变化回调
  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        _currentThemeMode = _themeManager.themeMode;
      });
    }
  }

  /// 监听应用生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 当应用恢复前台时，重新加载设置
    if (state == AppLifecycleState.resumed) {
      _loadSettings();
    }
  }

  /// 加载设置信息
  Future<void> _loadSettings() async {
    // 加载当前角色
    final role = await SecureStorage.getUserRole();

    // 通过 ThemeManager 加载主题设置（确保与主应用同步）
    final themeMode = await ThemeManager.loadThemeMode();

    if (mounted) {
      setState(() {
        _currentRole = role ?? '';
        _currentThemeMode = themeMode;
      });
    }
  }

  /// 设置刷新（当主题改变时触发）
  void _refreshSettings() {
    // 重新加载主题设置
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 角色切换卡片
          RoleSwitchCard(
            currentRole: _currentRole,
            onRoleChanged: _refreshSettings,
          ),

          const SizedBox(height: 16),

          // 主题设置卡片
          ThemeSelectorCard(
            currentThemeMode: _currentThemeMode,
            onThemeChanged: _refreshSettings,
          ),

          const SizedBox(height: 16),

          // 退出登录卡片
          const LogoutCard(),

          const SizedBox(height: 32),

          // 版本信息
          Center(
            child: Text(
              '${AppStrings.appName} v1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkLightTextColor
                    : AppColors.lightTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
