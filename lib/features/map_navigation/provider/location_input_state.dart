import '../models/poi_models.dart';
import '../models/amap_routing_models.dart';
import 'location_category.dart';
import 'location_input_callbacks.dart';

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

class LocationInputState {
  final InputFieldState origin;
  final InputFieldState destination;
  final bool listVisible;
  final bool isOriginFocused;
  final String searchKeyword;
  final List<PoiSuggestion> searchResults;
  final bool isSearching;
  final String? searchError;
  final List<PoiSuggestion> historyItems;
  final bool isLoadingHistory;
  final List<PoiSuggestion> binderItems;
  final bool isLoadingBinderItems;
  final LocationCategory selectedCategory;
  final LocationInputCardCallbacks? callbacks;
  final Set<String> selectedHistoryIds;
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