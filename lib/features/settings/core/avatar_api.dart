import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../constants/api_endpoints.dart';
import '../../../core/http/api_client.dart';

/// 头像上传 API 层
class AvatarApi {
  /// 上传头像图片
  /// 返回上传后的访问路径
  static Future<String?> uploadAvatar(String filePath) async {
    final file = await MultipartFile.fromFile(
      filePath,
      contentType: MediaType('image', 'jpeg'),
    );
    final formData = FormData.fromMap({
      'avatar': file,
    });

    final response = await ApiClient().post(
      ApiEndpoints.uploadAvatar,
      data: formData,
    );

    if (response.success && response.data != null) {
      final data = response.data['data'];
      if (data != null && data['avatarUrl'] != null) {
        return data['avatarUrl'] as String?;
      }
    }
    return null;
  }

  /// 上传头像图片（字节数组）
  /// 返回上传后的访问路径
  static Future<String?> uploadAvatarBytes(List<int> bytes, {String filename = 'avatar.png'}) async {
    final file = MultipartFile.fromBytes(
      bytes,
      contentType: MediaType('image', 'png'),
      filename: filename,
    );
    final formData = FormData.fromMap({
      'avatar': file,
    });

    final response = await ApiClient().post(
      ApiEndpoints.uploadAvatar,
      data: formData,
    );

    if (response.success && response.data != null) {
      final data = response.data['data'];
      if (data != null && data['avatarUrl'] != null) {
        return data['avatarUrl'] as String?;
      }
    }
    return null;
  }
}