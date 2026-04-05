import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../config/app_config.dart';
import '../../constants/app_strings.dart';

/// 发送者 Home 内容（路径规划、发送导航）
///
/// 这是发送者的核心功能页面，包含：
/// - 起点输入
/// - 终点输入
/// - 规划路线
/// - 选择接收者发送

class SenderHomeContent extends StatefulWidget {
  final String userId;
  final String accessToken;

  const SenderHomeContent({
    super.key,
    required this.userId,
    required this.accessToken,
  });

  @override
  State<SenderHomeContent> createState() => _SenderHomeContentState();
}

class _SenderHomeContentState extends State<SenderHomeContent> {
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
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          AppStrings.senderHomeTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
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
                isDark: isDark,
                cardBackground: cardBackground,
                textColor: textColor,
                lightTextColor: lightTextColor,
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
                isDark: isDark,
                cardBackground: cardBackground,
                textColor: textColor,
                lightTextColor: lightTextColor,
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
    required bool isDark,
    required Color cardBackground,
    required Color textColor,
    required Color lightTextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
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
          color: textColor,
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
            color: lightTextColor,
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
          fillColor: cardBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
