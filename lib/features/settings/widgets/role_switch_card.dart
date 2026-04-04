import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_roles.dart';
import '../../../services/secure_storage.dart';
import '../../../services/navigation_service.dart';
import '../../../utils/logger.dart';
import 'settings_section_card.dart';

/// ============================================
/// 角色切换卡片组件
///
/// 显示当前角色并提供切换功能
/// ============================================

class RoleSwitchCard extends StatefulWidget {
  final String currentRole;
  final VoidCallback? onRoleChanged;

  const RoleSwitchCard({
    super.key,
    required this.currentRole,
    this.onRoleChanged,
  });

  @override
  State<RoleSwitchCard> createState() => _RoleSwitchCardState();
}

class _RoleSwitchCardState extends State<RoleSwitchCard> {
  /// 切换角色
  Future<void> _switchRole() async {
    final newRole = widget.currentRole == AppRoles.receiver
        ? AppRoles.sender
        : AppRoles.receiver;

    final roleName = newRole == AppRoles.receiver
        ? AppStrings.roleReceiver
        : AppStrings.roleSender;

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换角色'),
        content: Text('确定要切换到$roleName吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancelLogout),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.confirmLogout),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // 保存新角色
        await SecureStorage.saveRole(newRole);

        if (!mounted) return;

        // 获取登录信息
        final loginInfo = await SecureStorage.getLoginInfo();
        final userId = loginInfo?['user_id'] ?? '';
        final phone = loginInfo?['phone_number'] ?? '';
        final accessToken = loginInfo?['access_token'] ?? '';

        // 跳转到对应主页
        if (mounted) {
          await NavigationService.goToHomeByRole(
            context,
            userId: userId,
            phone: phone,
            accessToken: accessToken,
            userRole: newRole,
          );
        }

        // 触发回调
        widget.onRoleChanged?.call();
      } catch (e) {
        Logs.app.error('切换角色失败: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('切换角色失败，请重试'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }

  /// 获取角色名称
  String _getRoleName(String role) {
    switch (role) {
      case AppRoles.receiver:
        return AppStrings.roleReceiver;
      case AppRoles.sender:
        return AppStrings.roleSender;
      default:
        return '未设置';
    }
  }

  /// 获取角色图标
  IconData _getRoleIcon(String role) {
    switch (role) {
      case AppRoles.receiver:
        return Icons.location_on;
      case AppRoles.sender:
        return Icons.send;
      default:
        return Icons.help_outline;
    }
  }

  /// 获取角色颜色
  Color _getRoleColor(String role) {
    switch (role) {
      case AppRoles.receiver:
        return AppColors.successColor;
      case AppRoles.sender:
        return AppColors.infoColor;
      default:
        return AppColors.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsSectionCard(
      title: '当前角色',
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getRoleColor(widget.currentRole).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getRoleIcon(widget.currentRole),
              color: _getRoleColor(widget.currentRole),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getRoleName(widget.currentRole),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '点击右侧按钮切换角色',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkLightTextColor
                        : AppColors.lightTextColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _switchRole,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('切换'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 40),
            ),
          ),
        ],
      ),
    );
  }
}
