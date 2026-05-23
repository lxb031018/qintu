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
  /// [partnerUserID] 绑定者的 userId
  /// 返回位置信息，如果未共享或无位置返回 null
  Future<BindingLocationResult> getBinderLocation(String partnerUserID) async {
    try {
      Logs.map.info('获取绑定者位置: $partnerUserID');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/locations/$partnerUserID',
      );

      if (response.isSuccessful && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null && data.containsKey('latitude') && data.containsKey('longitude')) {
          return BindingLocationResult.success(
            partnerUserID,
            BindingLocation.fromJson(data),
          );
        }
      }

      return BindingLocationResult.notSharing(partnerUserID);
    } catch (e) {
      Logs.map.warning('获取绑定者位置失败: $e');
      return BindingLocationResult.error(partnerUserID, e.toString());
    }
  }

  /// 批量获取多个绑定者的位置
  Future<Map<String, BindingLocationResult>> getBinderLocations(
    List<String> partnerUserIDs,
  ) async {
    final results = <String, BindingLocationResult>{};

    // 并发请求所有绑定者位置
    final futures = partnerUserIDs.map((userId) async {
      final result = await getBinderLocation(userId);
      return MapEntry(userId, result);
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
  final String userId;
  final BindingLocation? location;
  final BindingLocationStatus status;
  final String? errorMessage;

  const BindingLocationResult._({
    required this.userId,
    this.location,
    required this.status,
    this.errorMessage,
  });

  factory BindingLocationResult.success(String userId, BindingLocation location) =>
      BindingLocationResult._(
        userId: userId,
        location: location,
        status: BindingLocationStatus.success,
      );

  factory BindingLocationResult.notSharing(String userId) => BindingLocationResult._(
        userId: userId,
        status: BindingLocationStatus.notSharing,
      );

  factory BindingLocationResult.notFound(String userId) => BindingLocationResult._(
        userId: userId,
        status: BindingLocationStatus.notFound,
      );

  factory BindingLocationResult.error(String userId, String message) => BindingLocationResult._(
        userId: userId,
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
