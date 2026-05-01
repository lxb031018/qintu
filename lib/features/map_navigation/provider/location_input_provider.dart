import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';
import 'package:qintu/core/gps/gps_service.dart';
import '../models/poi_models.dart';
import '../service/poi_service.dart';
import '../service/location_category_service.dart';
import '../service/binding_location_service.dart';
import '../models/amap_routing_models.dart';
import '../../relationship_binding/service/binding_service.dart';
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

  /// 回调接口（Widget 通过回调与 Provider 交互）
  final LocationInputCardCallbacks? callbacks;

  /// 历史选中状态集合（用于删除）
  final Set<String> selectedHistoryIds;

  /// 是否处于历史选择模式
  final bool isHistorySelectionMode;

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
    this.callbacks,
    this.selectedHistoryIds = const {},
    this.isHistorySelectionMode = false,
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
    LocationInputCardCallbacks? callbacks,
    Set<String>? selectedHistoryIds,
    bool? isHistorySelectionMode,
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
      callbacks: callbacks ?? this.callbacks,
      selectedHistoryIds: selectedHistoryIds ?? this.selectedHistoryIds,
      isHistorySelectionMode: isHistorySelectionMode ?? this.isHistorySelectionMode,
    );
  }
}

/// ============================================
/// LocationInputCard 回调接口
///
/// Widget 通过回调与 Provider 交互，实现单向数据流
/// ============================================
class LocationInputCardCallbacks {
  final void Function(String value)? onOriginTextChanged;
  final void Function(String value)? onDestinationTextChanged;
  final void Function()? onSwapRequested;
  final void Function(bool isOrigin)? onClearField;
  final void Function(bool hasFocus)? onOriginFocusChanged;
  final void Function(bool hasFocus)? onDestinationFocusChanged;
  final void Function(RouteType type)? onRouteTypeSelected;

  const LocationInputCardCallbacks({
    this.onOriginTextChanged,
    this.onDestinationTextChanged,
    this.onSwapRequested,
    this.onClearField,
    this.onOriginFocusChanged,
    this.onDestinationFocusChanged,
    this.onRouteTypeSelected,
  });
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
    return LocationInputState(
      callbacks: LocationInputCardCallbacks(
        onOriginTextChanged: (value) {
          updateText(true, value);
          updateSearchKeyword(value);
        },
        onDestinationTextChanged: (value) {
          updateText(false, value);
          updateSearchKeyword(value);
        },
        onSwapRequested: () {
          final mapNotifier = ref.read(mapNavigationProvider.notifier);
          swapOriginAndDestination(mapNotifier);
        },
        onClearField: (isOrigin) {
          final mapNotifier = ref.read(mapNavigationProvider.notifier);
          clearField(isOrigin, mapNotifier);
        },
        onOriginFocusChanged: (hasFocus) {
          if (hasFocus) {
            showList(isOrigin: true);
          }
        },
        onDestinationFocusChanged: (hasFocus) {
          if (hasFocus) {
            showList(isOrigin: false);
          }
        },
        onRouteTypeSelected: (type) {
          final mapNotifier = ref.read(mapNavigationProvider.notifier);
          mapNotifier.switchRouteType(type);
          mapNotifier.showRoutesSheet();
        },
      ),
    );
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
      source: PoiSource.myLocation,
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
  ///
  /// 提供者层负责跨 feature 数据编排：
  /// 1. 从 relationship_binding 获取绑定列表
  /// 2. 逐项获取绑定者位置
  /// 3. 将数据传入 LocationCategoryService 做 PoiSuggestion 转换
  Future<void> loadBinderLocations() async {
    state = state.copyWith(isLoadingBinderItems: true);

    try {
      final bindingService = BindingService();
      final bindings = await bindingService.getBindingsList();

      if (bindings.isEmpty) {
        state = state.copyWith(binderItems: [], isLoadingBinderItems: false);
        return;
      }

      final binderDataList = <BinderLocationData>[];
      for (final binding in bindings) {
        final openid = binding.partnerOpenid;
        if (openid == null) continue;

        try {
          final result = await bindingLocationService.getBinderLocation(openid);
          if (result.isSuccess && result.location != null) {
            binderDataList.add(BinderLocationData(
              openid: openid,
              nickname: binding.partnerNickname ?? '绑定者',
              address: result.location!.address,
              lat: result.location!.latitude,
              lng: result.location!.longitude,
            ));
          }
        } catch (e) {
          // 单个绑定者获取失败不影响其他
          continue;
        }
      }

      final items = _categoryService.getBinderLocations(binderDataList);

      state = state.copyWith(
        binderItems: items,
        isLoadingBinderItems: false,
      );
    } catch (e) {
      state = state.copyWith(
        binderItems: [],
        isLoadingBinderItems: false,
      );
    }
  }

  /// 选择分类
  void selectCategory(LocationCategory category) {
    // 切换到历史分类时，重置选择模式
    if (category != LocationCategory.history) {
      state = state.copyWith(
        selectedCategory: category,
        isHistorySelectionMode: false,
        selectedHistoryIds: {},
      );
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  /// 开启历史选择模式
  void enterHistorySelectionMode() {
    state = state.copyWith(isHistorySelectionMode: true);
  }

  /// 退出历史选择模式
  void exitHistorySelectionMode() {
    state = state.copyWith(
      isHistorySelectionMode: false,
      selectedHistoryIds: {},
    );
  }

  /// 切换历史项选中状态
  void toggleHistorySelection(String poiId) {
    final newSet = Set<String>.from(state.selectedHistoryIds);
    if (newSet.contains(poiId)) {
      newSet.remove(poiId);
    } else {
      newSet.add(poiId);
    }
    state = state.copyWith(selectedHistoryIds: newSet);
  }

  /// 全选历史
  void selectAllHistory() {
    final allIds = state.historyItems.map((poi) => poi.id).toSet();
    state = state.copyWith(selectedHistoryIds: allIds);
  }

  /// 删除选中的历史
  Future<void> deleteSelectedHistory() async {
    if (state.selectedHistoryIds.isEmpty) return;

    await _categoryService.deleteHistoryItems(state.selectedHistoryIds);

    // 重新加载历史
    final items = await _categoryService.getHistoryLocations();
    state = state.copyWith(
      historyItems: items,
      selectedHistoryIds: {},
      isHistorySelectionMode: false,
    );
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

    // 只添加搜索来源的 POI 到历史
    if (poi.source == PoiSource.search && poi.latLng != null) {
      _categoryService.addToHistory(
        name: poi.name,
        address: poi.address,
        location: poi.latLng!,
      );
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

      // 如果已有搜索中心（绑定者 POI 坐标），直接用其获取城市，跳过 GPS 调用
      if (center != null) {
        Logs.ui.debug('已有搜索中心，使用 POI 位置获取城市');
        searchCity = await _poiService.getCityFromLocation(center);
        if (searchCity != null) {
          searchCity = searchCity.endsWith('市')
              ? searchCity.substring(0, searchCity.length - 1)
              : searchCity;
          Logs.ui.debug('从 POI 坐标获取城市: $searchCity');
        }
      } else {
        Logs.ui.debug('开始获取 GPS 位置...');
        final gpsResult = await _gpsService.getCurrentLocation();
        Logs.ui.debug('GPS 结果: $gpsResult');

        if (gpsResult != null) {
          center = LatLng(
            gpsResult['latitude'] as double,
            gpsResult['longitude'] as double,
          );

          final gpsCity = gpsResult['city'] as String?;
          if (gpsCity != null && gpsCity.isNotEmpty) {
            searchCity = gpsCity.endsWith('市')
                ? gpsCity.substring(0, gpsCity.length - 1)
                : gpsCity;
          } else {
            // GPS 返回的城市为空，尝试从坐标逆地理编码获取城市
            searchCity = await _poiService.getCityFromLocation(center);
            if (searchCity != null) {
              searchCity = searchCity.endsWith('市')
                  ? searchCity.substring(0, searchCity.length - 1)
                  : searchCity;
              Logs.ui.debug('从 GPS 坐标逆地理编码获取城市: $searchCity');
            }
          }
          Logs.ui.debug('使用 GPS 位置: ${center.latitude},${center.longitude}, 城市: $searchCity');
        } else {
          Logs.ui.debug('GPS 不可用，尝试获取设备缓存位置...');
          final lastLoc = await _gpsService.getLastKnownLocation();
          if (lastLoc != null) {
            center = lastLoc;
            searchCity = await _poiService.getCityFromLocation(lastLoc);
            if (searchCity != null) {
              searchCity = searchCity.endsWith('市')
                  ? searchCity.substring(0, searchCity.length - 1)
                  : searchCity;
              Logs.ui.debug('从缓存位置获取城市: $searchCity');
            }
          } else {
            Logs.ui.debug('无缓存位置，使用 lastKnownCity');
            final cachedCity = _gpsService.lastKnownCity;
            if (cachedCity != null && cachedCity.isNotEmpty) {
              searchCity = cachedCity.endsWith('市')
                  ? cachedCity.substring(0, cachedCity.length - 1)
                  : cachedCity;
            }
          }
        }
      }

      Logs.ui.info('🔍 搜索 POI: $keyword, 城市: $searchCity, 中心: ${center?.latitude},${center?.longitude}');

      // 获取城市区号（电话区号如 "0771"），原生搜索要求 cityCode 而非城市名
      String? cityCode;
      if (center != null) {
        cityCode = await _poiService.getCityCodeFromLocation(center);
        Logs.ui.debug('获取到城市区号: $cityCode');
      }

      final suggestions = await _poiService.inputTips(
        keywords: keyword,
        city: cityCode ?? searchCity,
        location: center,
      );

      if (keyword != state.searchKeyword) return;

      // 计算距离并排序
      if (center != null && suggestions.isNotEmpty) {
        for (final poi in suggestions) {
          final poiLatLng = poi.distanceLatLng;
          if (poiLatLng != null) {
            poi.distance = center.distanceTo(poiLatLng).toInt();
          }
        }
        suggestions.sort((a, b) => (a.distance ?? 999999999).compareTo(b.distance ?? 999999999));
      }

      if (suggestions.isNotEmpty) {
        Logs.ui.info('✅ 搜索到 ${suggestions.length} 条结果');
        state = state.copyWith(
          searchResults: suggestions,
          isSearching: false,
        );
      } else {
        Logs.ui.info('🔍 未找到匹配的 POI 结果');
        state = state.copyWith(
          searchResults: [],
          isSearching: false,
          searchError: '未找到匹配的结果',
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