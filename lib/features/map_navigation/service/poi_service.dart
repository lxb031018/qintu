import '../core/poi_api.dart';
import '../../../models/location/lat_lng.dart';

/// ============================================
/// POI 搜索 Service
///
/// 业务逻辑层，封装 PoiApi 调用
/// 不持有 UI 状态，只负责 POI 相关业务逻辑
/// ============================================

class PoiService {
  final PoiApi _api = PoiApi();

  /// POI 关键字搜索
  Future<PoiSearchResult> searchPoi({
    required String keywords,
    String? city,
    LatLng? location,
    int radius = 50000,
  }) async {
    return await _api.searchPoi(
      keywords: keywords,
      city: city,
      location: location,
      radius: radius,
    );
  }

  /// 地理编码：地址转坐标
  Future<LatLng?> geocodeAddress(String address) async {
    return await _api.geocodeAddress(address);
  }

  /// 逆地理编码：坐标转城市
  Future<String?> getCityFromLocation(LatLng location) async {
    return await _api.getCityFromLocation(location);
  }
}

/// 全局单例
final poiService = PoiService();
