import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/platform_channels.dart';

class NaviViewController {
  static const _channel = MethodChannel(PlatformChannels.mapControl);

  Future<void> pauseNaviView() async {
    await _channel.invokeMethod('pauseNaviView');
  }

  Future<void> resumeNaviView() async {
    await _channel.invokeMethod('resumeNaviView');
  }

  Future<void> setNaviShowMode(int mode) async {
    await _channel.invokeMethod('setNaviShowMode', {'mode': mode});
  }

  Future<void> enableNaviMode() async {
    await _channel.invokeMethod('enableNaviMode');
  }

  Future<void> disableNaviMode() async {
    await _channel.invokeMethod('disableNaviMode');
  }

  Future<bool> updateCarMarker({
    required double lat,
    required double lng,
    double bearing = 0,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('updateCarMarker', {
        'lat': lat,
        'lng': lng,
        'bearing': bearing,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ 更新车辆标记失败: $e');
      return false;
    }
  }

  Future<bool> setFollowMode(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setFollowMode', {
        'enabled': enabled,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ 设置跟随模式失败: $e');
      return false;
    }
  }

  Future<bool> setLockCar(bool locked) async {
    try {
      final result = await _channel.invokeMethod<bool>('setLockCar', {
        'locked': locked,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setLockCar 失败: $e');
      return false;
    }
  }

  Future<bool> setLocationDotEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setLocationDotEnabled', {
        'enabled': enabled,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ 设置定位蓝点失败: $e');
      return false;
    }
  }

  Future<bool> setCarOverlayVisible(bool visible) async {
    try {
      final result = await _channel.invokeMethod<bool>('setCarOverlayVisible', {
        'visible': visible,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ 设置车载标记可见性失败: $e');
      return false;
    }
  }

  Future<bool> clearCarMarker() async {
    try {
      final result = await _channel.invokeMethod<bool>('clearCarMarker');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ 清除车辆标记失败: $e');
      return false;
    }
  }

  Future<bool> setMapType(int type) async {
    try {
      final result = await _channel.invokeMethod<bool>('setMapType', {'type': type});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setMapType 失败: $e');
      return false;
    }
  }

  Future<bool> setTrafficEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setTrafficEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setTrafficEnabled 失败: $e');
      return false;
    }
  }

  Future<bool> setBuildingsEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setBuildingsEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setBuildingsEnabled 失败: $e');
      return false;
    }
  }

  Future<bool> showIndoorMap(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('showIndoorMap', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ showIndoorMap 失败: $e');
      return false;
    }
  }

  Future<bool> setRouteTmcEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setRouteTmcEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setRouteTmcEnabled 失败: $e');
      return false;
    }
  }

  Future<bool> setRouteTrafficIconEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setRouteTrafficIconEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setRouteTrafficIconEnabled 失败: $e');
      return false;
    }
  }

  Future<bool> updateSelectedRouteStyle({
    int? selectedColor,
    int? unselectedColor,
    double? selectedWidth,
    double? unselectedWidth,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (selectedColor != null) params['selectedColor'] = selectedColor;
      if (unselectedColor != null) params['unselectedColor'] = unselectedColor;
      if (selectedWidth != null) params['selectedWidth'] = selectedWidth;
      if (unselectedWidth != null) params['unselectedWidth'] = unselectedWidth;
      if (params.isEmpty) return false;
      final result = await _channel.invokeMethod<bool>('updateSelectedRouteStyle', params);
      return result ?? false;
    } catch (e) {
      debugPrint('❌ updateSelectedRouteStyle 失败: $e');
      return false;
    }
  }
}