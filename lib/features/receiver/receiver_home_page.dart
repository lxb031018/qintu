import 'package:flutter/material.dart';
import 'package:x_amap_base/x_amap_base.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/location_service.dart';
import '../../utils/logger.dart';
import '../../providers/binding_provider.dart';
import '../settings/settings_page.dart';
import '../../theme/app_text_styles.dart';
import 'widgets/receiver_map_widget.dart';
import 'widgets/receiver_location_toggle.dart';
import '../../../services/location_cache_service.dart';
import '../binding/pending_requests_page.dart';

/// 接收者端主页 - 等待接收导航指引

class ReceiverHomePage extends StatefulWidget {
  final String userId;
  final String phone;

  const ReceiverHomePage({
    super.key,
    required this.userId,
    required this.phone,
  });

  @override
  State<ReceiverHomePage> createState() => _ReceiverHomePageState();
}

class _ReceiverHomePageState extends State<ReceiverHomePage> with WidgetsBindingObserver {
  bool _isLocationEnabled = false;

  // 地图相关
  LatLng? _currentPosition;
  dynamic _mapWidgetState;

  @override
  void initState() {
    super.initState();
    // 注册生命周期观察者
    WidgetsBinding.instance.addObserver(this);
    _checkLocationStatus();
    _fetchCurrentPosition(); // 获取当前位置
    // 加载待确认的绑定请求
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingBindingRequests();
    });
  }

  /// 加载待确认的绑定请求
  Future<void> _loadPendingBindingRequests() async {
    final provider = context.read<BindingProvider>();
    await provider.loadPendingRequests();
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
      Logs.ui.info('应用恢复前台，重新检查定位状态');
      _checkLocationStatus();
    }
  }

  /// 检查定位状态
  Future<void> _checkLocationStatus() async {
    final isEnabled = await LocationService.checkPermission();
    if (mounted) {
      setState(() => _isLocationEnabled = isEnabled);
      Logs.ui.info('定位状态更新: ${isEnabled ? "已开启" : "未开启"}');
    }
  }

  /// 获取当前位置并更新地图
  Future<void> _fetchCurrentPosition() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        Logs.ui.info('位置更新: ${position.latitude}, ${position.longitude}');
        
        // 缓存位置
        await LocationCacheService.saveLocation(
          position.latitude,
          position.longitude,
        );
      }
    } catch (e) {
      Logs.ui.warning('获取位置失败: $e');
    }
  }

  /// 定位到当前位置
  void _moveToCurrentPosition() {
    _mapWidgetState?.moveToCurrentPosition();
  }

  /// 显示待确认绑定请求页面
  void _showPendingBindingRequests() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PendingRequestsPage(),
      ),
    ).then((_) {
      // 返回时刷新
      _loadPendingBindingRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 64,
        title: const Text(AppStrings.appName),
        actions: [
          // 绑定请求通知按钮（始终显示，有请求时显示徽章）
          Consumer<BindingProvider>(
            builder: (context, provider, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: _showPendingBindingRequests,
                    tooltip: AppStrings.bindingRequests,
                    iconSize: 28,
                  ),
                  if (provider.hasPendingRequests)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.errorColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          provider.pendingRequestsCount > 99
                              ? '99+'
                              : '${provider.pendingRequestsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // 设置按钮（最右边）
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 30),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            tooltip: AppStrings.settings,
            iconSize: 30,
            padding: const EdgeInsets.only(right: 8),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 地图组件
            ReceiverMapWidget(
              onStateCreated: (state) {
                _mapWidgetState = state;
              },
              currentPosition: _currentPosition,
              onPositionUpdated: (LatLng position) {
                setState(() => _currentPosition = position);
              },
            ),
            // 定位开关（AppBar 下方居中）
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: ReceiverLocationToggle(
                  isLocationEnabled: _isLocationEnabled,
                  onLocationChanged: (isEnabled) {
                    setState(() => _isLocationEnabled = isEnabled);
                  },
                ),
              ),
            ),
            // 定位到当前位置按钮（右下角）
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

  /// 构建定位到当前位置按钮
  Widget _buildLocateMeButton() {
    return GestureDetector(
      onTap: _moveToCurrentPosition,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _currentPosition != null
              ? Colors.white
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
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
                  : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              AppStrings.currentLocation,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: _currentPosition != null
                    ? AppColors.primaryColor
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
