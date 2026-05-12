import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/utils/logger.dart';
import '../../../models/poi_models.dart';
import '../../../service/location_category_service.dart';
import '../location_input_state.dart';
import '../location_input_callbacks.dart';
import '../location_category.dart';
import '../../map_navigation/map_navigation_service.dart';
import '../../map_navigation/map_navigation_service_provider.dart';
import 'location_search_notifier.dart';

/// ============================================
/// 位置输入 Notifier
///
/// 管理位置输入卡片的状态和业务逻辑：
/// - 起点/终点文本和 POI 选择状态
/// - 列表显示/隐藏控制
/// - 历史选择模式管理
///
/// 通过 LocationInputCardCallbacks 与 UI 解耦
/// ============================================
class LocationInputNotifier extends Notifier<LocationInputState> {
  bool _hasShownList = false;

  late final LocationCategoryService _categoryService = ref.read(locationCategoryServiceProvider);

  MapNavigationService get _mapNavigation => ref.read(mapNavigationServiceProvider);

  @override
  LocationInputState build() {
    // 监听搜索结果并同步到 LocationInputState
    ref.listen<LocationSearchState>(locationSearchProvider, (previous, next) {
      state = state.copyWith(
        list: state.list.copyWith(
          searchResults: next.results,
          isSearching: next.isSearching,
          searchError: next.error,
        ),
      );
    });

    return LocationInputState(
      callbacks: LocationInputCardCallbacks(
        onOriginTextChanged: (value) {
          updateText(true, value);
          ref.read(locationSearchProvider.notifier).updateKeyword(value);
        },
        onDestinationTextChanged: (value) {
          updateText(false, value);
          ref.read(locationSearchProvider.notifier).updateKeyword(value);
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
    ref.read(locationSearchProvider.notifier).clearSearch();
    state = state.copyWith(
      list: state.list.copyWith(
        listVisible: false,
      ),
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
    _hasShownList = false;
    ref.read(locationSearchProvider.notifier).clearSearch();
    state = const LocationInputState();
  }
}

final locationInputProvider =
    NotifierProvider<LocationInputNotifier, LocationInputState>(
  LocationInputNotifier.new,
);