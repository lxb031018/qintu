import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/poi_api.dart';
import '../core/geocode_bridge.dart';
import '../../../models/location/lat_lng.dart';

/// ============================================
/// POI 搜索 Service
///
/// 业务逻辑层，封装 PoiApi 调用
/// 不持有 UI 状态，只负责 POI 相关业务逻辑
///
/// 提供缓存和请求去重能力
/// ============================================

/// 位置搜索上下文
class LocationSearchContext {
  final LatLng? fixedCenter;
  final LatLng? gpsCenter;
  final String? cachedCity;
  final String? cachedCityCode;

  const LocationSearchContext({
    this.fixedCenter,
    this.gpsCenter,
    this.cachedCity,
    this.cachedCityCode,
  });
}

/// 位置搜索结果
class LocationSearchResult {
  final List<PoiSuggestion> suggestions;
  final LatLng? searchCenter;
  final String? searchCity;
  final String? error;

  const LocationSearchResult({
    this.suggestions = const [],
    this.searchCenter,
    this.searchCity,
    this.error,
  });

  bool get isSuccess => error == null && suggestions.isNotEmpty;
}

class PoiService {
  final PoiApi _api = PoiApi();

  /// 搜索结果缓存
  final Map<String, _CachedSearch> _searchCache = {};
  static const _cacheExpirySeconds = 60;

  /// in-flight 请求去重
  final Map<String, Future<PoiSearchResult>> _pendingRequests = {};

  /// 输入提示：模糊匹配 POI 关键词
  Future<List<PoiSuggestion>> inputTips({
    required String keywords,
    String? city,
    LatLng? location,
  }) async {
    if (keywords.length < 2) return [];
    return await _api.inputTips(
      keywords: keywords,
      city: city,
      location: location,
    );
  }

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

  /// 从坐标获取城市区号（电话区号，如 "0771"）
  Future<String?> getCityCodeFromLocation(LatLng location) async {
    return await _api.getCityCodeFromLocation(location);
  }

  /// 从坐标获取完整的逆地理编码结果
  Future<RegeocodeResult?> getRegeocodeFromLocation(LatLng location) async {
    return await _api.getRegeocodeFromLocation(location);
  }

  /// 带位置上下文的 POI 搜索
  ///
  /// 整合：城市获取 → POI 搜索 → 距离排序
  Future<LocationSearchResult> searchPoiWithLocation({
    required String keyword,
    required LocationSearchContext context,
  }) async {
    if (keyword.length < 2) {
      return const LocationSearchResult(error: '关键词长度不足');
    }

    LatLng? searchCenter = context.fixedCenter;
    String? searchCity = context.cachedCity;
    String? cityCode = context.cachedCityCode;

    if (searchCenter == null && context.gpsCenter != null) {
      searchCenter = context.gpsCenter;
      if (context.cachedCity == null) {
        searchCity = await getCityFromLocation(searchCenter!);
      }
      if (context.cachedCityCode == null) {
        cityCode = await getCityCodeFromLocation(searchCenter!);
      }
    }

    final suggestions = await inputTips(
      keywords: keyword,
      city: cityCode ?? searchCity,
      location: searchCenter,
    );

    if (searchCenter != null && suggestions.isNotEmpty) {
      for (final poi in suggestions) {
        final poiLatLng = poi.distanceLatLng;
        if (poiLatLng != null) {
          poi.distance = searchCenter.distanceTo(poiLatLng).toInt();
        }
      }
      suggestions.sort((a, b) => (a.distance ?? 999999999).compareTo(b.distance ?? 999999999));
    }

    if (suggestions.isNotEmpty) {
      return LocationSearchResult(
        suggestions: suggestions,
        searchCenter: searchCenter,
        searchCity: searchCity,
      );
    } else {
      return LocationSearchResult(
        suggestions: [],
        searchCenter: searchCenter,
        searchCity: searchCity,
        error: '未找到匹配的结果',
      );
    }
  }
}

/// 缓存条目
class _CachedSearch {
  final PoiSearchResult result;
  final DateTime timestamp;
  _CachedSearch({required this.result, required this.timestamp});
}

final poiServiceProvider = Provider<PoiService>((ref) => PoiService());