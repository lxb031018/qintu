import 'package:dio/dio.dart';
import '../../../core/http/third_party_api_client.dart';
import '../../../config/amap_web_config.dart';
import '../../../models/location/lat_lng.dart';
import '../../../utils/errors/amap_error_handler.dart';
import '../../../utils/logger.dart';
import '../models/poi_models.dart';

export '../models/poi_models.dart';

class PoiApi {
  final Dio _dio = ThirdPartyApiClient.instance.dio;

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