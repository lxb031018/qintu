import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../config/app_config.dart';
import '../constants/app_strings.dart';
import '../services/location_service.dart';
import '../widgets/common/logout_dialog.dart';
import '../utils/logger.dart';

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

class _ReceiverHomePageState extends State<ReceiverHomePage> with WidgetsBindingObserver {
  bool _isLocationEnabled = false;
  bool _isCheckingLocation = false; // 防止重复检查

  @override
  void initState() {
    super.initState();
    // 注册生命周期观察者
    WidgetsBinding.instance.addObserver(this);
    _checkLocationStatus();
  }

  @override
  void dispose() {
    // 移除生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 监听应用生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 当应用从后台恢复时（用户从设置返回），重新检查定位状态
    if (state == AppLifecycleState.resumed) {
      Logger.ui('应用恢复前台，重新检查定位状态');
      _checkLocationStatus();
    }
  }

  /// 检查定位状态
  Future<void> _checkLocationStatus() async {
    // 防止重复检查
    if (_isCheckingLocation) return;
    
    setState(() => _isCheckingLocation = true);
    
    try {
      final isEnabled = await LocationService.checkPermission();
      if (mounted) {
        setState(() => _isLocationEnabled = isEnabled);
        Logger.ui('定位状态更新: ${isEnabled ? "已开启" : "未开启"}');
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingLocation = false);
      }
    }
  }

  /// 打开定位设置
  Future<void> _openLocationSettings() async {
    final opened = await LocationService.openLocationSettings();
    if (opened) {
      Logger.ui('已打开定位设置页面，等待用户操作...');
      // 不在这里延迟检查，而是等用户返回时由生命周期触发
    } else {
      Logger.warning('打开定位设置失败');
    }
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
              onTap: _isCheckingLocation ? null : _openLocationSettings,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _isCheckingLocation
                      ? AppColors.lightTextColor.withValues(alpha: 0.3)
                      : _isLocationEnabled
                          ? AppColors.successColor.withValues(alpha: 0.15)
                          : AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isCheckingLocation)
                      const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      Icon(
                        _isLocationEnabled ? Icons.location_on : Icons.location_off,
                        size: 26,
                        color: _isLocationEnabled
                            ? AppColors.successColor
                            : Colors.white,
                      ),
                    if (!_isCheckingLocation) const SizedBox(width: 10),
                    if (!_isCheckingLocation)
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
