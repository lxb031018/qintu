import 'dart:async';
import 'package:flutter/services.dart';
import 'package:qintu/core/constants/platform_channels.dart';
import 'package:qintu/utils/logger.dart';
import '../models/navigation_models.dart';
import '../models/amap_routing_models.dart';

/// 高德导航桥接层
///
/// 职责：
/// 1. 封装原生层导航能力（Android/iOS）
/// 2. 提供 Flutter 与原生导航的通信接口
/// 3. 监听导航状态变化
///
/// 注意：路线规划已迁移至 AmapRouteSearchBridge，
/// 此桥接层仅负责导航生命周期（开始/暂停/恢复/停止导航）和状态监听
///
/// 使用方式：
/// ```dart
/// // 开始导航
/// await AmapNavigationBridge.startNavigation(enableVoice: true);
///
/// // 监听状态
/// AmapNavigationBridge.navigationStateStream.listen((state) {
///   print('导航状态：$state');
/// });
///
/// // 停止导航
/// await AmapNavigationBridge.stopNavigation();
/// ```

class AmapNavigationBridge {
  static const _methodChannel = MethodChannel(PlatformChannels.navigation);
  static const _eventChannel = EventChannel(PlatformChannels.navigationEvents);

  static Stream<NavigationState>? _stateStream;
  static StreamController<NavigationState>? _stateController;

  static Future<bool> selectRouteId(int routeId) async {
    try {
      await _methodChannel.invokeMethod('selectRouteId', {'routeId': routeId});
      return true;
    } catch (e) {
      Logs.navigation.error('❌ 选择路线失败：$e');
      return false;
    }
  }

  static Future<List<int>> getAllRouteIds() async {
    try {
      final result = await _methodChannel.invokeMethod<List<dynamic>>('getAllRouteIds');
      return result?.map((e) => (e as num).toInt()).toList() ?? [];
    } catch (e) {
      Logs.navigation.error('❌ getAllRouteIds failed: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getRouteInfoList() async {
    try {
      final result = await _methodChannel.invokeMethod<List<dynamic>>('getRouteInfoList');
      return result?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    } catch (e) {
      Logs.navigation.error('❌ getRouteInfoList failed: $e');
      return [];
    }
  }

  /// 使用 AMapNavi 计算路线（驾车/步行/骑行）
  ///
  /// 返回路线列表，每条路线包含 routeId（用于 RouteOverLay 渲染）
  static Future<List<RouteOption>?> calculateRoute({
    required String routeType,
    required LatLng origin,
    required LatLng destination,
    int strategy = 10,
  }) async {
    try {
      Logs.navigation.info('🗺️ calculateRoute via AMapNavi: $routeType, ($origin → $destination), strategy=$strategy');

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('calculateRoute', {
        'routeType': routeType,
        'fromLat': origin.latitude,
        'fromLng': origin.longitude,
        'toLat': destination.latitude,
        'toLng': destination.longitude,
        'strategy': strategy,
      });

      if (result == null) {
        Logs.navigation.warning('⚠️ calculateRoute via AMapNavi returned null');
        return null;
      }

      final routes = result['routes'] as List<dynamic>?;
      final routeIds = result['routeIds'] as List<dynamic>?;

      if (routes == null || routes.isEmpty) {
        Logs.navigation.warning('⚠️ calculateRoute via AMapNavi returned empty routes');
        return [];
      }

      return routes.asMap().entries.map((entry) {
        final map = entry.value as Map<dynamic, dynamic>;
        final index = entry.key;
        final pointsList = map['points'] as List<dynamic>? ?? [];
        final points = pointsList.map((p) {
          final pm = p as Map<dynamic, dynamic>;
          return LatLng((pm['lat'] as num).toDouble(), (pm['lng'] as num).toDouble());
        }).toList();

        return RouteOption(
          routeId: routeIds != null && index < routeIds.length
              ? (routeIds[index] as num).toInt()
              : -1,
          distance: (map['distance'] as num?)?.toDouble() ?? 0,
          duration: (map['duration'] as num?)?.toDouble() ?? 0,
          strategy: map['strategy']?.toString() ?? '',
          tolls: (map['tolls'] as num?)?.toDouble() ?? 0,
          points: points,
          routeType: _parseRouteType(routeType),
          trafficLights: (map['trafficLights'] as num?)?.toInt() ?? 0,
          strategyId: strategy,
        );
      }).toList();
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ calculateRoute via AMapNavi failed: ${e.message}');
      return null;
    } catch (e) {
      Logs.navigation.error('❌ calculateRoute via AMapNavi unknown error: $e');
      return null;
    }
  }

  static RouteType _parseRouteType(String type) {
    switch (type) {
      case 'driving':
        return RouteType.driving;
      case 'walking':
        return RouteType.walking;
      case 'riding':
        return RouteType.riding;
      case 'elebike':
        return RouteType.eleBike;
      default:
        return RouteType.driving;
    }
  }

  static Future<bool> startNavigation({
    bool isEmulator = false,
    bool enableVoice = true,
  }) async {
    try {
      Logs.navigation.info('🗺️ 开始无 View 导航，isEmulator=$isEmulator');

      final result = await _methodChannel.invokeMethod<bool>('startNavigation', {
        'isEmulator': isEmulator,
        'enableVoice': enableVoice,
      });

      Logs.navigation.info('📡 invokeMethod startNavigation 返回: $result');

      if (result == true) {
        Logs.navigation.info('✅ 导航已开始');
      } else {
        Logs.navigation.warning('❌ 导航启动失败');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ 开始导航异常：${e.message}');
      return false;
    } catch (e) {
      Logs.navigation.error('❌ 开始导航未知错误：$e');
      return false;
    }
  }

  static Future<bool> stopNavigation() async {
    try {
      Logs.navigation.info('🛑 停止导航');
      final result = await _methodChannel.invokeMethod<bool>('stopNavigation');
      if (result == true) {
        Logs.navigation.info('✅ 导航已停止');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ 停止导航异常：${e.message}');
      return false;
    } catch (e) {
      Logs.navigation.error('❌ 停止导航未知错误：$e');
      return false;
    }
  }

  static Future<bool> pauseNavigation() async {
    try {
      Logs.navigation.info('⏸️ 暂停导航');
      final result = await _methodChannel.invokeMethod<bool>('pauseNavigation');
      return result ?? false;
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ 暂停导航异常：${e.message}');
      return false;
    } catch (e) {
      Logs.navigation.error('❌ 暂停导航未知错误：$e');
      return false;
    }
  }

  static Future<bool> resumeNavigation() async {
    try {
      Logs.navigation.info('▶️ 恢复导航');
      final result = await _methodChannel.invokeMethod<bool>('resumeNavigation');
      return result ?? false;
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ 恢复导航异常：${e.message}');
      return false;
    } catch (e) {
      Logs.navigation.error('❌ 恢复导航未知错误：$e');
      return false;
    }
  }

  static Stream<NavigationState> get navigationStateStream {
    if (_stateStream != null) {
      return _stateStream!;
    }

    _stateController = StreamController<NavigationState>.broadcast(
      onCancel: () {
        _stateController = null;
        _stateStream = null;
      },
    );

    _stateStream = _eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        final state = NavigationState.fromMap(event);
        Logs.navigation.info('📡 导航状态更新：$state');
        _stateController?.add(state);
        return state;
      }
      return NavigationState(status: NavigationStatus.idle);
    }).handleError((error) {
      Logs.navigation.error('❌ 导航状态流错误：$error');
      _stateController?.addError(error);
    });

    return _stateStream!;
  }
}