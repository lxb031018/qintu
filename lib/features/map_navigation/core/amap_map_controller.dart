import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../models/location/lat_lng.dart';
import '../../../utils/logger.dart';
import 'package:qintu/features/map_navigation/models/map_overlay_models.dart';

/// ============================================
/// 地图控制器
///
/// 封装与原生 Android 高德地图的交互（Platform Channel）
///
/// 方法分类：
/// - 定位：startLocation, moveToMyLocation, getCurrentLocation, stopLocation
/// - 地图操作：moveCamera, setRouteMarkers, clearRouteMarkers
/// - 路线绘制：addPolyline, showRoutes, selectRoute, clearRoutes
/// - POI 标注：addPoiMarkers, showPoiOverlay, clearPoiMarkers
///
/// 注意：此类属于 core 层（平台 API 封装）
/// ============================================
class AmapMapController {
  static const _channel = MethodChannel('com.qintu/amap_map_control');
  static const _eventChannel = EventChannel('com.qintu/amap_location_event');

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

  /// 地理编码：地址转坐标（使用 Android 原生 API）
  Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('geocodeAddress', {
        'address': address,
      });
      if (result != null) {
        return {
          'latitude': result['latitude'] as double,
          'longitude': result['longitude'] as double,
          'address': result['address'] as String,
        };
      }
      return null;
    } catch (e) {
      debugPrint('❌ 地理编码失败: $e');
      return null;
    }
  }

  /// 使用高德 AMapUtils.calculateLineDistance 计算两点间距离（米）
  /// [fromLat] 起点纬度
  /// [fromLng] 起点经度
  /// [toLat] 终点纬度
  /// [toLng] 终点经度
  Future<int?> calculateDistance({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final result = await _channel.invokeMethod<int>('calculateDistance', {
        'fromLat': fromLat,
        'fromLng': fromLng,
        'toLat': toLat,
        'toLng': toLng,
      });
      return result;
    } catch (e) {
      debugPrint('❌ 计算距离失败: $e');
      return null;
    }
  }

  /// 停止定位
  Future<void> stopLocation() async {
    await _channel.invokeMethod('stopLocation');
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

  /// 绘制路线
  Future<void> addPolyline(List<LatLng> points, {int color = 0xFF1890FF, double width = 8.0}) async {
    await _channel.invokeMethod('addPolyline', {
      'points': points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'color': color,
      'width': width,
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

  /// 设置单条路线的透明度
  ///
  /// [index] 路线索引
  /// [transparency] 透明度（0.0 完全透明 ~ 1.0 完全不透明）
  Future<bool> setRouteTransparency(int index, double transparency) async {
    try {
      final result = await _channel.invokeMethod<bool>('setRouteTransparency', {
        'index': index,
        'transparency': transparency,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('❌ 设置路线透明度失败: $e');
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

  /// 添加 POI 标注点
  Future<void> addPoiMarkers(List<PoiMarkerData> pois) async {
    if (pois.isEmpty) return;

    final markerData = pois.map((poi) => {
      'id': poi.id,
      'name': poi.name,
      'address': poi.address ?? '',
      'lat': poi.position.latitude,
      'lng': poi.position.longitude,
      'snippet': poi.snippet ?? '',
    }).toList();

    await _channel.invokeMethod('addPoiMarkers', {
      'markers': markerData,
    });
  }

  /// 添加单个 POI 标注点
  Future<void> addPoiMarker(PoiMarkerData poi) async {
    await addPoiMarkers([poi]);
  }

  /// 清除所有 POI 标注点
  Future<void> clearPoiMarkers() async {
    await _channel.invokeMethod('clearPoiMarkers');
  }

  /// 显示 POI 标注层
  ///
  /// [pois] POI 数据列表
  /// [selectedIndex] 默认选中的索引
  /// 自动调整视野以显示所有 POI
  Future<void> showPoiOverlay(PoiOverlay overlay, {int selectedIndex = -1}) async {
    if (overlay.pois.isEmpty) return;

    // 存储当前选中索引
    if (selectedIndex >= 0) {
      overlay.selectPoi(selectedIndex);
    }

    // 添加标注点到地图
    await addPoiMarkers(overlay.pois);

    // 移动视野到第一个 POI
    final firstPos = overlay.firstPosition;
    if (firstPos != null) {
      await moveCamera(lat: firstPos.latitude, lng: firstPos.longitude, zoom: 15);
    }
  }

  /// 点击 POI 标注点的回调
  void onPoiMarkerClick(Function(String markerId) callback) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPoiMarkerClick') {
        final markerId = call.arguments['id'] as String?;
        if (markerId != null) {
          callback(markerId);
        }
      }
    });
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
}