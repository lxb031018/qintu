import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/poi_models.dart';
import '../../../service/binding_location_service.dart';
import '../../../service/location_category_service.dart';

class LocationBinderState {
  final List<PoiSuggestion> items;
  final bool isLoading;

  const LocationBinderState({
    this.items = const [],
    this.isLoading = false,
  });

  LocationBinderState copyWith({
    List<PoiSuggestion>? items,
    bool? isLoading,
  }) {
    return LocationBinderState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationBinderNotifier extends Notifier<LocationBinderState> {
  late final BindingLocationService _bindingService = ref.read(bindingLocationServiceProvider);
  late final LocationCategoryService _categoryService = ref.read(locationCategoryServiceProvider);

  @override
  LocationBinderState build() {
    return const LocationBinderState();
  }

  Future<void> loadBinderLocations() async {
    state = state.copyWith(isLoading: true);

    try {
      final binderDataList = await _bindingService.fetchBinderDataList();
      final items = _categoryService.getBinderLocations(binderDataList);

      state = state.copyWith(
        items: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        items: [],
        isLoading: false,
      );
    }
  }
}

final locationBinderProvider =
    NotifierProvider<LocationBinderNotifier, LocationBinderState>(
  LocationBinderNotifier.new,
);