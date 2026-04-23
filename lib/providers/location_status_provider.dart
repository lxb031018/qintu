import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qintu/utils/logger.dart';

/// ============================================
/// 定位状态枚举
///
/// 被多个组件共享
/// ============================================
enum LocationStatus {
  unknown,  // 未知状态（初始状态）
  disabled, // 定位服务未开启（GPS 关闭）
  enabled,  // 定位已开启
  denied,   // 定位权限被拒绝
}

/// ============================================
/// 定位状态 Notifier
///
/// 职责：
/// - 检查和更新定位状态
/// - 请求定位权限
/// - 跳转系统设置
///
/// 使用方式：
/// ```dart
/// // 读取状态
/// final status = ref.watch(locationProvider);
///
/// // 更新状态
/// ref.read(locationProvider.notifier).checkStatus();
///
/// // 请求权限
/// ref.read(locationProvider.notifier).requestPermission();
/// ```
/// ============================================
class LocationNotifier extends Notifier<LocationStatus> {
  @override
  LocationStatus build() => LocationStatus.unknown;

  /// 检查定位状态
  Future<void> checkStatus() async {
    try {
      // 检查定位服务是否启用（系统 GPS 开关）
      final serviceEnabled = await Permission.locationWhenInUse.serviceStatus.isEnabled;
      // 检查定位权限状态（用户授权状态）
      final permissionStatus = await Permission.locationWhenInUse.status;

      Logs.map.info('📍 定位状态检查: serviceEnabled=$serviceEnabled, permission=$permissionStatus');

      if (!serviceEnabled) {
        state = LocationStatus.disabled;
      } else if (permissionStatus.isDenied) {
        state = LocationStatus.denied;
      } else if (permissionStatus.isGranted) {
        state = LocationStatus.enabled;
      } else {
        state = LocationStatus.unknown;
      }

      Logs.map.info('📍 定位状态已更新: $state');
    } catch (e) {
      Logs.map.warning('❌ 检查定位状态失败: $e');
      state = LocationStatus.unknown;
    }
  }

  /// 请求定位权限
  Future<void> requestPermission() async {
    try {
      // 检查定位服务是否启用
      final serviceEnabled = await Permission.locationWhenInUse.serviceStatus.isEnabled;

      if (!serviceEnabled) {
        // 定位服务未开启，跳转到系统定位设置页面
        await _openSystemSettings();
      } else if (state == LocationStatus.enabled) {
        // 定位已开启，用户想调整设置，跳转到系统定位设置页面
        await _openSystemSettings();
      } else {
        // 定位服务已开启但权限未授予，请求权限
        final result = await Permission.locationWhenInUse.request();
        Logs.map.info('📍 定位权限请求结果: $result');
      }

      // 等待用户返回后重新检查状态
      await Future.delayed(const Duration(seconds: 1));
      await checkStatus();
    } catch (e) {
      Logs.map.warning('❌ 请求定位权限失败: $e');
    }
  }

  /// 打开系统定位设置页面
  Future<void> _openSystemSettings() async {
    try {
      const platform = MethodChannel('qintu/location_settings');
      await platform.invokeMethod('openLocationSettings');
    } on PlatformException catch (e) {
      Logs.map.warning('❌ 跳转系统定位设置页面失败: ${e.message}');
      // 降级方案：跳转到应用设置页面
      await openAppSettings();
    }
  }
}

/// ============================================
/// 定位状态 Provider
///
/// 供多个组件共享使用
/// ============================================
final locationProvider = NotifierProvider<LocationNotifier, LocationStatus>(
  LocationNotifier.new,
);
