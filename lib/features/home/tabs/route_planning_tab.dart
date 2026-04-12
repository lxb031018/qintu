import 'package:flutter/material.dart';
import 'package:x_amap_base/x_amap_base.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_durations.dart';
import '../../../theme/app_text_styles.dart';
import '../../../services/location_service.dart';
import '../../../services/location_cache_service.dart';
import '../../../utils/app_snackbar.dart';
import '../../../utils/logger.dart';
import 'widgets/route_map_widget.dart';

/// 路线规划 Tab 页面
/// 
/// 整合地图和路线输入功能，所有用户都能看到相同界面：
/// - 地图显示（始终可见）
/// - 起点/终点输入
/// - 规划路线按钮
/// - 定位到当前位置按钮

class RoutePlanningTab extends StatefulWidget {
  const RoutePlanningTab({super.key});

  @override
  State<RoutePlanningTab> createState() => _RoutePlanningTabState();
}

class _RoutePlanningTabState extends State<RoutePlanningTab> with WidgetsBindingObserver {
  final TextEditingController _startPointController = TextEditingController();
  final TextEditingController _endPointController = TextEditingController();
  bool _isLoading = false;
  
  // 地图和位置相关
  LatLng? _currentPosition;
  dynamic _mapWidgetState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationStatus();
    _fetchCurrentPosition();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _startPointController.dispose();
    _endPointController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Logs.ui.info('应用恢复前台，重新检查定位状态');
      _checkLocationStatus();
    }
  }

  /// 检查定位状态
  Future<void> _checkLocationStatus() async {
    final isEnabled = await LocationService.checkPermission();
    if (mounted) {
      Logs.ui.info('定位状态更新: ${isEnabled ? "已开启" : "未开启"}');
    }
  }

  /// 获取当前位置
  Future<void> _fetchCurrentPosition() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        Logs.ui.info('位置更新: ${position.latitude}, ${position.longitude}');

        await LocationCacheService.saveLocation(
          position.latitude,
          position.longitude,
        );
      }
    } catch (e) {
      Logs.ui.warning('获取位置失败: $e');
    }
  }

  /// 规划路线
  Future<void> _planRoute() async {
    final start = _startPointController.text.trim();
    final end = _endPointController.text.trim();

    if (start.isEmpty || end.isEmpty) {
      _showSnackBar(AppStrings.pleaseFillRoute);
      return;
    }

    setState(() => _isLoading = true);

    // TODO: 调用路线规划 API
    await Future.delayed(AppDurations.splashMinDuration);

    setState(() => _isLoading = false);

    // TODO: 显示规划结果，选择接收者发送
    _showSnackBar(AppStrings.routePlanningInDevelopment);
  }

  /// 移动到当前位置
  void _moveToCurrentPosition() {
    _mapWidgetState?.moveToCurrentPosition();
  }

  void _showSnackBar(String message) {
    AppSnackbar.showInfo(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.textColor;
    final lightTextColor = isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor;
    final cardBackground = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // 地图层（底层）
            Positioned.fill(
              child: RouteMapWidget(
                onStateCreated: (state) {
                  _mapWidgetState = state;
                },
                currentPosition: _currentPosition,
                onPositionUpdated: (LatLng position) {
                  setState(() => _currentPosition = position);
                },
              ),
            ),
            
            // 输入卡片层（顶层，悬浮在地图上方）
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildInputCard(
                isDark: isDark,
                textColor: textColor,
                lightTextColor: lightTextColor,
                cardBackground: cardBackground,
              ),
            ),
            
            // 定位按钮（右下角）
            Positioned(
              bottom: 24,
              right: 16,
              child: _buildLocateMeButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建输入卡片
  Widget _buildInputCard({
    required bool isDark,
    required Color textColor,
    required Color lightTextColor,
    required Color cardBackground,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题
            Text(
              AppStrings.routePlanningTitle,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // 起点输入
            _buildInputField(
              controller: _startPointController,
              label: AppStrings.startPointLabel,
              hint: AppStrings.inputStartPoint,
              icon: Icons.trip_origin,
              textColor: textColor,
              lightTextColor: lightTextColor,
              cardBackground: cardBackground,
            ),
            
            const SizedBox(height: 12),
            
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
            
            const SizedBox(height: 12),
            
            // 终点输入
            _buildInputField(
              controller: _endPointController,
              label: AppStrings.endPointLabel,
              hint: AppStrings.inputEndPoint,
              icon: Icons.location_on,
              textColor: textColor,
              lightTextColor: lightTextColor,
              cardBackground: cardBackground,
            ),
            
            const SizedBox(height: 20),
            
            // 规划路线按钮
            _buildPlanButton(
              textColor: textColor,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建输入字段
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color textColor,
    required Color lightTextColor,
    required Color cardBackground,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.caption.copyWith(
            color: AppColors.primaryColor,
          ),
          hintText: hint,
          hintStyle: AppTextStyles.caption.copyWith(
            color: lightTextColor,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// 构建规划按钮
  Widget _buildPlanButton({required Color textColor}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryColor,
            AppColors.secondaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.whiteText,
                  strokeWidth: 3,
                ),
              )
            : Text(
                AppStrings.planRoute,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteText,
                ),
              ),
      ),
    );
  }

  /// 构建定位到当前位置按钮
  Widget _buildLocateMeButton() {
    return GestureDetector(
      onTap: _moveToCurrentPosition,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _currentPosition != null
              ? AppColors.cardBackground
              : AppColors.grey300,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackOpacity15,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.my_location,
              color: _currentPosition != null
                  ? AppColors.primaryColor
                  : AppColors.disabledColor,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              AppStrings.currentLocation,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: _currentPosition != null
                    ? AppColors.primaryColor
                    : AppColors.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
