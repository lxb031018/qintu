import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/utils/logger.dart';
import '../../../models/poi_models.dart';
import '../../../service/poi_service.dart';
import '../../../service/map_controller_service/map_controller_service.dart';
import '../location_category.dart';
import '../../map_display/map_controller_provider.dart';
import '../../../../../models/location/lat_lng.dart';

class LocationSearchState {
  final String keyword;
  final List<PoiSuggestion> results;
  final bool isSearching;
  final String? error;
  final LocationCategory selectedCategory;

  const LocationSearchState({
    this.keyword = '',
    this.results = const [],
    this.isSearching = false,
    this.error,
    this.selectedCategory = LocationCategory.recommended,
  });

  LocationSearchState copyWith({
    String? keyword,
    List<PoiSuggestion>? results,
    bool? isSearching,
    String? error,
    LocationCategory? selectedCategory,
    bool clearError = false,
  }) {
    return LocationSearchState(
      keyword: keyword ?? this.keyword,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      error: clearError ? null : (error ?? this.error),
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class LocationSearchNotifier extends Notifier<LocationSearchState> {
  Timer? _debounceTimer;

  late final PoiService _poiService = ref.read(poiServiceProvider);
  MapControllerService? get _mapController => ref.read(mapControllerProvider);

  @override
  LocationSearchState build() {
    return const LocationSearchState();
  }

  void updateKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);

    _debounceTimer?.cancel();

    if (keyword.length < 2) {
      state = state.copyWith(
        results: [],
        isSearching: false,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(
      selectedCategory: LocationCategory.none,
      isSearching: true,
      clearError: true,
    );

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(keyword);
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = state.copyWith(
      keyword: '',
      results: [],
      isSearching: false,
      clearError: true,
      selectedCategory: LocationCategory.recommended,
    );
  }

  Future<void> _performSearch(String keyword) async {
    if (keyword != state.keyword) return;

    try {
      final context = await _buildSearchContext();

      final result = await _poiService.searchPoiWithLocation(
        keyword: keyword,
        context: context,
      );

      if (keyword != state.keyword) return;

      if (result.isSuccess) {
        Logs.ui.info('✅ 搜索到 ${result.suggestions.length} 条结果');
        state = state.copyWith(
          results: result.suggestions,
          isSearching: false,
        );
      } else {
        Logs.ui.info('🔍 未找到匹配的 POI 结果');
        state = state.copyWith(
          results: [],
          isSearching: false,
          error: result.error,
        );
      }
    } catch (e) {
      Logs.ui.error('❌ 搜索异常: $e');
      state = state.copyWith(
        results: [],
        isSearching: false,
        error: '搜索异常',
      );
    }
  }

  Future<LocationSearchContext> _buildSearchContext() async {
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
      gpsCenter: gpsCenter,
      cachedCity: cachedCity,
    );
  }
}

final locationSearchProvider =
    NotifierProvider<LocationSearchNotifier, LocationSearchState>(
  LocationSearchNotifier.new,
);