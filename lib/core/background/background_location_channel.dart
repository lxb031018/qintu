import 'dart:async';
import 'package:flutter/services.dart';
import '../constants/platform_channels.dart';
import '../../utils/logger.dart';

/// ============================================
/// 后台定位通道（core 层）
///
/// 封装 MethodChannel + EventChannel 与 Android
/// 后台定位服务通信
/// ============================================
class BackgroundLocationChannel {
  static const _methodChannel = MethodChannel(PlatformChannels.backgroundLocation);
  static const _eventChannel = EventChannel(PlatformChannels.backgroundLocationEvents);

  StreamSubscription? _subscription;

  /// 启动后台定位服务
  Future<bool> start() async {
    try {
      await _methodChannel.invokeMethod('start');
      return true;
    } catch (e) {
      Logs.location.error('启动后台定位失败: $e');
      return false;
    }
  }

  /// 停止后台定位服务
  Future<bool> stop() async {
    try {
      _subscription?.cancel();
      _subscription = null;
      await _methodChannel.invokeMethod('stop');
      return true;
    } catch (e) {
      Logs.location.error('停止后台定位失败: $e');
      return false;
    }
  }

  /// 检查后台定位服务是否运行中
  Future<bool> isRunning() async {
    try {
      return await _methodChannel.invokeMethod<bool>('isRunning') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 监听后台定位更新
  void listenLocationUpdates({
    required void Function(Map<String, dynamic> location) onLocationUpdate,
    void Function(String error)? onError,
  }) {
    _subscription?.cancel();
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          onLocationUpdate(Map<String, dynamic>.from(event));
        }
      },
      onError: (error) {
        onError?.call(error.toString());
      },
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
