import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/platform_channels.dart';
import '../../../../utils/logger.dart';

class LocationController {
  static const _channel = MethodChannel(PlatformChannels.mapControl);
  static const _eventChannel = EventChannel(PlatformChannels.mapLocationEvent);

  StreamSubscription? _locationSubscription;
  bool _hasMovedToFirstLocation = false;
  String? _lastKnownCity;

  VoidCallback? _onNaviViewExit;

  String? get lastKnownCity => _lastKnownCity;

  void setOnNaviViewExitListener(VoidCallback? listener) {
    _onNaviViewExit = listener;
  }

  Future<void> startLocation({bool autoMoveToFirstLocation = true}) async {
    if (autoMoveToFirstLocation && !_hasMovedToFirstLocation) {
      _listenFirstLocationEvent();
    }
    await _channel.invokeMethod('startLocation');
  }

  void _listenFirstLocationEvent() {
    _locationSubscription?.cancel();
    _locationSubscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event['type'] == 'firstLocation' && !_hasMovedToFirstLocation) {
          _hasMovedToFirstLocation = true;
          final lat = event['latitude'] as double;
          final lng = event['longitude'] as double;
          debugPrint('🚀 首次定位成功，自动移动相机到: $lat, $lng');
          _moveCameraToCenter(lat: lat, lng: lng, zoom: 17);
        } else if (event['type'] == 'naviViewExit') {
          debugPrint('🚪 收到导航退出事件');
          _onNaviViewExit?.call();
        }
      },
      onError: (error) {
        debugPrint('❌ 首次定位事件监听失败: $error');
      },
    );
  }

  Future<void> _moveCameraToCenter({
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

  Future<void> moveToMyLocation() async {
    final result = await _channel.invokeMethod<bool>('moveToMyLocation');
    if (result == false) {}
  }

  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getCurrentLocation');
      if (result != null) {
        _lastKnownCity = result['city'] as String? ?? '';
        return {
          'latitude': result['latitude'] as double,
          'longitude': result['longitude'] as double,
          'accuracy': result['accuracy'] as double,
          'timestamp': result['timestamp'] as int,
          'city': _lastKnownCity,
        };
      }
      return null;
    } catch (e) {
      Logs.location.error('getCurrentLocation: Platform Channel异常', stackTrace: StackTrace.current);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLastKnownLocation() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getLastKnownLocation');
      if (result != null) {
        _lastKnownCity = result['city'] as String? ?? '';
        return {
          'latitude': result['latitude'] as double,
          'longitude': result['longitude'] as double,
          'city': _lastKnownCity,
        };
      }
    } catch (e) {
      Logs.location.warning('getLastKnownLocation: Platform Channel异常 $e');
    }
    return null;
  }

  void dispose() {
    _locationSubscription?.cancel();
  }
}