import 'dart:math' as math;
import 'package:json_annotation/json_annotation.dart';

part 'lat_lng.g.dart';

/// 通用经纬度坐标模型
/// 
/// 替代高德插件中的 LatLng，用于项目内部坐标表示
/// 
/// 注意：
/// - latitude: 纬度（-90 到 90）
/// - longitude: 经度（-180 到 180）
/// - 与高德 API 交互时，注意坐标顺序（高德使用 lon,lat）

@JsonSerializable()
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  /// 从高德 API 响应解析（高德返回 "lon,lat" 字符串）
  factory LatLng.fromAmapString(String lonLatStr) {
    final parts = lonLatStr.split(',');
    if (parts.length != 2) {
      throw FormatException('Invalid AMap coordinate format: $lonLatStr');
    }
    return LatLng(
      double.parse(parts[1]), // lat
      double.parse(parts[0]), // lon
    );
  }

  /// 转换为高德 API 请求格式（"lon,lat"）
  String toAmapString() => '$longitude,$latitude';

  /// 计算与另一点的距离（米，使用 Haversine 公式）
  double distanceTo(LatLng other) {
    const double earthRadius = 6371000;
    final double dLat = _toRadians(other.latitude - latitude);
    final double dLng = _toRadians(other.longitude - longitude);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(other.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadius * 2 * math.asin(math.sqrt(a));
  }

  @override
  String toString() => 'LatLng($latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
