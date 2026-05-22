import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../utils/logger.dart';
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

      Logs.map.info('获取到 ${bindings.length} 个绑定关系');
      for (final b in bindings) {
        Logs.map.info('Binding: partnerUserID=${b.partnerUserID}, status=${b.status}, nickname=${b.partnerNickname}');
      }

      final user_IDToNickname = <String, String>{};
      final user_IDs = <String>[];
      for (final binding in bindings) {
        final user_ID = binding.partnerUserID;
        if (user_ID == null) {
          Logs.map.warning('跳过 null partnerUserID 的绑定: status=${binding.status}');
          continue;
        }
        user_IDToNickname[user_ID] = (binding.myNameForPartner != null && binding.myNameForPartner!.isNotEmpty)
            ? binding.myNameForPartner!
            : (binding.partnerNickname ?? '绑定者');
        user_IDs.add(user_ID);
      }

      Logs.map.info('有效绑定者数量: ${user_IDs.length}, userIDs=$user_IDs');

      final locationResults = await _bindingService.getBinderLocations(user_IDs);
      Logs.map.info('位置查询结果: $locationResults');

      final binderDataList = _bindingService.convertToBinderDataList(user_IDToNickname, locationResults);
      Logs.map.info('转换后绑定者数据: $binderDataList');

      final items = _categoryService.getBinderLocations(binderDataList);

      state = state.copyWith(
        items: items,
        isLoading: false,
      );
    } catch (e) {
      Logs.map.error('加载绑定者位置失败: $e');
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