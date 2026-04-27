import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/gps/gps_service.dart';
import '../../../models/location/lat_lng.dart';
import '../../../utils/logger.dart';
import '../core/poi_api.dart'; // 仅导入类型 PoiSuggestion
import '../service/poi_service.dart';
import '../service/location_category_service.dart';
import 'map_navigation_provider.dart';

/// ============================================
/// 位置分类枚举
/// ============================================

enum LocationCategory {
  recommended, // 推荐地点
  binder,     // 绑定者位置
  history,    // 历史地点
  none,       // 无选中分类（搜索时使用）
}

/// ============================================
/// 单个输入框的状态
///
/// 追踪输入框的文本和 POI 选择状态
/// ============================================

class InputFieldState {
  final String text;
  final PoiSuggestion? poi;

  const InputFieldState({
    this.text = '',
    this.poi,
  });

  bool get hasText => text.isNotEmpty;
  bool get isPoiSelected => poi != null;

  InputFieldState copyWith({String? text, PoiSuggestion? poi, bool clearPoi = false}) {
    return InputFieldState(
      text: text ?? this.text,
      poi: clearPoi ? null : (poi ?? this.poi),
    );
  }
}

/// ============================================
/// 地点输入状态
///
/// 每个输入框有独立的状态，搜索相关状态独立管理
/// ============================================

class LocationInputState {
  /// 起点输入框状态
  final InputFieldState origin;

  /// 终点输入框状态
  final InputFieldState destination;

  /// 列表是否显示
  final bool listVisible;

  /// 当前焦点是否在起点输入框
  final bool isOriginFocused;

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

  /// 绑定者位置列表
  final List<PoiSuggestion> binderItems;

  /// 是否正在加载绑定者位置
  final bool isLoadingBinderItems;

  /// 当前选中的分类
  final LocationCategory selectedCategory;

  const LocationInputState({
    this.origin = const InputFieldState(),
    this.destination = const InputFieldState(),
    this.listVisible = false,
    this.isOriginFocused = true,
    this.searchKeyword = '',
    this.searchResults = const [],
    this.isSearching = false,
    this.searchError,
    this.historyItems = const [],
    this.isLoadingHistory = false,
    this.binderItems = const [],
    this.isLoadingBinderItems = false,
    this.selectedCategory = LocationCategory.recommended,
  });

  /// 获取搜索中心坐标
  /// 优先使用：对向位置已选的坐标，其次使用当前已选的坐标
  LatLng? get searchCenter {
    if (!isOriginFocused && origin.poi != null) {
      return origin.poi!.latLng;
    }
    if (isOriginFocused && destination.poi != null) {
      return destination.poi!.latLng;
    }
    if (origin.poi != null) return origin.poi!.latLng;
    if (destination.poi != null) return destination.poi!.latLng;
    return null;
  }

  LocationInputState copyWith({
    InputFieldState? origin,
    InputFieldState? destination,
    bool? listVisible,
    bool? isOriginFocused,
    String? searchKeyword,
    List<PoiSuggestion>? searchResults,
    bool? isSearching,
    String? searchError,
    List<PoiSuggestion>? historyItems,
    bool? isLoadingHistory,
    List<PoiSuggestion>? binderItems,
    bool? isLoadingBinderItems,
    LocationCategory? selectedCategory,
    bool clearOrigin = false,
    bool clearDestination = false,
  }) {
    return LocationInputState(
      origin: clearOrigin ? const InputFieldState() : (origin ?? this.origin),
      destination: clearDestination ? const InputFieldState() : (destination ?? this.destination),
      listVisible: listVisible ?? this.listVisible,
      isOriginFocused: isOriginFocused ?? this.isOriginFocused,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchError: searchError,
      historyItems: historyItems ?? this.historyItems,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      binderItems: binderItems ?? this.binderItems,
      isLoadingBinderItems: isLoadingBinderItems ?? this.isLoadingBinderItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

/// ============================================
/// 地点输入 Provider
/// ============================================

class LocationInputNotifier extends Notifier<LocationInputState> {
  Timer? _debounceTimer;
  final PoiService _poiService = poiService;
  final GpsService _gpsService = GpsService();
  final LocationCategoryService _categoryService = LocationCategoryService();
  bool _hasShownList = false;

  @override
  LocationInputState build() {
    return const LocationInputState();
  }

  /// 直接将 GPS 位置填入当前焦点的输入框
  Future<void> fillMyLocation(
    Future<Map<String, dynamic>?> Function() getCurrentLocationFn,
    MapNavigationNotifier mapNotifier,
  ) async {
    Logs.location.debug('fillMyLocation: 开始获取GPS位置, isOrigin=${state.isOriginFocused}');

    final location = await getCurrentLocationFn();
    if (location == null) {
      Logs.location.warning('fillMyLocation: getCurrentLocationFn返回null');
      return;
    }

    Logs.location.info('fillMyLocation: 获取到GPS位置 city=${location['city']}');

    final poi = PoiSuggestion(
      id: 'my_location',
      name: '我的位置',
      district: location['city'] ?? '',
      address: 'GPS 定位',
      location: '${location["longitude"]},${location["latitude"]}',
    );

    selectPoi(poi, mapNotifier);
    Logs.location.info('fillMyLocation: 已填充位置 ${poi.name}');
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

  /// 加载绑定者位置列表
  Future<void> loadBinderLocations() async {
    state = state.copyWith(isLoadingBinderItems: true);

    final items = await _categoryService.getBinderLocations();

    state = state.copyWith(
      binderItems: items,
      isLoadingBinderItems: false,
    );
  }

  /// 选择分类
  void selectCategory(LocationCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// 选择 POI
  void selectPoi(PoiSuggestion poi, MapNavigationNotifier mapNotifier) {
    if (state.isOriginFocused) {
      state = state.copyWith(origin: InputFieldState(text: poi.name, poi: poi));
      mapNotifier.setOrigin(poi);
    } else {
      state = state.copyWith(destination: InputFieldState(text: poi.name, poi: poi));
      mapNotifier.setDestination(poi);
    }
    hideList();
  }

  /// 显示列表
  void showList({required bool isOrigin}) {
    Logs.ui.debug('PROVIDER showList: isOrigin=$isOrigin');

    LocationCategory? categoryToSet;
    if (!_hasShownList) {
      categoryToSet = LocationCategory.binder;
      _hasShownList = true;
    }

    state = state.copyWith(
      listVisible: true,
      isOriginFocused: isOrigin,
      selectedCategory: categoryToSet,
    );
  }

  /// 隐藏列表
  void hideList() {
    Logs.ui.debug('PROVIDER hideList');
    state = state.copyWith(
      listVisible: false,
      searchKeyword: '',
      searchResults: [],
      isSearching: false,
    );
  }

  /// 设置焦点
  void setFocused(bool isOrigin) {
    state = state.copyWith(isOriginFocused: isOrigin);
  }

  /// 更新输入框文本（仅更新文本，不清除 POI）
  void updateText(bool isOrigin, String text) {
    if (isOrigin) {
      state = state.copyWith(origin: state.origin.copyWith(text: text));
    } else {
      state = state.copyWith(destination: state.destination.copyWith(text: text));
    }
  }

  /// 清除输入框
  void clearField(bool isOrigin, MapNavigationNotifier mapNotifier) {
    if (isOrigin) {
      state = state.copyWith(clearOrigin: true);
      mapNotifier.clearOrigin();
    } else {
      state = state.copyWith(clearDestination: true);
      mapNotifier.clearDestination();
    }
  }

  /// 清除起点（兼容旧 API）
  void clearOrigin() {
    state = state.copyWith(clearOrigin: true);
  }

  /// 清除终点（兼容旧 API）
  void clearDestination() {
    state = state.copyWith(clearDestination: true);
  }

  /// 判断是否可以交换起点和终点
  bool canSwapOriginAndDestination() {
    return state.origin.poi != null || state.destination.poi != null;
  }

  /// 交换起点和终点
  void swapOriginAndDestination(MapNavigationNotifier mapNotifier) {
    final newOrigin = state.destination;
    final newDestination = state.origin;

    state = state.copyWith(
      origin: newOrigin,
      destination: newDestination,
      isOriginFocused: false,
    );

    mapNotifier.swapOriginAndDestination();
  }

  /// 清除所有
  void clearAll() {
    state = const LocationInputState();
  }

  /// 更新搜索关键词（带 debounce）
  void updateSearchKeyword(String keyword) {
    state = state.copyWith(searchKeyword: keyword);

    _debounceTimer?.cancel();

    if (keyword.length < 2) {
      state = state.copyWith(searchResults: [], isSearching: false, searchError: null);
      return;
    }

    state = state.copyWith(selectedCategory: LocationCategory.none);
    state = state.copyWith(isSearching: true, searchError: null);

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(keyword);
    });
  }

  /// 执行 POI 搜索
  Future<void> _performSearch(String keyword) async {
    if (keyword != state.searchKeyword) return;

    try {
      var center = state.searchCenter;
      String? searchCity;

      Logs.ui.debug('开始获取 GPS 位置...');
      final gpsResult = await _gpsService.getCurrentLocation();
      Logs.ui.debug('GPS 结果: $gpsResult');

      if (gpsResult != null) {
        // 仅当 searchCenter 为 null 时才使用 GPS 位置
        // 如果起点已选 POI（绑定者位置），优先使用该位置作为搜索中心
        center ??= LatLng(
          gpsResult['latitude'] as double,
          gpsResult['longitude'] as double,
        );

        final gpsCity = gpsResult['city'] as String?;
        if (gpsCity != null && gpsCity.isNotEmpty) {
          searchCity = gpsCity.endsWith('市')
              ? gpsCity.substring(0, gpsCity.length - 1)
              : gpsCity;
        }
        Logs.ui.debug('使用 GPS 位置: ${center.latitude},${center.longitude}, 城市: $searchCity');
      } else {
        Logs.ui.debug('GPS 不可用，使用 POI 位置');
        // GPS 不可用时，尝试用搜索中心的坐标获取城市
        if (center != null) {
          searchCity = await _poiService.getCityFromLocation(center);
          if (searchCity != null) {
            searchCity = searchCity.endsWith('市')
                ? searchCity.substring(0, searchCity.length - 1)
                : searchCity;
            Logs.ui.debug('从 POI 坐标获取城市: $searchCity');
          }
        }
        if (searchCity == null) {
          final cachedCity = _gpsService.lastKnownCity;
          if (cachedCity != null && cachedCity.isNotEmpty) {
            searchCity = cachedCity.endsWith('市')
                ? cachedCity.substring(0, cachedCity.length - 1)
                : cachedCity;
          }
        }
      }

      Logs.ui.info('🔍 搜索 POI: $keyword, 城市: $searchCity, 中心: ${center?.latitude},${center?.longitude}');

      final result = await _poiService.searchPoi(
        keywords: keyword,
        city: searchCity,
        location: center,
        radius: 10000,
      );

      if (keyword != state.searchKeyword) return;

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