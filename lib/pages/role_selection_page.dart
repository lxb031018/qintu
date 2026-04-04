import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../config/app_config.dart';
import '../constants/app_strings.dart';
import '../services/secure_storage.dart';
import 'receiver_home_page.dart';
import 'sender_home_page.dart';

/// 角色选择页面 - 用户登录后选择身份：接收者 或 发送者

class RoleSelectionPage extends StatefulWidget {
  final String userId;
  final String accessToken;

  const RoleSelectionPage({
    super.key,
    required this.userId,
    required this.accessToken,
  });

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  bool _isLoading = false;

  Future<void> _selectRole(String role) async {
    setState(() => _isLoading = true);

    try {
      // 保存角色信息到本地（根据角色设置不同的有效期）
      await SecureStorage.saveRole(role);

      // TODO: 将角色信息保存到服务器
      // await saveUserRole(widget.userId, role, widget.accessToken);

      await Future.delayed(const Duration(milliseconds: 300));

      if (role == 'receiver') {
        // 跳转到接收者端主页
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ReceiverHomePage(
                userId: widget.userId,
                accessToken: widget.accessToken,
              ),
            ),
          );
        }
      } else {
        // 跳转到发送者端主页
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SenderHomePage(
                userId: widget.userId,
                accessToken: widget.accessToken,
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                      fontFamily: AppConfig.fontFamily,
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
                    ),

                    const SizedBox(height: 40),

                    _buildRoleButton(
                      role: 'sender',
                      title: AppStrings.iAmSender,
                      subtitle: AppStrings.senderRoleDescription,
                      icon: Icons.send,
                      color: AppColors.secondaryColor,
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
  }) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
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
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                          fontFamily: AppConfig.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.lightTextColor,
                          fontFamily: AppConfig.fontFamily,
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
