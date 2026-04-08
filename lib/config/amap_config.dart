library;

/// 高德地图配置 - 统一定义高德地图相关配置
///
/// 使用方法：
/// 1. 在 .env 文件中配置 AMAP_ANDROID_API_KEY
/// 2. 在应用启动时调用 AmapConfig.initialize()

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AmapConfig {
  /// Android 端高德地图 API Key
  /// 从 .env 文件读取（通过 flutter_dotenv）
  static String get androidApiKey {
    try {
      final key = dotenv.env['AMAP_ANDROID_API_KEY'] ?? '';
      // 调试日志
      if (kDebugMode) {
        debugPrint('AmapConfig: AMAP_ANDROID_API_KEY = ${key.isEmpty ? "(空)" : "${key.substring(0, 10)}..."}');
      }
      if (key.isEmpty || key.contains('your-')) {
        debugPrint('警告：未配置高德地图 Android API Key');
        return '';
      }
      return key;
    } catch (e) {
      debugPrint('读取高德地图 API Key 失败: $e');
      return '';
    }
  }

  /// 是否已配置 API Key
  static bool get isConfigured => androidApiKey.isNotEmpty && !androidApiKey.contains('your-');

  /// 地图默认缩放级别
  static const double defaultZoomLevel = 15.0;

  /// 导航时默认缩放级别
  static const double navigationZoomLevel = 17.0;

  /// 地图默认中心点（北京）
  static const double defaultCenterLat = 39.9042;
  static const double defaultCenterLng = 116.4074;

  /// 位置更新间隔（毫秒）
  static const int locationUpdateInterval = 5000;

  /// 定位精度
  static const LocationAccuracy defaultLocationAccuracy = LocationAccuracy.high;

  /// 路线规划 API 基础地址
  static String get routingApiBaseUrl => 'https://restapi.amap.com/v3/direction';

  /// 地理编码 API 基础地址
  static String get geocodeApiBaseUrl => 'https://restapi.amap.com/v3/geocode';

  /// 默认路线规划策略
  /// 0-速度优先，1-费用优先，2-距离优先，3-不计算费用
  static const int defaultRoutingStrategy = 0;

  /// 是否启用调试日志
  static const bool enableDebugLog = kDebugMode;
}

/// 定位精度枚举
enum LocationAccuracy {
  low,      // 低功耗
  balanced, // 均衡
  high,     // 高精度
  best,     // 最佳
}
