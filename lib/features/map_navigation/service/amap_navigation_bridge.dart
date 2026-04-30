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
/// 使用方式：
/// ```dart
/// // 初始化
/// await AmapNavigationBridge.initialize();
/// 
/// // 开始导航
/// await AmapNavigationBridge.startNavigation(
///   routePoints: routePoints,
///   enableVoice: true,
/// );
/// 
/// // 监听状态
/// AmapNavigationBridge.navigationStateStream.listen((state) {
///   print('导航状态: $state');
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

  /// 初始化导航 SDK
  /// 
  /// 在应用启动时调用一次
  static Future<bool> initialize() async {
    try {
      Logs.navigation.info('🔧 初始化高德导航 SDK');
      final result = await _methodChannel.invokeMethod<bool>('initialize');
      if (result == true) {
        Logs.navigation.info('✅ 高德导航 SDK 初始化成功');
      } else {
        Logs.navigation.warning('❌ 高德导航 SDK 初始化失败');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ 初始化高德导航 SDK 异常: ${e.message}');
      return false;
    } catch (e) {
      Logs.navigation.error('❌ 初始化高德导航 SDK 未知错误: $e');
      return false;
    }
  }

  /// 通过原生导航 SDK 计算路线（替代 Web API）
  ///
  /// [type] 出行方式（driving/walking/riding）
  /// [origin] 起点坐标
  /// [destination] 终点坐标
  /// [strategy] 驾车策略: 0=高速优先, 1=避免收费, 2=距离最短
  /// [multiRoute] 是否请求多路径（默认 true）
  static Future<List<RouteOption>> calculateRoute({
    required RouteType type,
    required LatLng origin,
    required LatLng destination,
    int strategy = 0,
    bool multiRoute = true,
  }) async {
    if (type == RouteType.transit) {
      throw const RoutingException('公交路线暂不支持原生 SDK 算路');
    }

    try {
      Logs.navigation.info('🗺️ SDK 算路: $type, ($origin → $destination), strategy=$strategy');

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'calculateRoute',
        {
          'routeType': _routeTypeToString(type),
          'fromLat': origin.latitude,
          'fromLng': origin.longitude,
          'toLat': destination.latitude,
          'toLng': destination.longitude,
          'strategy': strategy,
          'multiRoute': multiRoute,
        },
      );

      if (result == null) {
        Logs.navigation.warning('⚠️ SDK 算路返回为空');
        return [];
      }

      final routesList = result['routes'] as List<dynamic>? ?? [];
      Logs.navigation.info('✅ SDK 算路成功: ${routesList.length} 条路线');

      return routesList
          .map((r) => _parseRouteResponse(r as Map<dynamic, dynamic>, type))
          .toList();
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ SDK 算路失败: ${e.message}');
      throw RoutingException(e.message ?? '算路失败');
    } catch (e) {
      Logs.navigation.error('❌ SDK 算路异常: $e');
      throw RoutingException('算路异常: $e');
    }
  }

  static String _routeTypeToString(RouteType type) {
    switch (type) {
      case RouteType.driving:
        return 'driving';
      case RouteType.walking:
        return 'walking';
      case RouteType.riding:
        return 'riding';
      case RouteType.transit:
        return 'transit';
    }
  }

  static RouteOption _parseRouteResponse(Map<dynamic, dynamic> map, RouteType type) {
    final pointsList = map['points'] as List<dynamic>? ?? [];
    final points = pointsList.map((p) {
      final pm = p as Map<dynamic, dynamic>;
      return LatLng(
        (pm['lat'] as num).toDouble(),
        (pm['lng'] as num).toDouble(),
      );
    }).toList();

    final stepsList = map['steps'] as List<dynamic>? ?? [];

    return RouteOption(
      routeId: (map['routeId'] as num?)?.toInt() ?? -1,
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      duration: (map['duration'] as num?)?.toDouble() ?? 0,
      strategy: map['strategy']?.toString() ?? '',
      tolls: (map['tolls'] as num?)?.toDouble() ?? 0,
      points: points,
      routeType: type,
      driveSteps: type == RouteType.driving
          ? stepsList
              .map((s) => _parseDriveStep(s as Map<dynamic, dynamic>))
              .toList()
          : null,
      walkSteps: type == RouteType.walking
          ? stepsList
              .map((s) => _parseWalkStep(s as Map<dynamic, dynamic>))
              .toList()
          : null,
      rideSteps: type == RouteType.riding
          ? stepsList
              .map((s) => _parseWalkStep(s as Map<dynamic, dynamic>))
              .toList()
          : null,
    );
  }

  static DriveStep _parseDriveStep(Map<dynamic, dynamic> map) {
    return DriveStep(
      instruction: map['instruction']?.toString() ?? '',
      action: map['action']?.toString() ?? '',
      road: map['road']?.toString() ?? '',
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      duration: (map['duration'] as num?)?.toDouble() ?? 0,
      points: const [],
      driveAction: DriveStep.parseAction(map['action']?.toString()),
      tmcStatus: map['tmcStatus']?.toString(),
      lat: (map['lat'] as num?)?.toDouble() ?? 0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0,
    );
  }

  static WalkStep _parseWalkStep(Map<dynamic, dynamic> map) {
    return WalkStep(
      instruction: map['instruction']?.toString() ?? '',
      action: map['action']?.toString() ?? '',
      road: map['road']?.toString() ?? '',
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      duration: (map['duration'] as num?)?.toDouble() ?? 0,
      points: const [],
      walkAction: WalkStep.parseAction(map['action']?.toString()),
      lat: (map['lat'] as num?)?.toDouble() ?? 0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0,
    );
  }

  /// 选中路线（多路径时选择导航路线）
  static Future<bool> selectRouteId(int routeId) async {
    try {
      await _methodChannel.invokeMethod('selectRouteId', {'routeId': routeId});
      return true;
    } catch (e) {
      Logs.navigation.error('❌ 选择路线失败: $e');
      return false;
    }
  }

  /// 开始无 View 导航（同地图，不跳转页面）
  ///
  /// [isEmulator] 是否为模拟导航
  /// [enableVoice] 是否开启语音播报
  static Future<bool> startNavigation({
    bool isEmulator = false,
    bool enableVoice = true,
  }) async {
    try {
      Logs.navigation.info('🗺️ 开始无View导航, isEmulator=$isEmulator');

      final result = await _methodChannel.invokeMethod<bool>('startNavigation', {
        'isEmulator': isEmulator,
        'enableVoice': enableVoice,
      });

      if (result == true) {
        Logs.navigation.info('✅ 导航已开始');
      } else {
        Logs.navigation.warning('❌ 导航启动失败');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ 开始导航异常: ${e.message}');
      return false;
    } catch (e) {
      Logs.navigation.error('❌ 开始导航未知错误: $e');
      return false;
    }
  }

  /// 直接开始导航（跳过路线规划页面，直接进入导航）
  /// 
  /// 内部调用 calculateRoute + startNavigation
  static Future<Map<dynamic, dynamic>> startDirectNavigation({
    required String originName,
    required double originLat,
    required double originLng,
    required String destinationName,
    required double destinationLat,
    required double destinationLng,
    bool enableVoice = true,
  }) async {
    try {
      Logs.navigation.info('🗺️ 直接开始导航: $originName → $destinationName');

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('startDirectNavigation', {
        'originName': originName,
        'originLat': originLat,
        'originLng': originLng,
        'destinationName': destinationName,
        'destinationLat': destinationLat,
        'destinationLng': destinationLng,
        'enableVoice': enableVoice,
      });

      if (result != null) {
        Logs.navigation.info('✅ 导航组件已启动');
        return result;
      }
      
      return {'status': 'error', 'message': '返回结果为空'};
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ 开始导航异常: ${e.message}');
      return {'status': 'error', 'message': e.message};
    } catch (e) {
      Logs.navigation.error('❌ 开始导航未知错误: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// 启动路线规划页面（用户可以选择路线后开始导航）
  /// 
  /// 参数同上
  static Future<Map<dynamic, dynamic>> startRoutePlanning({
    required String originName,
    required double originLat,
    required double originLng,
    required String destinationName,
    required double destinationLat,
    required double destinationLng,
    bool enableVoice = true,
  }) async {
    try {
      Logs.navigation.info('🗺️ 启动路线规划页面: $originName → $destinationName');

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('startNavigation', {
        'originName': originName,
        'originLat': originLat,
        'originLng': originLng,
        'destinationName': destinationName,
        'destinationLat': destinationLat,
        'destinationLng': destinationLng,
        'enableVoice': enableVoice,
        'pageType': 1, // AmapPageType.ROUTE
      });

      if (result != null) {
        Logs.navigation.info('✅ 路线规划页面已启动');
        return result;
      }
      
      return {'status': 'error', 'message': '返回结果为空'};
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ 启动路线规划异常: ${e.message}');
      return {'status': 'error', 'message': e.message};
    } catch (e) {
      Logs.navigation.error('❌ 启动路线规划未知错误: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// 停止导航
  static Future<bool> stopNavigation() async {
    try {
      Logs.navigation.info('🛑 停止导航');
      final result = await _methodChannel.invokeMethod<bool>('stopNavigation');
      if (result == true) {
        Logs.navigation.info('✅ 导航已停止');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ 停止导航异常: ${e.message}');
      return false;
    } catch (e) {
      Logs.navigation.error('❌ 停止导航未知错误: $e');
      return false;
    }
  }

  /// 暂停/继续导航
  static Future<bool> togglePause() async {
    try {
      Logs.navigation.info('⏸️ 切换导航暂停/继续状态');
      final result = await _methodChannel.invokeMethod<bool>('togglePause');
      return result ?? false;
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ 切换暂停状态异常: ${e.message}');
      return false;
    } catch (e) {
      Logs.navigation.error('❌ 切换暂停状态未知错误: $e');
      return false;
    }
  }

  /// 监听导航状态
  /// 
  /// 返回一个 Stream，持续接收导航状态更新
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
        Logs.navigation.info('📡 导航状态更新: $state');
        _stateController?.add(state);
        return state;
      }
      return NavigationState(status: NavigationStatus.idle);
    }).handleError((error) {
      Logs.navigation.error('❌ 导航状态流错误: $error');
      _stateController?.addError(error);
    });

    return _stateStream!;
  }

  /// 设置导航监听
  /// 
  /// [onStateChange] 状态变化回调
  static void setNavigationListener(Function(NavigationState state) onStateChange) {
    navigationStateStream.listen(
      (state) => onStateChange(state),
      onError: (error) => Logs.navigation.error('导航状态错误: $error'),
    );
  }

  /// 释放资源
  static Future<void> dispose() async {
    await stopNavigation();
    await _stateController?.close();
    _stateStream = null;
    _stateController = null;
    Logs.navigation.info('🧹 导航桥接层资源已释放');
  }
}
