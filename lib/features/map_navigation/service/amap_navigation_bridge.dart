import 'dart:async';
import 'package:flutter/services.dart';
import 'package:qintu/models/location/lat_lng.dart';
import 'package:qintu/utils/logger.dart';

/// 导航状态枚举
enum NavigationStatus {
  idle,           // 空闲
  navigating,     // 导航中
  paused,         // 已暂停
  arrived,        // 已到达
  offRoute,       // 偏航
  gpsWeak,        // GPS 信号弱
  error,          // 错误
}

/// 导航状态数据模型
class NavigationState {
  final NavigationStatus status;
  final double currentSpeed;        // 当前速度（km/h）
  final int remainingDistance;      // 剩余距离（米）
  final int remainingDuration;      // 剩余时间（秒）
  final String nextInstruction;     // 下一个转向指令
  final double? currentLat;         // 当前位置纬度
  final double? currentLng;         // 当前位置经度
  final String? roadName;           // 当前道路名称
  final String? naviText;           // 导航播报文字
  final int naviTextType;           // 导航播报类型（0=转向, 1=道路名, etc）

  NavigationState({
    required this.status,
    this.currentSpeed = 0,
    this.remainingDistance = 0,
    this.remainingDuration = 0,
    this.nextInstruction = '',
    this.currentLat,
    this.currentLng,
    this.roadName,
    this.naviText,
    this.naviTextType = 0,
  });

  factory NavigationState.fromMap(Map<dynamic, dynamic> map) {
    return NavigationState(
      status: _parseStatus(map['status']),
      currentSpeed: (map['currentSpeed'] ?? 0).toDouble(),
      remainingDistance: (map['remainingDistance'] ?? 0).toInt(),
      remainingDuration: (map['remainingDuration'] ?? 0).toInt(),
      nextInstruction: map['nextInstruction'] ?? '',
      currentLat: map['currentLat']?.toDouble(),
      currentLng: map['currentLng']?.toDouble(),
      roadName: map['roadName'],
      naviText: map['naviText'],
      naviTextType: (map['naviTextType'] ?? 0).toInt(),
    );
  }

  static NavigationStatus _parseStatus(dynamic status) {
    switch (status) {
      case 'navigating':
        return NavigationStatus.navigating;
      case 'paused':
        return NavigationStatus.paused;
      case 'arrived':
        return NavigationStatus.arrived;
      case 'off_route':
        return NavigationStatus.offRoute;
      case 'gps_weak':
        return NavigationStatus.gpsWeak;
      case 'error':
        return NavigationStatus.error;
      default:
        return NavigationStatus.idle;
    }
  }

  @override
  String toString() {
    return 'NavigationState('
        'status: $status, '
        'speed: $currentSpeed km/h, '
        'distance: $remainingDistance m, '
        'duration: $remainingDuration s, '
        'instruction: $nextInstruction, '
        'naviText: $naviText)';
  }
}

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
  static const _methodChannel = MethodChannel('com.qintu/amap_navigation');
  static const _eventChannel = EventChannel('com.qintu/amap_navigation/events');
  
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

  /// 开始导航
  ///
  /// [routePoints] 路线坐标点列表（至少 2 个点）
  /// [steps] 导航步骤详情（用于在导航页面显示转弯节点）
  /// [enableVoice] 是否开启语音播报（默认 true）
  /// [enableTts] 是否开启 TTS 详细播报（默认 true）
  static Future<bool> startNavigation({
    required List<LatLng> routePoints,
    List<Map<String, dynamic>>? steps,
    bool enableVoice = true,
    bool enableTts = true,
  }) async {
    if (routePoints.length < 2) {
      Logs.navigation.warning('⚠️ 路线点数不足，至少需要 2 个点');
      return false;
    }

    try {
      Logs.navigation.info('🗺️ 开始导航，路线点数: ${routePoints.length}');
      Logs.navigation.info('   语音播报: $enableVoice, TTS: $enableTts');

      final pointsData = routePoints
          .map((p) => {
                'latitude': p.latitude,
                'longitude': p.longitude,
              })
          .toList();

      final result = await _methodChannel.invokeMethod<bool>('startNavigation', {
        'routePoints': pointsData,
        'steps': steps,
        'enableVoice': enableVoice,
        'enableTts': enableTts,
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
  /// [originName] 起点名称
  /// [originLat] 起点纬度
  /// [originLng] 起点经度
  /// [destinationName] 终点名称
  /// [destinationLat] 终点纬度
  /// [destinationLng] 终点经度
  /// [enableVoice] 是否开启语音播报
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
