import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/platform_channels.dart';

class GestureController {
  static const _channel = MethodChannel(PlatformChannels.mapControl);

  Future<bool> setScrollGesturesEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setScrollGesturesEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setScrollGesturesEnabled 失败: $e');
      return false;
    }
  }

  Future<bool> setZoomGesturesEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setZoomGesturesEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setZoomGesturesEnabled 失败: $e');
      return false;
    }
  }

  Future<bool> setRotateGesturesEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setRotateGesturesEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setRotateGesturesEnabled 失败: $e');
      return false;
    }
  }

  Future<bool> setTiltGesturesEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setTiltGesturesEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setTiltGesturesEnabled 失败: $e');
      return false;
    }
  }
}