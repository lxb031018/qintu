import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/poi_models.dart';
import '../../../service/binding_location_service.dart';
import '../../../service/location_category_service.dart';
import '../../../../relationship_binding/service/binding_service.dart';

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

/// ============================================
/// 绑定者位置 Notifier
///
/// 管理绑定者位置列表的加载：
/// - 从 BindingService 获取绑定关系
/// - 调用 BindingLocationService 获取各绑定者位置
/// - 转换为 POI 列表供 UI 显示
/// ============================================
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
      final bindingService = BindingService();
      final bindings = await bindingService.getBindingsList();

      final user_IDToNickname = <String, String>{};
      final user_IDs = <String>[];
      for (final binding in bindings) {
        final user_ID = binding.partnerUserID;
        if (user_ID == null) continue;
        user_IDToNickname[user_ID] = binding.partnerNickname ?? '绑定者';
        user_IDs.add(user_ID);
      }

      final locationResults = await _bindingService.getBinderLocations(user_IDs);
      final binderDataList = _bindingService.convertToBinderDataList(user_IDToNickname, locationResults);
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