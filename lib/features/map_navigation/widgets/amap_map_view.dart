import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/platform_channels.dart';
import '../service/map_controller_service/map_controller_service.dart';
import '../provider/map_display/map_controller_provider.dart';

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
  final Function(MapControllerService controller)? onMapCreated;

  const AmapMapView({
    super.key,
    this.onMapCreated,
  });

  @override
  State<AmapMapView> createState() => _AmapMapViewState();
}

class _AmapMapViewState extends State<AmapMapView> with WidgetsBindingObserver {
  MapControllerService? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _controller!.pauseNaviView();
        break;
      case AppLifecycleState.resumed:
        _controller!.resumeNaviView();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Center(child: Text('地图暂不支持 Web 平台'));
    }

    return Consumer(
      builder: (context, ref, child) {
        return AndroidView(
          viewType: PlatformChannels.naviView,
          onPlatformViewCreated: (id) => _onPlatformViewCreated(id, ref),
          creationParams: <String, dynamic>{},
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
          },
        );
      },
    );
  }

  Future<void> _onPlatformViewCreated(int id, WidgetRef ref) async {
    final controller = ref.read(mapControllerProvider);
    if (controller == null) return;

    _controller = controller;
    ref.read(mapControllerNotifierProvider.notifier).setController(controller);

    controller.startLocation();

    widget.onMapCreated?.call(controller);
  }
}
