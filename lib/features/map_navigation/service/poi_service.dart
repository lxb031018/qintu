import '../core/poi_api.dart';
import '../../../models/location/lat_lng.dart';

/// ============================================
/// POI 搜索 Service
///
/// 业务逻辑层，封装 PoiApi 调用
/// 不持有 UI 状态，只负责 POI 相关业务逻辑
///
/// 提供缓存和请求去重能力
/// ============================================

class PoiService {
  final PoiApi _api = PoiApi();

  /// 搜索结果缓存
  final Map<String, _CachedSearch> _searchCache = {};
  static const _cacheExpirySeconds = 60;

  /// in-flight 请求去重
  final Map<String, Future<PoiSearchResult>> _pendingRequests = {};

  /// POI 关键字搜索（带缓存和去重）
  Future<PoiSearchResult> searchPoi({
    required String keywords,
    String? city,
    LatLng? location,
    int radius = 50000,
  }) async {
    final cacheKey = '$keywords|$city|${location?.latitude}|${location?.longitude}|$radius';

    // 检查缓存
    if (_searchCache.containsKey(cacheKey)) {
      final cached = _searchCache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp).inSeconds < _cacheExpirySeconds) {
        return cached.result;
      }
    }

    // 检查是否有相同请求正在执行
    if (_pendingRequests.containsKey(cacheKey)) {
      return await _pendingRequests[cacheKey]!;
    }

    // 执行请求
    final future = _api.searchPoi(
      keywords: keywords,
      city: city,
      location: location,
      radius: radius,
    );
    _pendingRequests[cacheKey] = future;

    try {
      final result = await future;
      _searchCache[cacheKey] = _CachedSearch(
        result: result,
        timestamp: DateTime.now(),
      );
      return result;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  /// 逆地理编码：坐标转城市
  Future<String?> getCityFromLocation(LatLng location) async {
    return await _api.getCityFromLocation(location);
  }
}

/// 缓存条目
class _CachedSearch {
  final PoiSearchResult result;
  final DateTime timestamp;
  _CachedSearch({required this.result, required this.timestamp});
}

/// 全局单例
final poiService = PoiService();