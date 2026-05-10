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
      final data = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'is_navigating': isNavigating,
      };
      if (accuracy != null) data['accuracy'] = accuracy;
      if (speed != null) data['speed'] = speed;
      if (bearing != null) data['bearing'] = bearing;
      if (altitude != null) data['altitude'] = altitude;

      await _apiClient.post<Map<String, dynamic>>(
        '/api/locations/update',
        data: data,
      );
    } catch (e) {
      Logs.location.warning('上传位置失败: $e');
      rethrow;
    }
  }

  /// 删除本设备的位置信息（定位关闭时调用）
  Future<void> deleteLocation() async {
    try {
      await _apiClient.delete('/api/locations');
      Logs.location.info('位置信息已删除');
    } catch (e) {
      Logs.location.warning('删除位置失败: $e');
      // 不抛出异常，因为定位关闭时位置信息本就不应该存在
    }
  }
}
