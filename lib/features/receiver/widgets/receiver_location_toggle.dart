import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../services/location_service.dart';
import '../../../utils/logger.dart';
import '../../../theme/app_text_styles.dart';

/// 定位开关组件 - 显示定位状态并允许用户开启/关闭定位

class ReceiverLocationToggle extends StatefulWidget {
  /// 定位是否已开启
  final bool isLocationEnabled;

  /// 状态变化回调
  final Function(bool isEnabled)? onLocationChanged;

  const ReceiverLocationToggle({
    super.key,
    required this.isLocationEnabled,
    this.onLocationChanged,
  });

  @override
  State<ReceiverLocationToggle> createState() => _ReceiverLocationToggleState();
}

class _ReceiverLocationToggleState extends State<ReceiverLocationToggle> {
  bool _isCheckingLocation = false;

  /// 检查定位状态
  Future<void> _checkLocationStatus() async {
    if (_isCheckingLocation) return;

    setState(() => _isCheckingLocation = true);

    try {
      final isEnabled = await LocationService.checkPermission();
      if (mounted) {
        setState(() {});
        widget.onLocationChanged?.call(isEnabled);
        Logs.ui.info('定位状态更新: ${isEnabled ? "已开启" : "未开启"}');
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
      Logs.ui.info('已打开定位设置页面，等待用户操作...');
    } else {
      Logs.app.warning('打开定位设置失败');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lightTextColor = isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor;

    return GestureDetector(
      onTap: _isCheckingLocation ? null : _openLocationSettings,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: _isCheckingLocation
              ? lightTextColor.withAlpha(77)
              : widget.isLocationEnabled
                  ? AppColors.successColor.withAlpha(38)
                  : AppColors.primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isCheckingLocation)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(
                widget.isLocationEnabled ? Icons.location_on : Icons.location_off,
                size: 22,
                color: widget.isLocationEnabled
                    ? AppColors.successColor
                    : Colors.white,
              ),
            if (!_isCheckingLocation) const SizedBox(width: 8),
            if (!_isCheckingLocation)
              Text(
                widget.isLocationEnabled
                    ? AppStrings.locationEnabled
                    : AppStrings.openLocation,
                style: AppTextStyles.bodySmall.copyWith(
                  height: 1.2,
                  color: widget.isLocationEnabled
                      ? AppColors.successColor
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
