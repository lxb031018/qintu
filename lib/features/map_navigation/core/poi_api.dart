import '../../../models/location/lat_lng.dart';
import '../../../utils/logger.dart';
import '../models/poi_models.dart';
import 'geocode_bridge.dart';
import 'poi_search_bridge.dart';

export '../models/poi_models.dart';

class PoiApi {
  Future<PoiSearchResult> searchPoi({
    required String keywords,
    String? city,
    LatLng? location,
    int radius = 50000,
  }) async {
    if (keywords.length < 2) {
      return PoiSearchResult(suggestions: []);
    }

    final result = await PoiSearchBridge.searchPoi(
      keyword: keywords,
      city: city,
      lat: location?.latitude,
      lng: location?.longitude,
      radius: radius,
      cityLimit: city != null && city.isNotEmpty,
    );

    if (!result.isSuccess) return result;

    final suggestions = result.suggestions;

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
  }

  Future<LatLng?> geocodeAddress(String address) async {
    try {
      final result = await GeocodeBridge.geocodeAddress(address);
      if (result == null) return null;
      return LatLng(result.latitude, result.longitude);
    } catch (e) {
      Logs.map.warning('地理编码失败: $e');
      return null;
    }
  }

  Future<String?> getCityFromLocation(LatLng location) async {
    try {
      final result = await GeocodeBridge.regeocode(location.latitude, location.longitude);
      return result?.city;
    } catch (e) {
      Logs.map.warning('逆地理编码异常: $e');
      return null;
    }
  }

  /// 从坐标获取城市区号（电话区号，如 "010"、"0771"）
  ///
  /// 用于原生公交路径规划 API（BusRouteQuery 的 city 参数）
  Future<String?> getCityCodeFromLocation(LatLng location) async {
    try {
      final result = await GeocodeBridge.regeocode(location.latitude, location.longitude);
      return result?.cityCode;
    } catch (e) {
      Logs.map.warning('获取城市区号异常: $e');
      return null;
    }
  }
}