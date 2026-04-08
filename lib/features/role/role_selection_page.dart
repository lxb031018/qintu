import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/secure_storage.dart';
import '../../router/app_router.dart';
import '../../theme/app_text_styles.dart';

/// 角色选择页面 - 用户登录后选择身份：接收者 或 发送者

class RoleSelectionPage extends StatefulWidget {
  final String userId;
  final String phone;

  const RoleSelectionPage({
    super.key,
    required this.userId,
    required this.phone,
  });

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  bool _isLoading = false;

  Future<void> _selectRole(String role) async {
    setState(() => _isLoading = true);

    try {
      // 保存角色信息到本地
      await SecureStorage.saveRole(role);

      if (role == 'receiver') {
        // 跳转到接收者端主页
        if (mounted) {
          context.goToReceiverHome();
        }
      } else {
        // 跳转到发送者端主页
        if (mounted) {
          context.goToSenderHome();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.settingFailed),
        content: Text('${AppStrings.saveRoleFailed}\n错误：$error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.textColor;
    final lightTextColor = isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor;
    final cardBackground = isDark ? AppColors.darkCardBackground : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // 标题区域
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.roleSelectionTitle,
                    style: AppTextStyles.roleIcon.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // 角色选择按钮
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRoleButton(
                      role: 'receiver',
                      title: AppStrings.iAmReceiver,
                      subtitle: AppStrings.receiverRoleDescription,
                      icon: Icons.move_to_inbox,
                      color: AppColors.primaryColor,
                      cardBackground: cardBackground,
                      textColor: textColor,
                      lightTextColor: lightTextColor,
                    ),

                    const SizedBox(height: 40),

                    _buildRoleButton(
                      role: 'sender',
                      title: AppStrings.iAmSender,
                      subtitle: AppStrings.senderRoleDescription,
                      icon: Icons.send,
                      color: AppColors.secondaryColor,
                      cardBackground: cardBackground,
                      textColor: textColor,
                      lightTextColor: lightTextColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color cardBackground,
    required Color textColor,
    required Color lightTextColor,
  }) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : () => _selectRole(role),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: color,
                  ),
                ),

                const SizedBox(width: 24),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.roleCardIcon.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: AppTextStyles.roleName.copyWith(
                          color: lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!_isLoading)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 28,
                    color: color,
                  ),

                if (_isLoading)
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
