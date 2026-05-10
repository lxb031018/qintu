import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/utils/logger.dart';
import '../models/poi_models.dart';
import '../service/poi_service.dart';
import '../service/location_category_service.dart';
import '../service/binding_location_service.dart';
import '../models/amap_routing_models.dart';
import 'location_input_state.dart';
import 'location_input_callbacks.dart';
import 'location_category.dart';
import 'map_navigation_service.dart';
import 'map_navigation_service_provider.dart';
import 'map_display_service.dart';
import 'map_display_service_provider.dart';
import 'map_controller_provider.dart';

class LocationInputNotifier extends Notifier<LocationInputState> {
  Timer? _debounceTimer;
  late final PoiService _poiService = ref.read(poiServiceProvider);
  late final LocationCategoryService _categoryService = ref.read(locationCategoryServiceProvider);
  late final BindingLocationService _bindingLocationService = ref.read(bindingLocationServiceProvider);
  bool _hasShownList = false;

  MapNavigationService get _mapNavigation => ref.read(mapNavigationServiceProvider);
  MapDisplayService get _mapDisplay => ref.read(mapDisplayServiceProvider);

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
          swapOriginAndDestination(_mapNavigation);
        },
        onClearField: (isOrigin) {
          clearField(isOrigin, _mapNavigation);
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
          selectPoi(poi, _mapNavigation);
        },
        onExitHistorySelectionMode: exitHistorySelectionMode,
        onToggleHistorySelection: toggleHistorySelection,
        onSelectAllHistory: selectAllHistory,
        onDeleteSelectedHistory: deleteSelectedHistory,
        onEnterHistorySelectionMode: enterHistorySelectionMode,
        onFillMyLocation: (getCurrentLocationFn) {
          fillMyLocation(getCurrentLocationFn, _mapNavigation, _mapDisplay);
        },
        onSelectCategory: selectCategory,
      ),
    );
  }

  Future<void> fillMyLocation(
    Future<Map<String, dynamic>?> Function() getCurrentLocationFn,
    MapNavigationService mapNavigation,
    MapDisplayService mapDisplay,
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

    selectPoi(poi, mapNavigation);

    final lat = location['latitude'] as double;
    final lng = location['longitude'] as double;
    await mapDisplay.setNaviShowMode(3);
    await mapDisplay.moveCamera(lat: lat, lng: lng, zoom: 17);
    Logs.location.info('fillMyLocation: 已填充位置 ${poi.name}');
  }

  Future<void> loadHistoryLocations() async {
    state = state.copyWith(isLoadingHistory: true);

    final items = await _categoryService.getHistoryLocations();

    state = state.copyWith(
      historyItems: items,
      isLoadingHistory: false,
    );
  }

  Future<void> loadBinderLocations() async {
    state = state.copyWith(isLoadingBinderItems: true);

    try {
      final binderDataList = await _bindingLocationService.fetchBinderDataList();
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

  void selectCategory(LocationCategory category) {
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

  void enterHistorySelectionMode() {
    state = state.copyWith(isHistorySelectionMode: true);
  }

  void exitHistorySelectionMode() {
    state = state.copyWith(
      isHistorySelectionMode: false,
      selectedHistoryIds: {},
    );
  }

  void toggleHistorySelection(String poiId) {
    final newSet = Set<String>.from(state.selectedHistoryIds);
    if (newSet.contains(poiId)) {
      newSet.remove(poiId);
    } else {
      newSet.add(poiId);
    }
    state = state.copyWith(selectedHistoryIds: newSet);
  }

  void selectAllHistory() {
    final allIds = state.historyItems.map((poi) => poi.id).toSet();
    state = state.copyWith(selectedHistoryIds: allIds);
  }

  Future<void> deleteSelectedHistory() async {
    if (state.selectedHistoryIds.isEmpty) return;

    await _categoryService.deleteHistoryItems(state.selectedHistoryIds);

    final items = await _categoryService.getHistoryLocations();
    state = state.copyWith(
      historyItems: items,
      selectedHistoryIds: {},
      isHistorySelectionMode: false,
    );
  }

  Future<void> selectPoi(PoiSuggestion poi, MapNavigationService mapNavigation) async {
    if (state.isOriginFocused) {
      state = state.copyWith(origin: InputFieldState(text: poi.name, poi: poi));
      mapNavigation.setOrigin(poi);
    } else {
      state = state.copyWith(destination: InputFieldState(text: poi.name, poi: poi));
      mapNavigation.setDestination(poi);
    }

    if (poi.latLng != null) {
      await _mapDisplay.moveCameraToCenter(
        lat: poi.latLng!.latitude,
        lng: poi.latLng!.longitude,
        zoom: 17,
      );
    }

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
      state = state.copyWith(historyItems: updatedHistory);
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
      listVisible: true,
      isOriginFocused: isOrigin,
      selectedCategory: categoryToSet,
    );
  }

  void hideList() {
    Logs.ui.debug('PROVIDER hideList');
    state = state.copyWith(
      listVisible: false,
      searchKeyword: '',
      searchResults: [],
      isSearching: false,
    );
  }

  void setFocused(bool isOrigin) {
    state = state.copyWith(isOriginFocused: isOrigin);
  }

  void updateText(bool isOrigin, String text) {
    if (isOrigin) {
      state = state.copyWith(origin: state.origin.copyWith(text: text));
    } else {
      state = state.copyWith(destination: state.destination.copyWith(text: text));
    }
  }

  void clearField(bool isOrigin, MapNavigationService mapNavigation) {
    if (isOrigin) {
      state = state.copyWith(clearOrigin: true);
      mapNavigation.clearOrigin();
    } else {
      state = state.copyWith(clearDestination: true);
      mapNavigation.clearDestination();
    }
  }

  bool canSwapOriginAndDestination() {
    return state.origin.poi != null || state.destination.poi != null;
  }

  void swapOriginAndDestination(MapNavigationService mapNavigation) {
    final newOrigin = state.destination;
    final newDestination = state.origin;

    state = state.copyWith(
      origin: newOrigin,
      destination: newDestination,
      isOriginFocused: false,
    );

    mapNavigation.swapOriginAndDestination();
  }

  void clearAll() {
    state = const LocationInputState();
  }

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

  Future<void> _performSearch(String keyword) async {
    if (keyword != state.searchKeyword) return;

    try {
      var center = state.searchCenter;
      String? searchCity;

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
        final mcService = ref.read(mapControllerProvider);
        final gpsResult = await mcService?.getCurrentLocation();
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
          final lastLocMap = await mcService?.getLastKnownLocation();
          if (lastLocMap != null) {
            final lastLoc = LatLng(
              lastLocMap['latitude'] as double,
              lastLocMap['longitude'] as double,
            );
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
            final cachedCity = mcService?.lastKnownCity;
            if (cachedCity != null && cachedCity.isNotEmpty) {
              searchCity = cachedCity.endsWith('市')
                  ? cachedCity.substring(0, cachedCity.length - 1)
                  : cachedCity;
            }
          }
        }
      }

      Logs.ui.info('🔍 搜索 POI: $keyword, 城市: $searchCity, 中心: ${center?.latitude},${center?.longitude}');

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

final locationInputProvider =
    NotifierProvider<LocationInputNotifier, LocationInputState>(
  LocationInputNotifier.new,
);