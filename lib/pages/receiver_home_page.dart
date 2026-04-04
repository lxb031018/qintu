import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../config/app_config.dart';
import '../constants/app_strings.dart';
import '../services/location_service.dart';
import '../widgets/common/logout_dialog.dart';

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
            onTap: () => LogoutDialog.show(context),
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
