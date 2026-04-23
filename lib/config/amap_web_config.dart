library;

/// 高德地图路线规划 API Key
/// 从 .env 文件中读取 AMAP_WEB_API_KEY
/// 注意：Web 服务 Key 与 Android SDK Key 不同

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AmapWebConfig {
  static String get webApiKey {
    final key = dotenv.env['AMAP_WEB_API_KEY'] ?? '';
    if (key.isEmpty || key.contains('your-')) {
      return '';
    }
    return key;
  }

  static bool get isConfigured => webApiKey.isNotEmpty && !webApiKey.contains('your-');

  /// 路线规划 API 基础地址
  static const String routingApiBaseUrl = 'https://restapi.amap.com/v3/direction';

  /// 地理编码 API 基础地址
  static const String geocodeApiBaseUrl = 'https://restapi.amap.com/v3/geocode';

  /// 默认路线规划策略
  /// 0-速度最快，1-费用优先，2-距离最短，3-不计算费用
  static const int defaultRoutingStrategy = 0;
}
