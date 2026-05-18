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
  /// [partnerOpenid] 绑定者的 user_ID
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
            partnerOpenid,
            BindingLocation.fromJson(data),
          );
        }
      }

      return BindingLocationResult.notSharing(partnerOpenid);
    } catch (e) {
      Logs.map.warning('获取绑定者位置失败: $e');
      return BindingLocationResult.error(partnerOpenid, e.toString());
    }
  }

  /// 批量获取多个绑定者的位置
  Future<Map<String, BindingLocationResult>> getBinderLocations(
    List<String> partnerOpenids,
  ) async {
    final results = <String, BindingLocationResult>{};

    // 并发请求所有绑定者位置
    final futures = partnerOpenids.map((user_ID) async {
      final result = await getBinderLocation(user_ID);
      return MapEntry(user_ID, result);
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
  final String user_ID;
  final BindingLocation? location;
  final BindingLocationStatus status;
  final String? errorMessage;

  const BindingLocationResult._({
    required this.user_ID,
    this.location,
    required this.status,
    this.errorMessage,
  });

  factory BindingLocationResult.success(String user_ID, BindingLocation location) =>
      BindingLocationResult._(
        user_ID: user_ID,
        location: location,
        status: BindingLocationStatus.success,
      );

  factory BindingLocationResult.notSharing(String user_ID) => BindingLocationResult._(
        user_ID: user_ID,
        status: BindingLocationStatus.notSharing,
      );

  factory BindingLocationResult.notFound(String user_ID) => BindingLocationResult._(
        user_ID: user_ID,
        status: BindingLocationStatus.notFound,
      );

  factory BindingLocationResult.error(String user_ID, String message) => BindingLocationResult._(
        user_ID: user_ID,
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
