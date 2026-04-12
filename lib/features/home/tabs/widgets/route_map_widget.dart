import 'package:flutter/material.dart';
import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart';
import '../../../../services/amap_service.dart';
import '../../../../services/location_cache_service.dart';
import '../../../../utils/logger.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../theme/app_text_styles.dart';

/// 路线规划地图组件
/// 
/// 与 ReceiverMapWidget 类似，但用于统一主页的路线规划Tab

class RouteMapWidget extends StatefulWidget {
  /// 地图创建成功回调
  final Function(AMapController controller)? onMapCreated;

  /// 当前位置
  final LatLng? currentPosition;

  /// 位置更新回调
  final Function(LatLng position)? onPositionUpdated;

  /// 状态创建成功回调（使用 dynamic 类型）
  final Function(dynamic state)? onStateCreated;

  const RouteMapWidget({
    super.key,
    this.onMapCreated,
    this.currentPosition,
    this.onPositionUpdated,
    this.onStateCreated,
  });

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  AMapController? _mapController;
  bool _isMapReady = false;
  LatLng? _cachedPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 通知父组件状态已创建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStateCreated?.call(this);
    });
    _loadCachedPosition();
  }

  /// 加载缓存位置
  Future<void> _loadCachedPosition() async {
    final cached = await LocationCacheService.getCachedLocation();
    if (cached != null && mounted) {
      setState(() {
        _cachedPosition = LatLng(cached[0], cached[1]);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在 didChangeDependencies 中初始化，确保 inherited widget 可用
    AmapService.instance.initialize(context);
  }

  /// 地图创建成功回调
  void _onMapCreated(AMapController controller) {
    _mapController = controller;
    _isMapReady = true;
    Logs.ui.info('地图创建成功');

    // 通知父组件
    widget.onMapCreated?.call(controller);

    // 如果已有位置，移动到该位置
    if (widget.currentPosition != null) {
      _moveToPosition(widget.currentPosition!);
    }
  }

  /// 移动到指定位置
  void _moveToPosition(LatLng position) {
    if (_mapController == null) return;

    _mapController!.moveCamera(
      CameraUpdate.newLatLngZoom(position, 15.0),
      animated: true,
      duration: 500,
    );
  }

  /// 位置变化回调
  void _onLocationChanged(AMapLocation location) {
    Logs.map.info('位置更新: $location');
    // 注意：AMapLocation 的字段需要根据实际 API 调整
    // 这里暂时只记录日志，实际位置更新由父组件通过 geolocator 获取
  }

  @override
  Widget build(BuildContext context) {
    // 优先使用实际位置，其次是缓存位置，最后才显示加载状态
    final displayPosition = widget.currentPosition ?? _cachedPosition;

    // 如果正在加载且没有位置，显示加载状态
    if (_isLoading && displayPosition == null) {
      return _buildLoadingState();
    }

    // 如果有位置，显示地图
    final initialPosition = displayPosition ??
        const LatLng(39.9042, 116.4074); // 最后的 fallback

    return AMapWidget(
      // 初始相机位置
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 15.0,
      ),
      // 地图创建成功回调
      onMapCreated: _onMapCreated,
      // 地图点击回调
      onTap: (LatLng latLng) {
        Logs.ui.info('点击地图: $latLng');
      },
      // 位置变化回调
      onLocationChanged: _onLocationChanged,
      // 显示实时路况
      trafficEnabled: false,
      // 地图类型
      mapType: MapType.normal,
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Container(
      color: AppColors.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.fetchingLocation,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  /// 公开方法：移动到当前位置
  void moveToCurrentPosition() {
    if (widget.currentPosition != null && _isMapReady) {
      _moveToPosition(widget.currentPosition!);
    }
  }
}
