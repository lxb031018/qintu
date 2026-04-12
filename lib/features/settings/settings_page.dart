import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/theme_manager.dart';
import '../../theme/app_text_styles.dart';
import 'widgets/theme_selector_card.dart';
import 'widgets/logout_card.dart';
import 'widgets/font_size_selector_card.dart';
import 'widgets/tab_switch_mode_card.dart';

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
  ThemeMode _currentThemeMode = ThemeMode.system;
  late ThemeManager _themeManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在 didChangeDependencies 中获取 Provider
    _themeManager = Provider.of<ThemeManager>(context, listen: false);
    _themeManager.addListener(_onThemeChanged);
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
    // 通过 ThemeManager 加载主题设置（确保与主应用同步）
    final themeMode = await ThemeManager.loadThemeMode();

    if (mounted) {
      setState(() {
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 字体大小设置卡片
          const FontSizeSelectorCard(),

          const SizedBox(height: 16),

          // Tab 切换模式卡片
          const TabSwitchModeCard(),

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
              style: AppTextStyles.caption.copyWith(
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
