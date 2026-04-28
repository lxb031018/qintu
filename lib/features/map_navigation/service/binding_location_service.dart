import '../core/binding_location_api.dart';

/// ============================================
/// 绑定者位置 Service
///
/// 业务逻辑层，封装 BindingLocationApi 调用
/// 不持有 UI 状态，只负责获取绑定者位置的业务逻辑
///
/// 提供缓存能力（TTL 30秒）
/// ============================================

class BindingLocationService {
  final BindingLocationApi _api = BindingLocationApi();

  /// 缓存（key: openid）
  final Map<String, _CachedBinding> _cache = {};
  static const _cacheExpirySeconds = 30;

  /// 获取绑定者的位置（带缓存）
  Future<BindingLocationResult> getBinderLocation(String partnerOpenid) async {
    // 检查缓存
    if (_cache.containsKey(partnerOpenid)) {
      final cached = _cache[partnerOpenid]!;
      final age = DateTime.now().difference(cached.timestamp);
      if (age.inSeconds < _cacheExpirySeconds) {
        return cached.result;
      }
    }

    final result = await _api.getBinderLocation(partnerOpenid);
    if (result.isSuccess) {
      _cache[partnerOpenid] = _CachedBinding(
        result: result,
        timestamp: DateTime.now(),
      );
    }
    return result;
  }

  /// 批量获取多个绑定者的位置（优先从缓存读取）
  Future<Map<String, BindingLocationResult>> getBinderLocations(
    List<String> partnerOpenids,
  ) async {
    final results = <String, BindingLocationResult>{};
    final toFetch = <String>[];

    // 优先从缓存读取
    for (final openid in partnerOpenids) {
      if (_cache.containsKey(openid)) {
        final cached = _cache[openid]!;
        final age = DateTime.now().difference(cached.timestamp);
        if (age.inSeconds < _cacheExpirySeconds) {
          results[openid] = cached.result;
          continue;
        }
      }
      toFetch.add(openid);
    }

    // 批量获取未命中缓存的
    if (toFetch.isNotEmpty) {
      final fetched = await _api.getBinderLocations(toFetch);
      for (final entry in fetched.entries) {
        results[entry.key] = entry.value;
        if (entry.value.isSuccess) {
          _cache[entry.key] = _CachedBinding(
            result: entry.value,
            timestamp: DateTime.now(),
          );
        }
      }
    }

    return results;
  }
}

/// 缓存条目
class _CachedBinding {
  final BindingLocationResult result;
  final DateTime timestamp;
  _CachedBinding({required this.result, required this.timestamp});
}

/// 全局单例
final bindingLocationService = BindingLocationService();