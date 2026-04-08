import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_roles.dart';
import '../../../services/secure_storage.dart';
import '../../../managers/auth_state_manager.dart';
import '../../../router/app_router.dart';
import '../../../utils/logger.dart';
import '../../../theme/app_text_styles.dart';
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

    Logs.ui.info('请求切换角色: ${widget.currentRole} -> $roleName');

    // 显示警告风格的确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _RoleSwitchConfirmDialog(
        targetRole: roleName,
      ),
    );

    if (confirmed == true && mounted) {
      try {
        Logs.ui.info('用户确认切换角色: $roleName');

        // 保存新角色
        await SecureStorage.saveRole(newRole);
        Logs.storage.info('角色已保存: $newRole');

        // 更新 AuthStateManager 中的角色状态
        if (mounted) {
          final authStateManager = context.read<AuthStateManager>();
          await authStateManager.updateUserRole(newRole);

          if (mounted) {
            // 跳转到对应主页（通过路由守卫自动处理）
            // 使用 go 直接导航，避免 pop 可能导致的空栈问题
            if (newRole == AppRoles.receiver) {
              context.goToReceiverHome();
            } else {
              context.goToSenderHome();
            }
          }
        }

        Logs.ui.info('角色切换成功: $roleName');
      } catch (e, stackTrace) {
        Logs.ui.error('切换角色失败: $e', stackTrace: stackTrace);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.switchRoleFailed(e.toString())),
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
        return AppStrings.roleNotSet;
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
      title: AppStrings.currentRole,
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
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.switchRoleHint,
                  style: AppTextStyles.locationTitle.copyWith(
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
            label: const Text(AppStrings.switchText),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 40),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================
/// 角色切换确认对话框（警告风格）
///
/// 设计原则：
/// - "取消"按钮显眼、使用安心的绿色
/// - "确定"按钮不显眼、使用警告的橙色
/// - 让用户更容易选择"取消"，避免误操作
/// ============================================

class _RoleSwitchConfirmDialog extends StatelessWidget {
  final String targetRole;

  const _RoleSwitchConfirmDialog({
    required this.targetRole,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // 标题使用警告色
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warningColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.switchRole,
              style: AppTextStyles.dialogTitle.copyWith(
                color: AppColors.warningColor,
              ),
            ),
          ),
        ],
      ),
      // 内容
      content: Text(
        AppStrings.confirmSwitchRole(targetRole),
        style: AppTextStyles.dialogContent,
      ),
      // 按钮区域：调换位置，取消在左（显眼），确定在右（不显眼）
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Row(
          children: [
            // 确定按钮（左边）- 不显眼，使用OutlinedButton + 警告色
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warningColor,
                  side: BorderSide(color: AppColors.warningColor, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.confirm,
                  style: AppTextStyles.dialogButton.copyWith(
                    color: AppColors.warningColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 取消按钮（右边）- 显眼，使用ElevatedButton + 安心的绿色
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.cancel,
                  style: AppTextStyles.dialogButton.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
