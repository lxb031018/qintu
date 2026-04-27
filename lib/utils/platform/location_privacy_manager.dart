import 'dart:math';

/// 模糊位置级别
enum FuzzyLevel {
  low,     // 低精度模糊（100米）
  medium,  // 中精度模糊（500米）
  high,    // 高精度模糊（1000米）
}

/// 位置隐私保护工具类
///
/// 功能：
/// - 对真实位置添加随机偏移，保护用户隐私
/// - 支持不同精度的模糊级别

class LocationPrivacyManager {
  LocationPrivacyManager._();

  /// 对位置添加随机偏移，保护隐私
  ///
  /// [latitude] 真实纬度
  /// [longitude] 真实经度
  /// [radiusMeters] 随机偏移半径（米），默认 500 米
  /// 返回模糊后的位置坐标
  static Map<String, double> fuzzLocation({
    required double latitude,
    required double longitude,
    double radiusMeters = 500,
  }) {
    // 生成随机角度（0-360度）
    final angle = Random().nextDouble() * 2 * pi;
    
    // 生成随机距离（0-radiusMeters）
    final distance = Random().nextDouble() * radiusMeters;
    
    // 将米转换为度（近似值）
    // 1度纬度 ≈ 111,320米
    // 1度经度 ≈ 111,320 * cos(latitude)米
    const double metersPerDegreeLat = 111320;
    final double metersPerDegreeLng = 111320 * cos(latitude * pi / 180);
    
    // 计算偏移量
    final deltaLat = (distance * sin(angle)) / metersPerDegreeLat;
    final deltaLng = (distance * cos(angle)) / metersPerDegreeLng;
    
    return {
      'latitude': latitude + deltaLat,
      'longitude': longitude + deltaLng,
    };
  }

  /// 根据级别获取模糊半径
  static double getRadiusForLevel(FuzzyLevel level) {
    switch (level) {
      case FuzzyLevel.low:
        return 100;
      case FuzzyLevel.medium:
        return 500;
      case FuzzyLevel.high:
        return 1000;
    }
  }
}
