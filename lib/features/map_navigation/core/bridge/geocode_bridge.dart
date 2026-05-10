import 'package:flutter/services.dart';
import 'package:qintu/core/constants/platform_channels.dart';
import 'package:qintu/utils/logger.dart';

/// 逆地理编码结果
class RegeocodeResult {
  final String? city;
  final String? cityCode;
  final String? adCode;
  final String? district;
  final String? province;

  const RegeocodeResult({
    this.city,
    this.cityCode,
    this.adCode,
    this.district,
    this.province,
  });

  factory RegeocodeResult.fromMap(Map<dynamic, dynamic> map) {
    String? emptyToNull(dynamic v) {
      final s = v?.toString() ?? '';
      return s.isNotEmpty ? s : null;
    }

    return RegeocodeResult(
      city: emptyToNull(map['city']),
      cityCode: emptyToNull(map['cityCode']),
      adCode: emptyToNull(map['adCode']),
      district: emptyToNull(map['district']),
      province: emptyToNull(map['province']),
    );
  }
}

/// 正向地理编码结果
class GeocodeResult {
  final double latitude;
  final double longitude;
  final String? address;

  const GeocodeResult({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory GeocodeResult.fromMap(Map<dynamic, dynamic> map) {
    return GeocodeResult(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address']?.toString(),
    );
  }
}

/// 高德地理编码桥接层
///
/// 通过 Platform Channel 调用 Android 原生 GeocodeSearch SDK 进行地理编码
class GeocodeBridge {
  static const _channel = MethodChannel(PlatformChannels.geocode);

  /// 逆地理编码：坐标 → 地址信息
  static Future<RegeocodeResult?> regeocode(double lat, double lng) async {
    try {
      Logs.ui.info('🔄 原生逆地理编码: $lat, $lng');
      final map = await _channel.invokeMapMethod('regeocode', {
        'lat': lat,
        'lng': lng,
      });

      if (map == null) {
        Logs.ui.warning('⚠️ 原生逆地理编码返回为空');
        return null;
      }

      final result = RegeocodeResult.fromMap(map);
      Logs.ui.info('✅ 原生逆地理编码成功: city=${result.city}, cityCode=${result.cityCode}');
      return result;
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 原生逆地理编码失败: ${e.message}');
      return null;
    } catch (e) {
      Logs.ui.warning('❌ 原生逆地理编码异常: $e');
      return null;
    }
  }

  /// 正向地理编码：地址 → 坐标
  static Future<GeocodeResult?> geocodeAddress(String address) async {
    try {
      Logs.ui.info('🗺️ 原生正向地理编码: $address');
      final map = await _channel.invokeMapMethod('geocodeAddress', {
        'address': address,
      });

      if (map == null) {
        Logs.ui.warning('⚠️ 原生正向地理编码返回为空');
        return null;
      }

      final result = GeocodeResult.fromMap(map);
      Logs.ui.info('✅ 原生正向地理编码成功: ${result.latitude}, ${result.longitude}');
      return result;
    } on PlatformException catch (e) {
      Logs.ui.warning('❌ 原生正向地理编码失败: ${e.message}');
      return null;
    } catch (e) {
      Logs.ui.warning('❌ 原生正向地理编码异常: $e');
      return null;
    }
  }
}
