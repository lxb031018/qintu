import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/platform_channels.dart';

class CameraController {
  static const _channel = MethodChannel(PlatformChannels.mapControl);

  Future<void> moveCamera({
    required double lat,
    required double lng,
    double zoom = 15.0,
  }) async {
    await _channel.invokeMethod('moveCamera', {
      'lat': lat,
      'lng': lng,
      'zoom': zoom,
    });
  }

  Future<bool> animateCamera({
    required double lat,
    required double lng,
    double zoom = 15.0,
    double bearing = -1,
    double tilt = -1,
    int duration = 0,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('animateCamera', {
        'lat': lat,
        'lng': lng,
        'zoom': zoom,
        if (bearing >= 0) 'bearing': bearing,
        if (tilt >= 0) 'tilt': tilt,
        if (duration > 0) 'duration': duration,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ animateCamera 失败: $e');
      return false;
    }
  }

  Future<void> zoomIn() => _channel.invokeMethod('zoomIn');

  Future<void> zoomOut() => _channel.invokeMethod('zoomOut');

  Future<void> zoomTo(double level, {int duration = 0}) =>
      _channel.invokeMethod('zoomTo', {'level': level, 'duration': duration});

  Future<void> setPointToCenter({required int x, required int y}) async {
    await _channel.invokeMethod('setPointToCenter', {'x': x, 'y': y});
  }

  Future<void> changeLatLng({required double lat, required double lng}) async {
    await _channel.invokeMethod('changeLatLng', {'lat': lat, 'lng': lng});
  }

  Future<void> moveCameraToCenter({
    required double lat,
    required double lng,
    double zoom = 15.0,
  }) async {
    await _channel.invokeMethod('moveCameraToCenter', {
      'lat': lat,
      'lng': lng,
      'zoom': zoom,
    });
  }

  Future<void> animateCameraToCenter({
    required double lat,
    required double lng,
    double zoom = 15.0,
    int duration = 500,
  }) async {
    await _channel.invokeMethod('animateCameraToCenter', {
      'lat': lat,
      'lng': lng,
      'zoom': zoom,
      'duration': duration,
    });
  }

  Future<void> animateCameraToBounds(
    List<Map<String, double>> points, {
    int padding = 100,
    int duration = 800,
  }) async {
    await _channel.invokeMethod('animateCameraToBounds', {
      'points': points,
      'padding': padding,
      'duration': duration,
    });
  }
}