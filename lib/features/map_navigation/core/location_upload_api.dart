import 'package:qintu/core/http/api_client.dart';
import 'package:qintu/utils/logger.dart';

/// ============================================
/// 位置上传 API
///
/// 将本设备 GPS 位置上传到后端，供绑定者查询
/// ============================================

class LocationUploadApi {
  final ApiClient _apiClient;

  LocationUploadApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// 上传本设备位置到后端
  Future<void> uploadLocation({
    required double latitude,
    required double longitude,
    int? accuracy,
    int? speed,
    int? bearing,
    int? altitude,
    bool isNavigating = true,
  }) async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/api/locations/update',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          if (accuracy != null) 'accuracy': accuracy,
          if (speed != null) 'speed': speed,
          if (bearing != null) 'bearing': bearing,
          if (altitude != null) 'altitude': altitude,
          'is_navigating': isNavigating,
        },
      );
    } catch (e) {
      Logs.location.warning('上传位置失败: $e');
      rethrow;
    }
  }
}
