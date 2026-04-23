import 'package:qintu/core/http/api_client.dart';
import 'package:qintu/models/binding/binding.dart';
import 'package:qintu/utils/logger.dart';

/// ============================================
/// 绑定者位置 API
///
/// 获取绑定者的实时位置
/// ============================================

class BindingLocationApi {
  final ApiClient _apiClient;

  BindingLocationApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// 获取绑定者的位置
  ///
  /// [partnerOpenid] 绑定者的 openid
  /// 返回位置信息，如果未共享或无位置返回 null
  Future<BindingLocationResult> getBinderLocation(String partnerOpenid) async {
    try {
      Logs.map.info('获取绑定者位置: $partnerOpenid');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/locations/$partnerOpenid',
      );

      if (response.isSuccessful && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null) {
          return BindingLocationResult.success(
            BindingLocation.fromJson(data),
          );
        }
      }

      // 未共享或无位置
      return BindingLocationResult.notSharing();
    } catch (e) {
      Logs.map.warning('获取绑定者位置失败: $e');
      return BindingLocationResult.error(e.toString());
    }
  }

  /// 批量获取多个绑定者的位置
  Future<Map<String, BindingLocationResult>> getBinderLocations(
    List<String> partnerOpenids,
  ) async {
    final results = <String, BindingLocationResult>{};

    // 并发请求所有绑定者位置
    final futures = partnerOpenids.map((openid) async {
      final result = await getBinderLocation(openid);
      return MapEntry(openid, result);
    });

    final entries = await Future.wait(futures);
    for (final entry in entries) {
      results[entry.key] = entry.value;
    }

    return results;
  }
}

/// 绑定者位置查询结果
class BindingLocationResult {
  final BindingLocation? location;
  final BindingLocationStatus status;
  final String? errorMessage;

  const BindingLocationResult._({
    this.location,
    required this.status,
    this.errorMessage,
  });

  factory BindingLocationResult.success(BindingLocation location) =>
      BindingLocationResult._(
        location: location,
        status: BindingLocationStatus.success,
      );

  factory BindingLocationResult.notSharing() => BindingLocationResult._(
        status: BindingLocationStatus.notSharing,
      );

  factory BindingLocationResult.notFound() => BindingLocationResult._(
        status: BindingLocationStatus.notFound,
      );

  factory BindingLocationResult.error(String message) => BindingLocationResult._(
        status: BindingLocationStatus.error,
        errorMessage: message,
      );

  bool get isSuccess => status == BindingLocationStatus.success;
  bool get isNotSharing => status == BindingLocationStatus.notSharing;
  bool get isNotFound => status == BindingLocationStatus.notFound;
  bool get isError => status == BindingLocationStatus.error;
}

/// 绑定者位置状态
enum BindingLocationStatus {
  success,     // 成功获取位置
  notSharing,  // 绑定者未开启位置共享
  notFound,    // 未找到绑定者位置
  error,       // 获取失败
}
