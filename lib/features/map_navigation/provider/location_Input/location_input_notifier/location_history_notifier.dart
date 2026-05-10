import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/utils/logger.dart';
import '../../models/poi_models.dart';
import '../../service/location_category_service.dart';

class LocationHistoryState {
  final List<PoiSuggestion> items;
  final bool isLoading;
  final Set<String> selectedIds;
  final bool isSelectionMode;

  const LocationHistoryState({
    this.items = const [],
    this.isLoading = false,
    this.selectedIds = const {},
    this.isSelectionMode = false,
  });

  LocationHistoryState copyWith({
    List<PoiSuggestion>? items,
    bool? isLoading,
    Set<String>? selectedIds,
    bool? isSelectionMode,
  }) {
    return LocationHistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      selectedIds: selectedIds ?? this.selectedIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }
}

class LocationHistoryNotifier extends Notifier<LocationHistoryState> {
  late final LocationCategoryService _categoryService = ref.read(locationCategoryServiceProvider);

  @override
  LocationHistoryState build() {
    return const LocationHistoryState();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);

    final items = await _categoryService.getHistoryLocations();

    state = state.copyWith(
      items: items,
      isLoading: false,
    );
  }

  void enterSelectionMode() {
    state = state.copyWith(isSelectionMode: true);
  }

  void exitSelectionMode() {
    state = state.copyWith(
      isSelectionMode: false,
      selectedIds: {},
    );
  }

  void toggleSelection(String poiId) {
    final newSet = Set<String>.from(state.selectedIds);
    if (newSet.contains(poiId)) {
      newSet.remove(poiId);
    } else {
      newSet.add(poiId);
    }
    state = state.copyWith(selectedIds: newSet);
  }

  void selectAll() {
    final allIds = state.items.map((poi) => poi.id).toSet();
    state = state.copyWith(selectedIds: allIds);
  }

  Future<void> deleteSelected() async {
    if (state.selectedIds.isEmpty) return;

    await _categoryService.deleteHistoryItems(state.selectedIds);

    final items = await _categoryService.getHistoryLocations();
    state = state.copyWith(
      items: items,
      selectedIds: {},
      isSelectionMode: false,
    );
  }

  Future<void> moveItemToTop(PoiSuggestion poi) async {
    if (poi.source != PoiSource.history) return;

    Logs.ui.debug('moveItemToTop: 开始处理历史 POI 置顶, poi.id=${poi.id}');
    final updatedHistory = List<PoiSuggestion>.from(state.items);
    updatedHistory.removeWhere((item) => item.id == poi.id);
    updatedHistory.insert(0, poi);
    state = state.copyWith(items: updatedHistory);
    await _categoryService.moveHistoryItemToTop(poi.id);
  }
}

final locationHistoryProvider =
    NotifierProvider<LocationHistoryNotifier, LocationHistoryState>(
  LocationHistoryNotifier.new,
);