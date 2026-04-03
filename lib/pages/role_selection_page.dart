import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../config/app_config.dart';
import '../constants/app_strings.dart';

/// 角色选择页面 - 用户登录后选择身份：长辈 或 晚辈

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
      // TODO: 将角色信息保存到服务器
      // await saveUserRole(widget.userId, role, widget.accessToken);

      await Future.delayed(const Duration(milliseconds: 500));

      if (role == 'elder') {
        // TODO: 跳转到长辈端主页
        _showSuccessDialog(AppStrings.roleElder);
      } else {
        // TODO: 跳转到晚辈端主页
        _showSuccessDialog(AppStrings.roleJunior);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog(String role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.roleSetSuccess),
        content: Text(AppStrings.roleSetSuccessMessage(role)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _isLoading = false);
            },
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
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
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.roleSelectionHint,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.lightTextColor,
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
                      role: 'elder',
                      title: AppStrings.iAmElder,
                      subtitle: AppStrings.elderRoleDescription,
                      icon: Icons.elderly,
                      color: AppColors.primaryColor,
                    ),

                    const SizedBox(height: 40),

                    _buildRoleButton(
                      role: 'junior',
                      title: AppStrings.iAmJunior,
                      subtitle: AppStrings.juniorRoleDescription,
                      icon: Icons.family_restroom,
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
