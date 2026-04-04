import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../config/app_config.dart';
import '../constants/app_strings.dart';
import '../services/secure_storage.dart';
import 'role_selection_page.dart';

/// 发送者端主页 - 输入起终点，发送导航指引

class SenderHomePage extends StatefulWidget {
  final String userId;
  final String accessToken;

  const SenderHomePage({
    super.key,
    required this.userId,
    required this.accessToken,
  });

  @override
  State<SenderHomePage> createState() => _SenderHomePageState();
}

class _SenderHomePageState extends State<SenderHomePage> {
  final TextEditingController _startPointController = TextEditingController();
  final TextEditingController _endPointController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _startPointController.dispose();
    _endPointController.dispose();
    super.dispose();
  }

  Future<void> _planRoute() async {
    final start = _startPointController.text.trim();
    final end = _endPointController.text.trim();

    if (start.isEmpty || end.isEmpty) {
      _showSnackBar('请输入起点和终点');
      return;
    }

    setState(() => _isLoading = true);

    // TODO: 调用路线规划 API
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    // TODO: 显示规划结果，选择接收者发送
    _showSnackBar('路线规划功能开发中...');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示退出确认对话框
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          AppStrings.logoutConfirmTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: AppConfig.fontFamily,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Row(
            children: [
              // 确定按钮（左边）
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    // 清除登录状态
                    await SecureStorage.clearTokens();
                    // 跳转到角色选择页面
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => RoleSelectionPage(
                          userId: widget.userId,
                          accessToken: widget.accessToken,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppStrings.confirmLogout,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConfig.fontFamily,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 取消按钮（右边）
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightTextColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppStrings.cancelLogout,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConfig.fontFamily,
                    ),
                  ),
                ),
              ),
            ],
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
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: _showLogoutDialog,
            child: Center(
              child: Text(
                AppStrings.logout,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.lightTextColor,
                  fontFamily: AppConfig.fontFamily,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          AppStrings.senderHomeTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
            fontFamily: AppConfig.fontFamily,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 起点输入
              _buildInputCard(
                controller: _startPointController,
                label: AppStrings.startPointLabel,
                hint: AppStrings.inputStartPoint,
                icon: Icons.trip_origin,
              ),

              const SizedBox(height: 16),

              // 连接线
              Row(
                children: [
                  const SizedBox(width: 28),
                  Container(
                    width: 2,
                    height: 24,
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 终点输入
              _buildInputCard(
                controller: _endPointController,
                label: AppStrings.endPointLabel,
                hint: AppStrings.inputEndPoint,
                icon: Icons.location_on,
              ),

              const SizedBox(height: 32),

              // 规划路线按钮
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondaryColor,
                      AppColors.secondaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _planRoute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          AppStrings.planRoute,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: AppConfig.fontFamily,
                          ),
                        ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 18,
          color: AppColors.textColor,
          fontFamily: AppConfig.fontFamily,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 16,
            fontFamily: AppConfig.fontFamily,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.lightTextColor,
            fontSize: 16,
            fontFamily: AppConfig.fontFamily,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}