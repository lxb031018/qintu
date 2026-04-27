import 'package:dio/dio.dart';
import '../../../core/http/third_party_api_client.dart';
import '../../../config/amap_web_config.dart';
import '../../../models/location/lat_lng.dart';
import '../../../utils/errors/amap_error_handler.dart';
import '../../../utils/logger.dart';

/// ============================================
/// 高德 POI 搜索 API
///
/// 纯 HTTP 调用，返回数据模型，无 Flutter 依赖
///
/// 依赖 ThirdPartyApiClient 统一管理第三方 HTTP 请求
/// ============================================

class PoiApi {
  /// 使用统一的第三方 API 客户端
  final Dio _dio = ThirdPartyApiClient.instance.dio;

  /// POI 关键字搜索
  Future<PoiSearchResult> searchPoi({
    required String keywords,
    String? city,
    LatLng? location,
    int radius = 50000,
  }) async {
    final apiKey = AmapWebConfig.webApiKey;
    if (apiKey.isEmpty) {
      return PoiSearchResult(errorCode: 1002, errorMessage: 'API Key 未配置');
    }

    if (keywords.length < 2) {
      return PoiSearchResult(suggestions: []);
    }

    try {
      final params = <String, dynamic>{
        'key': apiKey,
        'keywords': keywords,
        'city': city ?? '全国',
        'citylimit': city != null && city.isNotEmpty,
        'extensions': 'all',
        'output': 'json',
      };

      if (location != null) {
        params['location'] = '${location.longitude},${location.latitude}';
        params['radius'] = radius;
      }

      final response = await _dio.get(
        '/v3/place/text',
        queryParameters: params,
      );

      final data = response.data;
      final status = data['status'] as String?;
      final infoCode = int.tryParse(data['infocode']?.toString() ?? '0') ?? 0;

      if (status != '1') {
        return PoiSearchResult(
          errorCode: infoCode,
          errorMessage: AmapErrorHandler.getFriendlyMessage(infoCode),
        );
      }

      final pois = data['pois'] as List? ?? [];
      final suggestions = pois.map((poi) => PoiSuggestion.fromMap(poi)).toList();

      // 计算距离并排序
      if (location != null && suggestions.isNotEmpty) {
        for (final poi in suggestions) {
          final poiLatLng = poi.distanceLatLng;
          if (poiLatLng != null) {
            poi.distance = location.distanceTo(poiLatLng).toInt();
          }
        }
        suggestions.sort((a, b) => (a.distance ?? 999999999).compareTo(b.distance ?? 999999999));
      }

      return PoiSearchResult(suggestions: suggestions);
    } on DioException {
      return PoiSearchResult(errorCode: 1806, errorMessage: '网络请求失败');
    } catch (e) {
      return PoiSearchResult(errorCode: 1203, errorMessage: e.toString());
    }
  }

  /// 地理编码：地址转坐标
  Future<LatLng?> geocodeAddress(String address) async {
    final apiKey = AmapWebConfig.webApiKey;
    if (apiKey.isEmpty) return null;

    try {
      final response = await _dio.get(
        '/v3/geocode/geo',
        queryParameters: {
          'key': apiKey,
          'address': address,
          'output': 'json',
        },
      );

      final data = response.data;
      if (data['status'] != '1' || data['geocodes'] == null) {
        return null;
      }

      final location = data['geocodes'][0]['location'] as String?;
      if (location == null || location.isEmpty) return null;

      return LatLng.fromAmapString(location);
    } catch (e) {
      Logs.map.warning('地理编码失败: $e');
      return null;
    }
  }

  /// 逆地理编码：坐标转城市
  Future<String?> getCityFromLocation(LatLng location) async {
    final apiKey = AmapWebConfig.webApiKey;
    if (apiKey.isEmpty) return null;

    try {
      final response = await _dio.get(
        '/v3/geocode/regeo',
        queryParameters: {
          'key': apiKey,
          'location': '${location.longitude},${location.latitude}',
          'extensions': 'base',
          'output': 'json',
        },
      );

      final data = response.data;
      if (data['status'] != '1' || data['regeocode'] == null) {
        return null;
      }

      final city = data['regeocode']['addressComponent']['city'] as String? ?? '';
      return city.isNotEmpty ? city : null;
    } catch (e) {
      Logs.map.warning('逆地理编码异常: $e');
      return null;
    }
  }
}

/// POI 搜索结果
class PoiSearchResult {
  final List<PoiSuggestion> suggestions;
  final int errorCode;
  final String? errorMessage;

  const PoiSearchResult({
    this.suggestions = const [],
    this.errorCode = 0,
    this.errorMessage,
  });

  bool get isSuccess => errorCode == 0 && suggestions.isNotEmpty;
}

/// POI 搜索结果项
class PoiSuggestion {
  final String id;
  final String name;
  final String district;
  final String address;
  final String location;
  int? distance;
  final String? entrLocation;

  PoiSuggestion({
    required this.id,
    required this.name,
    required this.district,
    required this.address,
    required this.location,
    this.distance,
    this.entrLocation,
  });

  LatLng? get latLng {
    if (location.isEmpty || location == '[]') return null;
    final parts = location.split(',');
    if (parts.length != 2) return null;
    return LatLng.fromAmapString(location);
  }

  LatLng? get distanceLatLng {
    final locStr = entrLocation ?? location;
    if (locStr.isEmpty || locStr == '[]') return null;
    return LatLng.fromAmapString(locStr);
  }

  factory PoiSuggestion.fromMap(Map<String, dynamic> map) {
    return PoiSuggestion(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      district: map['district']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      distance: int.tryParse(map['distance']?.toString() ?? ''),
      entrLocation: map['entr_location']?.toString(),
    );
  }
}
