import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/utils/logger.dart';
import '../models/poi_models.dart';
import '../service/poi_service.dart';
import '../service/location_category_service.dart';
import '../service/binding_location_service.dart';
import '../service/map_controller_service/map_controller_service.dart';
import 'location_input_state.dart';
import 'location_input_callbacks.dart';
import 'location_category.dart';
import 'map_navigation_service.dart';
import 'map_navigation_service_provider.dart';
import 'map_controller_provider.dart';
import '../../../models/location/lat_lng.dart';

class LocationInputNotifier extends Notifier<LocationInputState> {
  Timer? _debounceTimer;
  late final PoiService _poiService = ref.read(poiServiceProvider);
  late final LocationCategoryService _categoryService = ref.read(locationCategoryServiceProvider);
  late final BindingLocationService _bindingLocationService = ref.read(bindingLocationServiceProvider);
  MapControllerService? get _mapController => ref.read(mapControllerProvider);
  bool _hasShownList = false;

  MapNavigationService get _mapNavigation => ref.read(mapNavigationServiceProvider);

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
          swapOriginAndDestination();
        },
        onClearField: (isOrigin) {
          clearField(isOrigin);
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
          _mapNavigation.switchRouteType(type);
          _mapNavigation.showRoutesSheet();
        },
        onInputTap: (isOrigin) {
          showList(isOrigin: isOrigin);
        },
        onHideList: hideList,
        onLoadHistoryLocations: loadHistoryLocations,
        onLoadBinderLocations: loadBinderLocations,
        onSelectPoi: (poi) {
          selectPoi(poi);
        },
        onExitHistorySelectionMode: exitHistorySelectionMode,
        onToggleHistorySelection: toggleHistorySelection,
        onSelectAllHistory: selectAllHistory,
        onDeleteSelectedHistory: deleteSelectedHistory,
        onEnterHistorySelectionMode: enterHistorySelectionMode,
        onFillMyLocation: (getCurrentLocationFn) {
          fillMyLocation(getCurrentLocationFn);
        },
        onSelectCategory: selectCategory,
      ),
    );
  }

  Future<PoiSuggestion?> fillMyLocation(
    Future<Map<String, dynamic>?> Function() getCurrentLocationFn,
  ) async {
    Logs.location.debug('fillMyLocation: 开始获取GPS位置, isOrigin=${state.isOriginFocused}');

    final location = await getCurrentLocationFn();
    if (location == null) {
      Logs.location.warning('fillMyLocation: getCurrentLocationFn返回null');
      return null;
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

    final newFields = state.fields.copyWith(
      origin: state.isOriginFocused
          ? InputFieldState(text: poi.name, poi: poi)
          : state.fields.origin,
      destination: state.isOriginFocused
          ? state.fields.destination
          : InputFieldState(text: poi.name, poi: poi),
    );

    final newNaviTrigger = state.naviTrigger.copyWith(pendingNaviPoi: poi);

    state = state.copyWith(
      fields: newFields,
      naviTrigger: newNaviTrigger,
    );

    Logs.location.info('fillMyLocation: 已填充位置 ${poi.name}');
    return poi;
  }

  Future<void> loadHistoryLocations() async {
    state = state.copyWith(
      items: state.items.copyWith(isLoadingHistory: true),
    );

    final items = await _categoryService.getHistoryLocations();

    state = state.copyWith(
      items: state.items.copyWith(
        historyItems: items,
        isLoadingHistory: false,
      ),
    );
  }

  Future<void> loadBinderLocations() async {
    state = state.copyWith(
      items: state.items.copyWith(isLoadingBinderItems: true),
    );

    try {
      final binderDataList = await _bindingLocationService.fetchBinderDataList();
      final items = _categoryService.getBinderLocations(binderDataList);

      state = state.copyWith(
        items: state.items.copyWith(
          binderItems: items,
          isLoadingBinderItems: false,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        items: state.items.copyWith(
          binderItems: [],
          isLoadingBinderItems: false,
        ),
      );
    }
  }

  void selectCategory(LocationCategory category) {
    if (category != LocationCategory.history) {
      state = state.copyWith(
        list: state.list.copyWith(selectedCategory: category),
        selection: state.selection.copyWith(
          isHistorySelectionMode: false,
          selectedHistoryIds: {},
        ),
      );
    } else {
      state = state.copyWith(
        list: state.list.copyWith(selectedCategory: category),
      );
    }
  }

  void enterHistorySelectionMode() {
    state = state.copyWith(
      selection: state.selection.copyWith(isHistorySelectionMode: true),
    );
  }

  void exitHistorySelectionMode() {
    state = state.copyWith(
      selection: state.selection.copyWith(
        isHistorySelectionMode: false,
        selectedHistoryIds: {},
      ),
    );
  }

  void toggleHistorySelection(String poiId) {
    final newSet = Set<String>.from(state.selectedHistoryIds);
    if (newSet.contains(poiId)) {
      newSet.remove(poiId);
    } else {
      newSet.add(poiId);
    }
    state = state.copyWith(
      selection: state.selection.copyWith(selectedHistoryIds: newSet),
    );
  }

  void selectAllHistory() {
    final allIds = state.historyItems.map((poi) => poi.id).toSet();
    state = state.copyWith(
      selection: state.selection.copyWith(selectedHistoryIds: allIds),
    );
  }

  Future<void> deleteSelectedHistory() async {
    if (state.selectedHistoryIds.isEmpty) return;

    await _categoryService.deleteHistoryItems(state.selectedHistoryIds);

    final items = await _categoryService.getHistoryLocations();
    state = state.copyWith(
      items: state.items.copyWith(historyItems: items),
      selection: state.selection.copyWith(
        selectedHistoryIds: {},
        isHistorySelectionMode: false,
      ),
    );
  }

  Future<void> selectPoi(PoiSuggestion poi) async {
    final newFields = state.fields.copyWith(
      origin: state.isOriginFocused
          ? InputFieldState(text: poi.name, poi: poi)
          : state.fields.origin,
      destination: state.isOriginFocused
          ? state.fields.destination
          : InputFieldState(text: poi.name, poi: poi),
    );

    final newNaviTrigger = poi.latLng != null
        ? state.naviTrigger.copyWith(pendingNaviPoi: poi)
        : state.naviTrigger;

    state = state.copyWith(
      fields: newFields,
      naviTrigger: newNaviTrigger,
    );

    if (poi.source == PoiSource.search && poi.latLng != null) {
      _categoryService.addToHistory(
        name: poi.name,
        address: poi.address,
        location: poi.latLng!,
      );
    }

    if (poi.source == PoiSource.history) {
      Logs.ui.debug('selectPoi: 开始处理历史 POI 置顶, poi.id=${poi.id}');
      final updatedHistory = List<PoiSuggestion>.from(state.historyItems);
      updatedHistory.removeWhere((item) => item.id == poi.id);
      updatedHistory.insert(0, poi);
      state = state.copyWith(
        items: state.items.copyWith(historyItems: updatedHistory),
      );
      await _categoryService.moveHistoryItemToTop(poi.id);
    }

    hideList();
  }

  void showList({required bool isOrigin}) {
    Logs.ui.debug('PROVIDER showList: isOrigin=$isOrigin');

    LocationCategory? categoryToSet;
    if (!_hasShownList) {
      categoryToSet = LocationCategory.binder;
      _hasShownList = true;
    }

    state = state.copyWith(
      fields: state.fields.copyWith(isOriginFocused: isOrigin),
      list: state.list.copyWith(
        listVisible: true,
        selectedCategory: categoryToSet,
      ),
    );
  }

  void hideList() {
    Logs.ui.debug('PROVIDER hideList');
    state = state.copyWith(
      list: state.list.copyWith(
        listVisible: false,
        searchKeyword: '',
        searchResults: [],
        isSearching: false,
        clearSearchError: true,
      ),
    );
  }

  void setFocused(bool isOrigin) {
    state = state.copyWith(
      fields: state.fields.copyWith(isOriginFocused: isOrigin),
    );
  }

  void updateText(bool isOrigin, String text) {
    final newFields = state.fields.copyWith(
      origin: isOrigin
          ? state.fields.origin.copyWith(text: text)
          : state.fields.origin,
      destination: !isOrigin
          ? state.fields.destination.copyWith(text: text)
          : state.fields.destination,
    );
    state = state.copyWith(fields: newFields);
  }

  void clearField(bool isOrigin) {
    if (isOrigin) {
      state = state.copyWith(clearOrigin: true);
      _mapNavigation.clearOrigin();
    } else {
      state = state.copyWith(clearDestination: true);
      _mapNavigation.clearDestination();
    }
  }

  bool canSwapOriginAndDestination() {
    return state.origin.poi != null || state.destination.poi != null;
  }

  void swapOriginAndDestination() {
    final newFields = state.fields.copyWith(
      origin: state.fields.destination,
      destination: state.fields.origin,
      isOriginFocused: false,
    );

    state = state.copyWith(fields: newFields);
    _mapNavigation.swapOriginAndDestination();
  }

  void clearAll() {
    state = const LocationInputState();
  }

  void updateSearchKeyword(String keyword) {
    state = state.copyWith(
      list: state.list.copyWith(searchKeyword: keyword),
    );

    _debounceTimer?.cancel();

    if (keyword.length < 2) {
      state = state.copyWith(
        list: state.list.copyWith(
          searchResults: [],
          isSearching: false,
          clearSearchError: true,
        ),
      );
      return;
    }

    state = state.copyWith(
      list: state.list.copyWith(
        selectedCategory: LocationCategory.none,
        isSearching: true,
        clearSearchError: true,
      ),
    );

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(keyword);
    });
  }

  Future<void> _performSearch(String keyword) async {
    if (keyword != state.searchKeyword) return;

    try {
      final context = await _buildSearchContext();

      final result = await _poiService.searchPoiWithLocation(
        keyword: keyword,
        context: context,
      );

      if (keyword != state.searchKeyword) return;

      if (result.isSuccess) {
        Logs.ui.info('✅ 搜索到 ${result.suggestions.length} 条结果');
        state = state.copyWith(
          list: state.list.copyWith(
            searchResults: result.suggestions,
            isSearching: false,
          ),
        );
      } else {
        Logs.ui.info('🔍 未找到匹配的 POI 结果');
        state = state.copyWith(
          list: state.list.copyWith(
            searchResults: [],
            isSearching: false,
            searchError: result.error,
          ),
        );
      }
    } catch (e) {
      Logs.ui.error('❌ 搜索异常: $e');
      state = state.copyWith(
        list: state.list.copyWith(
          searchResults: [],
          isSearching: false,
          searchError: '搜索异常',
        ),
      );
    }
  }

  Future<LocationSearchContext> _buildSearchContext() async {
    final fixedCenter = state.searchCenter;
    String? cachedCity = _mapController?.lastKnownCity;
    LatLng? gpsCenter;

    final gpsResult = await _mapController?.getCurrentLocation();
    if (gpsResult != null) {
      gpsCenter = LatLng(
        gpsResult['latitude'] as double,
        gpsResult['longitude'] as double,
      );
      if (cachedCity == null) {
        cachedCity = gpsResult['city'] as String?;
      }
    } else {
      final lastLoc = await _mapController?.getLastKnownLocation();
      if (lastLoc != null) {
        gpsCenter = LatLng(
          lastLoc['latitude'] as double,
          lastLoc['longitude'] as double,
        );
      }
    }

    return LocationSearchContext(
      fixedCenter: fixedCenter,
      gpsCenter: gpsCenter,
      cachedCity: cachedCity,
    );
  }
}

final locationInputProvider =
    NotifierProvider<LocationInputNotifier, LocationInputState>(
  LocationInputNotifier.new,
);