import 'dart:math' as math;
import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart';
import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../config/amap_config.dart';

/// 高德地图服务 - 负责地图初始化、定位、路线规划等功能

class AmapService {
  static final AmapService _instance = AmapService._internal();
  factory AmapService() => _instance;
  AmapService._internal();

  static AmapService get instance => _instance;

  bool _isInitialized = false;

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化高德地图 SDK（设置 API Key）
  ///
  /// [context] BuildContext 用于资源适配
  ///
  /// 返回是否初始化成功
  bool initialize(BuildContext context) {
    if (_isInitialized) {
      return true;
    }

    try {
      final apiKey = AmapConfig.androidApiKey;
      if (apiKey.isEmpty) {
        Logs.map.warning('未配置高德地图 API Key');
        return false;
      }

      // 🌟 在 init() 之前立即调用隐私合规（必须在任何地图操作之前）
      const privacyStatement = AMapPrivacyStatement(
        hasShow: true,
        hasAgree: true,
      );
      AMapInitializer.updatePrivacyAgree(privacyStatement);
      Logs.map.info('✅ 高德地图隐私合规已设置');

      Logs.map.info('开始设置高德地图 API Key...');
      final amapApiKey = AMapApiKey(androidKey: apiKey);
      AMapInitializer.init(context, apiKey: amapApiKey);

      _isInitialized = true;
      Logs.map.info('✅ 高德地图 SDK 初始化成功');
      return true;
    } catch (e) {
      Logs.map.warning('高德地图 SDK 初始化失败: $e');
      return false;
    }
  }

  /// 检查权限
  /// 
  /// 注意：高德地图的权限检查请通过 LocationService 进行
  static Future<bool> checkPermission() async {
    Logs.map.info('高德地图权限检查请通过 LocationService 进行');
    return true;
  }

  /// 计算两点之间的距离（米）
  /// 
  /// [startLat] 起点纬度
  /// [startLng] 起点经度
  /// [endLat] 终点纬度
  /// [endLng] 终点经度
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    // 使用 Haversine 公式计算距离
    const double earthRadius = 6371000; // 地球半径（米）
    
    final double dLat = _toRadians(endLat - startLat);
    final double dLng = _toRadians(endLng - startLng);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(startLat)) *
            math.cos(_toRadians(endLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  /// 角度转弧度
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
