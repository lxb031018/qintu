import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../managers/theme_manager.dart';
import '../../../constants/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'settings_section_card.dart';

/// ============================================
/// 主题选择卡片组件
///
/// 提供浅色/深色/跟随系统三种主题选项
/// 通过 ThemeManager 统一管理主题状态
/// ============================================

class ThemeSelectorCard extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final VoidCallback? onThemeChanged;

  const ThemeSelectorCard({
    super.key,
    required this.currentThemeMode,
    this.onThemeChanged,
  });

  @override
  State<ThemeSelectorCard> createState() => _ThemeSelectorCardState();
}

class _ThemeSelectorCardState extends State<ThemeSelectorCard> {
  late ThemeMode _selectedThemeMode;
  late ThemeManager _themeManager;

  @override
  void initState() {
    super.initState();
    _selectedThemeMode = widget.currentThemeMode;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 通过 Provider 获取共享的 ThemeManager 实例
    _themeManager = Provider.of<ThemeManager>(context, listen: false);
  }

  @override
  void didUpdateWidget(ThemeSelectorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当父组件传入的值变化时，更新本地状态
    if (widget.currentThemeMode != oldWidget.currentThemeMode) {
      _selectedThemeMode = widget.currentThemeMode;
    }
  }

  /// 切换主题
  Future<void> _switchTheme(ThemeMode themeMode) async {
    if (_selectedThemeMode == themeMode) return;

    try {
      // 通过 ThemeManager 切换主题，会自动保存到 SharedPreferences 并通知监听器
      await _themeManager.setThemeMode(themeMode);

      if (mounted) {
        setState(() {
          _selectedThemeMode = themeMode;
        });

        // 触发回调通知父组件
        widget.onThemeChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('主题切换失败：$e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  /// 构建主题选项
  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required ThemeMode themeMode,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedThemeMode == themeMode;

    return InkWell(
      onTap: () => _switchTheme(themeMode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : isDark
                    ? AppColors.darkDividerColor
                    : AppColors.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryColor
                  : isDark
                      ? AppColors.darkIconColor
                      : AppColors.textColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primaryColor
                      : isDark
                          ? AppColors.darkTextColor
                          : AppColors.textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: '主题设置',
      child: Column(
        children: [
          _buildThemeOption(
            icon: Icons.light_mode,
            title: '浅色模式',
            themeMode: ThemeMode.light,
          ),
          const SizedBox(height: 12),
          _buildThemeOption(
            icon: Icons.dark_mode,
            title: '深色模式',
            themeMode: ThemeMode.dark,
          ),
          const SizedBox(height: 12),
          _buildThemeOption(
            icon: Icons.brightness_auto,
            title: '跟随系统',
            themeMode: ThemeMode.system,
          ),
        ],
      ),
    );
  }
}
