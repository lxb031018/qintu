import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/location/lat_lng.dart';
import '../core/amap_map_controller.dart';

/// ============================================
/// 高德地图显示组件
///
/// 使用 PlatformView 嵌入 Android 原生高德地图
/// 定位功能由原生 AMapLocationClient 提供（无需 geolocator）
///
/// 架构说明：
/// - [AmapMapView] - 纯 UI 组件，位于 widgets 层
/// - [AmapMapController] - 平台 API 封装，位于 core 层
/// ============================================

class AmapMapView extends StatefulWidget {
  final List<LatLng>? routePoints;
  final Function(AmapMapController controller)? onMapCreated;

  const AmapMapView({
    super.key,
    this.routePoints,
    this.onMapCreated,
  });

  @override
  State<AmapMapView> createState() => _AmapMapViewState();
}

class _AmapMapViewState extends State<AmapMapView> {
  late AmapMapController _controller;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Center(child: Text('地图暂不支持 Web 平台'));
    }

    return AndroidView(
      viewType: 'com.qintu/amap_map_view',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: <String, dynamic>{},
      creationParamsCodec: const StandardMessageCodec(),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _controller = AmapMapController();

    // 🚀 立即启动高德原生定位
    _controller.startLocation();

    // 绘制路线
    if (widget.routePoints != null && widget.routePoints!.isNotEmpty) {
      await _controller.addPolyline(widget.routePoints!);
    }

    widget.onMapCreated?.call(_controller);
  }
}
