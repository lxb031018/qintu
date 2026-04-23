import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/gps/gps_service.dart';
import '../../../models/location/lat_lng.dart';
import '../../../utils/logger.dart';
import '../api/poi_api.dart';
import '../service/location_category_service.dart';
import 'map_navigation_provider.dart';

/// ============================================
/// 地点输入状态
/// ============================================

class LocationInputState {
  /// 列表是否显示
  final bool listVisible;

  /// 当前焦点是否在起点输入框
  final bool isOriginFocused;

  /// 选中的起点
  final PoiSuggestion? originPoi;

  /// 选中的终点
  final PoiSuggestion? destinationPoi;

  /// 搜索关键词
  final String searchKeyword;

  /// POI 搜索结果
  final List<PoiSuggestion> searchResults;

  /// 是否正在搜索
  final bool isSearching;

  /// 搜索错误信息
  final String? searchError;

  /// 历史位置列表
  final List<PoiSuggestion> historyItems;

  /// 是否正在加载历史位置
  final bool isLoadingHistory;

  const LocationInputState({
    this.listVisible = false,
    this.isOriginFocused = true,
    this.originPoi,
    this.destinationPoi,
    this.searchKeyword = '',
    this.searchResults = const [],
    this.isSearching = false,
    this.searchError,
    this.historyItems = const [],
    this.isLoadingHistory = false,
  });

  /// 获取搜索中心坐标
  /// 优先使用：对向位置已选的坐标
  /// 其次使用：当前已选的坐标
  LatLng? get searchCenter {
    // 如果在终点输入框输入，优先用起点的位置
    if (!isOriginFocused && originPoi != null) {
      return originPoi!.latLng;
    }
    // 如果在起点输入框输入，优先用终点的位置
    if (isOriginFocused && destinationPoi != null) {
      return destinationPoi!.latLng;
    }
    // 否则用起点或终点的位置（如果有）
    if (originPoi != null) {
      return originPoi!.latLng;
    }
    if (destinationPoi != null) {
      return destinationPoi!.latLng;
    }
    return null;
  }

  LocationInputState copyWith({
    bool? listVisible,
    bool? isOriginFocused,
    PoiSuggestion? originPoi,
    PoiSuggestion? destinationPoi,
    String? searchKeyword,
    List<PoiSuggestion>? searchResults,
    bool? isSearching,
    String? searchError,
    List<PoiSuggestion>? historyItems,
    bool? isLoadingHistory,
  }) {
    return LocationInputState(
      listVisible: listVisible ?? this.listVisible,
      isOriginFocused: isOriginFocused ?? this.isOriginFocused,
      originPoi: originPoi ?? this.originPoi,
      destinationPoi: destinationPoi ?? this.destinationPoi,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchError: searchError,
      historyItems: historyItems ?? this.historyItems,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
    );
  }
}

/// ============================================
/// 地点输入 Provider
/// ============================================

class LocationInputNotifier extends Notifier<LocationInputState> {
  Timer? _debounceTimer;
  final PoiApi _poiApi = PoiApi();
  final GpsService _gpsService = GpsService();
  final LocationCategoryService _categoryService = LocationCategoryService();

  @override
  LocationInputState build() {
    return const LocationInputState();
  }

  /// 获取"我的位置" POI
  ///
  /// 通过 [getCurrentLocationFn] 获取 GPS 坐标，返回 PoiSuggestion
  Future<PoiSuggestion?> getMyLocation(
    Future<Map<String, dynamic>?> Function() getCurrentLocationFn,
  ) async {
    return await _categoryService.getMyLocation(getCurrentLocationFn);
  }

  /// 加载历史位置
  Future<void> loadHistoryLocations() async {
    state = state.copyWith(isLoadingHistory: true);

    final items = await _categoryService.getHistoryLocations();

    state = state.copyWith(
      historyItems: items,
      isLoadingHistory: false,
    );
  }

  /// 选择一个位置（根据 isOriginFocused 决定是起点还是终点）
  ///
  /// [poi] 选中的 POI
  /// [mapNotifier] 用于同时更新 mapNavigationProvider
  void selectLocation(PoiSuggestion poi, MapNavigationNotifier mapNotifier) {
    if (state.isOriginFocused) {
      setOrigin(poi);
      mapNotifier.setOrigin(poi);
    } else {
      setDestination(poi);
      mapNotifier.setDestination(poi);
    }
    hideList();
  }

  /// 显示列表
  /// [isOrigin] true=起点输入框被点击，false=终点输入框被点击
  void showList({required bool isOrigin}) {
    Logs.ui.debug('PROVIDER showList: isOrigin=$isOrigin, current listVisible=${state.listVisible}');
    state = state.copyWith(
      listVisible: true,
      isOriginFocused: isOrigin,
    );
    Logs.ui.debug('PROVIDER showList: after, new listVisible=${state.listVisible}');
  }

  /// 隐藏列表（点击 x 按钮）
  void hideList() {
    Logs.ui.debug('PROVIDER hideList: before, listVisible=${state.listVisible}');
    state = state.copyWith(
      listVisible: false,
      searchKeyword: '',
      searchResults: [],
      isSearching: false,
    );
    Logs.ui.debug('PROVIDER hideList: after, listVisible=${state.listVisible}');
  }

  /// 设置焦点
  void setFocused(bool isOrigin) {
    state = state.copyWith(isOriginFocused: isOrigin);
  }

  /// 设置起点
  void setOrigin(PoiSuggestion poi) {
    state = state.copyWith(originPoi: poi);
  }

  /// 设置终点
  void setDestination(PoiSuggestion poi) {
    state = state.copyWith(destinationPoi: poi);
  }

  /// 清除起点
  void clearOrigin() {
    state = state.copyWith(originPoi: null);
  }

  /// 清除终点
  void clearDestination() {
    state = state.copyWith(destinationPoi: null);
  }

  /// 交换起点和终点
  void swap() {
    state = state.copyWith(
      originPoi: state.destinationPoi,
      destinationPoi: state.originPoi,
      isOriginFocused: false, // 交换后焦点切换到终点
    );
  }

  /// 清除所有
  void clearAll() {
    state = const LocationInputState();
  }

  /// 更新搜索关键词（带 debounce）
  void updateSearchKeyword(String keyword) {
    state = state.copyWith(searchKeyword: keyword);

    // 取消之前的定时器
    _debounceTimer?.cancel();

    // 关键词太短，清空结果
    if (keyword.length < 2) {
      state = state.copyWith(searchResults: [], isSearching: false, searchError: null);
      return;
    }

    // 显示搜索中状态
    state = state.copyWith(isSearching: true, searchError: null);

    // 300ms debounce
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(keyword);
    });
  }

  /// 执行 POI 搜索
  Future<void> _performSearch(String keyword) async {
    if (keyword != state.searchKeyword) return; // 关键词已变化

    try {
      // 获取搜索中心坐标
      var center = state.searchCenter;
      String? searchCity;

      // 始终获取最新的 GPS 位置（确保 city 是最新的）
      Logs.ui.debug('开始获取 GPS 位置...');
      final gpsResult = await _gpsService.getCurrentLocation();
      Logs.ui.debug('GPS 结果: $gpsResult');

      if (gpsResult != null) {
        // 设置搜索中心（如果有 POI 选中会用 POI 的位置，否则用 GPS 位置）
        center = state.searchCenter ?? LatLng(
          gpsResult['latitude'] as double,
          gpsResult['longitude'] as double,
        );

        final gpsCity = gpsResult['city'] as String?;
        Logs.ui.debug('GPS city 原始值: "$gpsCity"');

        if (gpsCity != null && gpsCity.isNotEmpty) {
          // 去掉"市"后缀，如"南宁市"→"南宁"
          searchCity = gpsCity.endsWith('市')
              ? gpsCity.substring(0, gpsCity.length - 1)
              : gpsCity;
        }
        Logs.ui.debug('使用 GPS 位置: ${center.latitude},${center.longitude}, 城市: $searchCity');
      } else {
        // GPS 不可用时，使用 searchCenter（POI 位置）
        Logs.ui.debug('GPS 不可用，使用 POI 位置: ${center?.latitude},${center?.longitude}');
        final cachedCity = _gpsService.lastKnownCity;
        if (cachedCity != null && cachedCity.isNotEmpty) {
          searchCity = cachedCity.endsWith('市')
              ? cachedCity.substring(0, cachedCity.length - 1)
              : cachedCity;
        }
      }

      Logs.ui.info('🔍 搜索 POI: $keyword, 中心: ${center?.latitude},${center?.longitude}, 城市: $searchCity');

      final result = await _poiApi.searchPoi(
        keywords: keyword,
        city: searchCity,    // 城市名，限制搜索范围
        location: center,    // 坐标，用于距离排序；null 时高德使用 city 参数搜索
        radius: 10000,
      );

      if (keyword != state.searchKeyword) return; // 关键词已变化

      if (result.isSuccess) {
        Logs.ui.info('✅ 搜索到 ${result.suggestions.length} 条结果');
        state = state.copyWith(
          searchResults: result.suggestions,
          isSearching: false,
        );
      } else {
        Logs.ui.warning('❌ 搜索失败: ${result.errorMessage}');
        state = state.copyWith(
          searchResults: [],
          isSearching: false,
          searchError: result.errorMessage ?? '搜索失败',
        );
      }
    } catch (e) {
      Logs.ui.error('❌ 搜索异常: $e');
      state = state.copyWith(
        searchResults: [],
        isSearching: false,
        searchError: '搜索异常',
      );
    }
  }
}

/// Provider 导出
final locationInputProvider =
    NotifierProvider<LocationInputNotifier, LocationInputState>(
  LocationInputNotifier.new,
);
