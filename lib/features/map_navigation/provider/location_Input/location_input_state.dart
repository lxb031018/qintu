import '../models/poi_models.dart';
import '../models/amap_routing_models.dart';
import 'location_category.dart';
import 'location_input_callbacks.dart';
import '../../../models/location/lat_lng.dart';

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

class LocationInputFieldState {
  final InputFieldState origin;
  final InputFieldState destination;
  final bool isOriginFocused;

  const LocationInputFieldState({
    this.origin = const InputFieldState(),
    this.destination = const InputFieldState(),
    this.isOriginFocused = true,
  });

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

  LocationInputFieldState copyWith({
    InputFieldState? origin,
    InputFieldState? destination,
    bool? isOriginFocused,
    bool clearOrigin = false,
    bool clearDestination = false,
  }) {
    return LocationInputFieldState(
      origin: clearOrigin ? const InputFieldState() : (origin ?? this.origin),
      destination: clearDestination ? const InputFieldState() : (destination ?? this.destination),
      isOriginFocused: isOriginFocused ?? this.isOriginFocused,
    );
  }
}

class LocationListState {
  final bool listVisible;
  final String searchKeyword;
  final List<PoiSuggestion> searchResults;
  final bool isSearching;
  final String? searchError;
  final LocationCategory selectedCategory;

  const LocationListState({
    this.listVisible = false,
    this.searchKeyword = '',
    this.searchResults = const [],
    this.isSearching = false,
    this.searchError,
    this.selectedCategory = LocationCategory.recommended,
  });

  LocationListState copyWith({
    bool? listVisible,
    String? searchKeyword,
    List<PoiSuggestion>? searchResults,
    bool? isSearching,
    String? searchError,
    LocationCategory? selectedCategory,
    bool clearSearchError = false,
  }) {
    return LocationListState(
      listVisible: listVisible ?? this.listVisible,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchError: clearSearchError ? null : (searchError ?? this.searchError),
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class LocationItemsState {
  final List<PoiSuggestion> historyItems;
  final bool isLoadingHistory;
  final List<PoiSuggestion> binderItems;
  final bool isLoadingBinderItems;

  const LocationItemsState({
    this.historyItems = const [],
    this.isLoadingHistory = false,
    this.binderItems = const [],
    this.isLoadingBinderItems = false,
  });

  LocationItemsState copyWith({
    List<PoiSuggestion>? historyItems,
    bool? isLoadingHistory,
    List<PoiSuggestion>? binderItems,
    bool? isLoadingBinderItems,
  }) {
    return LocationItemsState(
      historyItems: historyItems ?? this.historyItems,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      binderItems: binderItems ?? this.binderItems,
      isLoadingBinderItems: isLoadingBinderItems ?? this.isLoadingBinderItems,
    );
  }
}

class LocationSelectionState {
  final Set<String> selectedHistoryIds;
  final bool isHistorySelectionMode;

  const LocationSelectionState({
    this.selectedHistoryIds = const {},
    this.isHistorySelectionMode = false,
  });

  LocationSelectionState copyWith({
    Set<String>? selectedHistoryIds,
    bool? isHistorySelectionMode,
  }) {
    return LocationSelectionState(
      selectedHistoryIds: selectedHistoryIds ?? this.selectedHistoryIds,
      isHistorySelectionMode: isHistorySelectionMode ?? this.isHistorySelectionMode,
    );
  }
}

class LocationNaviTriggerState {
  final PoiSuggestion? pendingNaviPoi;

  const LocationNaviTriggerState({
    this.pendingNaviPoi,
  });

  LocationNaviTriggerState copyWith({
    PoiSuggestion? pendingNaviPoi,
    bool clearPendingNaviPoi = false,
  }) {
    return LocationNaviTriggerState(
      pendingNaviPoi: clearPendingNaviPoi ? null : (pendingNaviPoi ?? this.pendingNaviPoi),
    );
  }
}

class LocationInputState {
  final LocationInputFieldState fields;
  final LocationListState list;
  final LocationItemsState items;
  final LocationSelectionState selection;
  final LocationNaviTriggerState naviTrigger;
  final LocationInputCardCallbacks? callbacks;

  const LocationInputState({
    this.fields = const LocationInputFieldState(),
    this.list = const LocationListState(),
    this.items = const LocationItemsState(),
    this.selection = const LocationSelectionState(),
    this.naviTrigger = const LocationNaviTriggerState(),
    this.callbacks,
  });

  InputFieldState get origin => fields.origin;
  InputFieldState get destination => fields.destination;
  bool get isOriginFocused => fields.isOriginFocused;
  LatLng? get searchCenter => fields.searchCenter;

  bool get listVisible => list.listVisible;
  String get searchKeyword => list.searchKeyword;
  List<PoiSuggestion> get searchResults => list.searchResults;
  bool get isSearching => list.isSearching;
  String? get searchError => list.searchError;
  LocationCategory get selectedCategory => list.selectedCategory;

  List<PoiSuggestion> get historyItems => items.historyItems;
  bool get isLoadingHistory => items.isLoadingHistory;
  List<PoiSuggestion> get binderItems => items.binderItems;
  bool get isLoadingBinderItems => items.isLoadingBinderItems;

  Set<String> get selectedHistoryIds => selection.selectedHistoryIds;
  bool get isHistorySelectionMode => selection.isHistorySelectionMode;

  PoiSuggestion? get pendingNaviPoi => naviTrigger.pendingNaviPoi;

  LocationInputState copyWith({
    LocationInputFieldState? fields,
    LocationListState? list,
    LocationItemsState? items,
    LocationSelectionState? selection,
    LocationNaviTriggerState? naviTrigger,
    LocationInputCardCallbacks? callbacks,
    bool clearOrigin = false,
    bool clearDestination = false,
    bool clearPendingNaviPoi = false,
  }) {
    return LocationInputState(
      fields: clearOrigin || clearDestination
          ? fields?.copyWith(
              clearOrigin: clearOrigin,
              clearDestination: clearDestination,
            ) ?? LocationInputFieldState(
              origin: clearOrigin ? const InputFieldState() : const InputFieldState(),
              destination: clearDestination ? const InputFieldState() : const InputFieldState(),
            )
          : (fields ?? this.fields),
      list: list ?? this.list,
      items: items ?? this.items,
      selection: selection ?? this.selection,
      naviTrigger: clearPendingNaviPoi
          ? const LocationNaviTriggerState()
          : (naviTrigger ?? this.naviTrigger),
      callbacks: callbacks ?? this.callbacks,
    );
  }
}