import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../config/app_config.dart';
import '../constants/app_strings.dart';
import '../services/location_service.dart';
import '../services/secure_storage.dart';
import 'role_selection_page.dart';

/// 接收者端主页 - 等待接收导航指引

class ReceiverHomePage extends StatefulWidget {
  final String userId;
  final String accessToken;

  const ReceiverHomePage({
    super.key,
    required this.userId,
    required this.accessToken,
  });

  @override
  State<ReceiverHomePage> createState() => _ReceiverHomePageState();
}

class _ReceiverHomePageState extends State<ReceiverHomePage> {
  bool _isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  /// 检查定位状态
  Future<void> _checkLocationStatus() async {
    final isEnabled = await LocationService.checkPermission();
    if (mounted) {
      setState(() => _isLocationEnabled = isEnabled);
    }
  }

  /// 打开定位设置
  Future<void> _openLocationSettings() async {
    await LocationService.openLocationSettings();
    // 延迟检查状态（用户可能需要时间开启）
    await Future.delayed(const Duration(seconds: 1));
    await _checkLocationStatus();
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
        toolbarHeight: 72,
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
        actions: [
          // 定位开关按钮（右上角）
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: GestureDetector(
              onTap: _openLocationSettings,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _isLocationEnabled
                      ? AppColors.successColor.withValues(alpha: 0.15)
                      : AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLocationEnabled ? Icons.location_on : Icons.location_off,
                      size: 26,
                      color: _isLocationEnabled
                          ? AppColors.successColor
                          : Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isLocationEnabled
                          ? AppStrings.locationEnabled
                          : AppStrings.openLocation,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.2,
                        color: _isLocationEnabled
                            ? AppColors.successColor
                            : Colors.white,
                        fontFamily: AppConfig.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 状态图标
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.navigation_outlined,
                  size: 80,
                  color: AppColors.primaryColor,
                ),
              ),

              const SizedBox(height: 32),

              // 提示文字
              Text(
                AppStrings.waitingForNavigation,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                  fontFamily: AppConfig.fontFamily,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                AppStrings.noNavigationTask,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.lightTextColor,
                  fontFamily: AppConfig.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
