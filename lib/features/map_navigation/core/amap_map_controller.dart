import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/platform_channels.dart';
import '../../../models/location/lat_lng.dart';
import '../../../utils/logger.dart';

/// ============================================
/// 地图控制器
///
/// 封装与原生 Android 高德地图的交互（Platform Channel）
///
/// 方法分类：
/// - 定位：startLocation, moveToMyLocation, getCurrentLocation
/// - 地图操作：moveCamera, setRouteMarkers, clearRouteMarkers
/// - 路线绘制：showRoutes, selectRoute, clearRoutes
///
/// 注意：此类属于 core 层（平台 API 封装）
/// ============================================
class AmapMapController {
  static const _channel = MethodChannel(PlatformChannels.mapControl);
  static const _eventChannel = EventChannel(PlatformChannels.mapLocationEvent);

  StreamSubscription? _locationSubscription;
  bool _hasMovedToFirstLocation = false;

  /// 启动高德原生定位 (蓝点 + 箭头)
  ///
  /// 如果 [autoMoveToFirstLocation] 为 true（默认），首次定位成功后会
  /// 自动将相机移动到用户当前位置
  Future<void> startLocation({bool autoMoveToFirstLocation = true}) async {
    if (autoMoveToFirstLocation && !_hasMovedToFirstLocation) {
      _listenFirstLocationEvent();
    }
    await _channel.invokeMethod('startLocation');
  }

  /// 监听首次定位事件，自动移动相机到用户位置
  void _listenFirstLocationEvent() {
    _locationSubscription?.cancel();
    _locationSubscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event['type'] == 'firstLocation' && !_hasMovedToFirstLocation) {
          _hasMovedToFirstLocation = true;
          final lat = event['latitude'] as double;
          final lng = event['longitude'] as double;
          debugPrint('🚀 首次定位成功，自动移动相机到: $lat, $lng');
          moveCamera(lat: lat, lng: lng, zoom: 17);
        }
      },
      onError: (error) {
        debugPrint('❌ 首次定位事件监听失败: $error');
      },
    );
  }

  /// 释放资源
  void dispose() {
    _locationSubscription?.cancel();
  }

  /// 移动到我的位置（如果有定位结果则立即移动，否则触发单次定位）
  Future<void> moveToMyLocation() async {
    final result = await _channel.invokeMethod<bool>('moveToMyLocation');
    if (result == false) {
      // 正在定位中，等待下一次位置更新
    }
  }

  /// 获取当前位置坐标
  /// 返回包含 latitude、longitude、accuracy、timestamp、city 的 Map
  /// 如果有缓存位置直接返回，否则发起单次定位
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getCurrentLocation');
      if (result != null) {
        return {
          'latitude': result['latitude'] as double,
          'longitude': result['longitude'] as double,
          'accuracy': result['accuracy'] as double,
          'timestamp': result['timestamp'] as int,
          'city': result['city'] as String? ?? '',
        };
      }
      return null;
    } catch (e) {
      Logs.location.error('getCurrentLocation: Platform Channel异常', stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 移动相机
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

  /// 显示多条路线
  ///
  /// [routes] 路线列表，每条路线是 LatLng 点列表
  /// [selectIndex] 默认选中的路线索引
  /// [colors] 每条路线的颜色（可选，默认使用蓝色）
  /// [widths] 每条路线的宽度（可选，默认12）
  Future<int?> showRoutes(
    List<List<LatLng>> routes, {
    int selectIndex = 0,
    List<int>? colors,
    List<double>? widths,
    List<bool>? dashedFlags,
    List<int>? routeIds,
  }) async {
    try {
      final routesData = routes.map((route) => route.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList()).toList();

      debugPrint('🗺️ [Flutter] showRoutes 调用:');
      debugPrint('   - 路线数量: ${routesData.length}');
      debugPrint('   - 选中索引: $selectIndex');
      for (int i = 0; i < routesData.length; i++) {
        debugPrint('   - 路线[$i]: ${routesData[i].length} 个点');
        if (routesData[i].isNotEmpty) {
          debugPrint('      起点: ${routesData[i].first}');
          debugPrint('      终点: ${routesData[i].last}');
        }
      }

      final params = <String, dynamic>{
        'routes': routesData,
        'selectIndex': selectIndex,
      };

      if (colors != null) {
        params['colors'] = colors;
        debugPrint('   - 自定义颜色: $colors');
      }
      if (widths != null) {
        params['widths'] = widths;
        debugPrint('   - 自定义宽度: $widths');
      }
      if (dashedFlags != null) {
        params['dashedFlags'] = dashedFlags;
        debugPrint('   - 虚线标记: $dashedFlags');
      }
      if (routeIds != null && routeIds.isNotEmpty) {
        params['routeIds'] = routeIds;
        debugPrint('   - RouteOverLay IDs: $routeIds');
      }

      final result = await _channel.invokeMethod<int>('showRoutes', params);
      debugPrint('🗺️ [Flutter] showRoutes 结果: $result 条路线');
      return result;
    } catch (e) {
      debugPrint('❌ [Flutter] 显示路线失败: $e');
      return null;
    }
  }

  /// 选择高亮某条路线
  ///
  /// [index] 路线索引
  /// [selectedColor] 选中路线颜色
  /// [unselectedColor] 未选中路线颜色
  Future<bool> selectRoute(
    int index, {
    int selectedColor = 0xFFFF4D4F,
    int unselectedColor = 0x401890FF,
  }) async {
    try {
      debugPrint('🗺️ [Flutter] selectRoute 调用: index=$index');

      final result = await _channel.invokeMethod<bool>('selectRoute', {
        'index': index,
        'selectedColor': selectedColor,
        'unselectedColor': unselectedColor,
      });

      debugPrint('🗺️ [Flutter] selectRoute 结果: $result');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 选择路线失败: $e');
      return false;
    }
  }

  /// 进入导航模式：仅保留选中路线（RouteOverLay + 方向箭头）
  /// 清除所有预览阶段的 Polyline
  Future<bool> enterNavigationMode(int routeId) async {
    try {
      final result = await _channel.invokeMethod<bool>('enterNavigationMode', {
        'routeId': routeId,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ enterNavigationMode 失败: $e');
      return false;
    }
  }

  /// 清除所有路线
  Future<void> clearRoutes() async {
    await _channel.invokeMethod('clearRoutes');
  }

  /// 设置路线起点/终点标记
  ///
  /// [startLat] 起点纬度
  /// [startLng] 起点经度
  /// [endLat] 终点纬度
  /// [endLng] 终点经度
  /// [startLabel] 起点标签（可选，默认"起点"）
  /// [endLabel] 终点标签（可选，默认"终点"）
  Future<bool> setRouteMarkers({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String? startLabel,
    String? endLabel,
  }) async {
    try {
      debugPrint('🗺️ [Flutter] setRouteMarkers: start=($startLat,$startLng), end=($endLat,$endLng)');

      final result = await _channel.invokeMethod<bool>('setRouteMarkers', {
        'startLat': startLat,
        'startLng': startLng,
        'endLat': endLat,
        'endLng': endLng,
        'startLabel': startLabel ?? '起点',
        'endLabel': endLabel ?? '终点',
      });

      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 设置路线标记失败: $e');
      return false;
    }
  }

  /// 清除路线标记（起点/终点）
  Future<bool> clearRouteMarkers() async {
    try {
      final result = await _channel.invokeMethod<bool>('clearRouteMarkers');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 清除路线标记失败: $e');
      return false;
    }
  }

  /// 显示单条路线标记（起点绿色/终点红色，可单独显示）
  ///
  /// [lat] 纬度
  /// [lng] 经度
  /// [isStart] 是否为起点（true=绿色起点，false=红色终点）
  /// [label] 标签文字
  Future<bool> showSingleMarker({
    required double lat,
    required double lng,
    required bool isStart,
    String? label,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('showSingleMarker', {
        'lat': lat,
        'lng': lng,
        'isStart': isStart,
        'label': label ?? (isStart ? '起点' : '终点'),
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 显示单条路线标记失败: $e');
      return false;
    }
  }

  /// 清除单条路线标记
  ///
  /// [isStart] 是否为起点（true=清除起点，false=清除终点）
  Future<bool> clearSingleMarker(bool isStart) async {
    try {
      final result = await _channel.invokeMethod<bool>('clearSingleMarker', {
        'isStart': isStart,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ [Flutter] 清除单条路线标记失败: $e');
      return false;
    }
  }

  /// 更新车辆标记位置（无 View 导航时使用）
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

  /// 设置跟随模式（导航时相机跟随车辆）
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

  /// 清除车辆标记
  Future<bool> clearCarMarker() async {
    try {
      final result = await _channel.invokeMethod<bool>('clearCarMarker');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ 清除车辆标记失败: $e');
      return false;
    }
  }

  /// 显示/隐藏定位蓝点
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

  /// 锁定/解锁车辆跟随（导航时使用）
  /// [locked] true=锁定（相机跟随车辆方向旋转），false=解锁（允许用户自由操作地图）
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

  /// 显示/隐藏车载标记
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

  // ==================== 相机增强 ====================

  /// 动画移动相机（支持 bearing/tilt/时长）
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

  /// 放大
  Future<void> zoomIn() => _channel.invokeMethod('zoomIn');

  /// 缩小
  Future<void> zoomOut() => _channel.invokeMethod('zoomOut');

  /// 缩放到指定级别
  Future<void> zoomTo(double level, {int duration = 0}) =>
      _channel.invokeMethod('zoomTo', {'level': level, 'duration': duration});

  // ==================== 地图图层 ====================

  /// 设置地图类型
  /// 1=普通, 2=卫星, 3=夜景, 4=导航, 5=导航夜景, 6=公交
  Future<bool> setMapType(int type) async {
    try {
      final result = await _channel.invokeMethod<bool>('setMapType', {'type': type});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setMapType 失败: $e');
      return false;
    }
  }

  /// 显示/隐藏实时路况
  Future<bool> setTrafficEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setTrafficEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setTrafficEnabled 失败: $e');
      return false;
    }
  }

  /// 显示/隐藏 3D 建筑
  Future<bool> setBuildingsEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setBuildingsEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setBuildingsEnabled 失败: $e');
      return false;
    }
  }

  /// 显示/隐藏室内地图
  Future<bool> showIndoorMap(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('showIndoorMap', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ showIndoorMap 失败: $e');
      return false;
    }
  }

  // ==================== 手势控制 ====================

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

  // ==================== 路线渲染样式 ====================

  /// 启用/禁用路线拥堵颜色（TMC）
  Future<bool> setRouteTmcEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setRouteTmcEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setRouteTmcEnabled 失败: $e');
      return false;
    }
  }

  /// 启用/禁用路线交通事件图标
  Future<bool> setRouteTrafficIconEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setRouteTrafficIconEnabled', {'enabled': enabled});
      return result ?? false;
    } catch (e) {
      debugPrint('❌ setRouteTrafficIconEnabled 失败: $e');
      return false;
    }
  }

  /// 更新路线选中/非选中样式
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