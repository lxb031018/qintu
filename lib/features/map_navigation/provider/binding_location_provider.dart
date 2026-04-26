import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/models/binding/binding.dart';
import '../core/binding_location_api.dart'; // 仅导入类型 BindingLocationResult
import '../service/binding_location_service.dart';

/// ============================================
/// 绑定者位置 Provider
///
/// 管理绑定者位置的状态和加载逻辑
/// ============================================

/// 绑定者位置状态
class BinderLocationState {
  /// 绑定者 openid -> 位置结果
  final Map<String, BindingLocation> locations;

  /// 加载中的 openid 列表
  final Set<String> loadingOpenids;

  /// 错误信息
  final Map<String, String> errors;

  const BinderLocationState({
    this.locations = const {},
    this.loadingOpenids = const {},
    this.errors = const {},
  });

  BinderLocationState copyWith({
    Map<String, BindingLocation>? locations,
    Set<String>? loadingOpenids,
    Map<String, String>? errors,
  }) {
    return BinderLocationState(
      locations: locations ?? this.locations,
      loadingOpenids: loadingOpenids ?? this.loadingOpenids,
      errors: errors ?? this.errors,
    );
  }

  /// 获取指定绑定者的位置
  BindingLocation? getLocation(String openid) => locations[openid];

  /// 指定绑定者是否正在加载
  bool isLoading(String openid) => loadingOpenids.contains(openid);

  /// 指定绑定者是否有错误
  String? getError(String openid) => errors[openid];

  /// 是否有任何有效位置
  bool get hasAnyLocation => locations.isNotEmpty;
}

/// 绑定者位置 Notifier
class BinderLocationNotifier extends Notifier<BinderLocationState> {
  final BindingLocationService _service = bindingLocationService;
  bool _disposed = false;

  @override
  BinderLocationState build() {
    ref.onDispose(() {
      _disposed = true;
    });
    return const BinderLocationState();
  }

  /// 加载单个绑定者的位置
  Future<BindingLocationResult> loadBinderLocation(
    String openid, {
    String? binderName,
  }) async {
    // 标记为加载中
    state = state.copyWith(
      loadingOpenids: {...state.loadingOpenids, openid},
      errors: Map.from(state.errors)..remove(openid),
    );

    try {
      final result = await _service.getBinderLocation(openid);

      if (_disposed) return result;

      if (result.isSuccess && result.location != null) {
        state = state.copyWith(
          locations: {...state.locations, openid: result.location!},
          loadingOpenids: Set.from(state.loadingOpenids)..remove(openid),
        );
      } else {
        state = state.copyWith(
          loadingOpenids: Set.from(state.loadingOpenids)..remove(openid),
        );
      }

      return result;
    } catch (e) {
      if (_disposed) {
        return BindingLocationResult.error(e.toString());
      }

      state = state.copyWith(
        loadingOpenids: Set.from(state.loadingOpenids)..remove(openid),
        errors: {...state.errors, openid: e.toString()},
      );

      return BindingLocationResult.error(e.toString());
    }
  }

  /// 批量加载多个绑定者的位置
  Future<void> loadBinderLocations(List<({String openid, String? name})> binders) async {
    if (binders.isEmpty) return;

    // 标记所有为加载中
    state = state.copyWith(
      loadingOpenids: binders.map((b) => b.openid).toSet(),
    );

    final results = await _service.getBinderLocations(
      binders.map((b) => b.openid).toList(),
    );

    if (_disposed) return;

    final newLocations = Map<String, BindingLocation>.from(state.locations);
    final newErrors = Map<String, String>.from(state.errors);
    final loadingOpenids = Set<String>.from(state.loadingOpenids);

    for (final entry in results.entries) {
      loadingOpenids.remove(entry.key);
      if (entry.value.isSuccess && entry.value.location != null) {
        newLocations[entry.key] = entry.value.location!;
      } else if (entry.value.isError) {
        newErrors[entry.key] = entry.value.errorMessage ?? '未知错误';
      }
    }

    state = state.copyWith(
      locations: newLocations,
      loadingOpenids: loadingOpenids,
      errors: newErrors,
    );
  }

  /// 清除指定绑定者的位置
  void clearLocation(String openid) {
    final newLocations = Map<String, BindingLocation>.from(state.locations);
    newLocations.remove(openid);
    state = state.copyWith(locations: newLocations);
  }

  /// 清除所有位置
  void clearAll() {
    state = const BinderLocationState();
  }
}

/// Provider 导出
final binderLocationProvider =
    NotifierProvider<BinderLocationNotifier, BinderLocationState>(
  BinderLocationNotifier.new,
);
