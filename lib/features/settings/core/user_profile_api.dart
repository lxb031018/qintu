import '../../../constants/api_endpoints.dart';
import '../../../core/http/api_client.dart';
import 'user_profile.dart';

/// 用户资料 API 层
class UserProfileApi {
  /// 获取当前用户资料
  static Future<UserProfile?> getCurrentUser() async {
    final response = await ApiClient().get(ApiEndpoints.getCurrentUser);
    if (response.success && response.data != null) {
      return UserProfile.fromJson(response.data['data']);
    }
    return null;
  }

  /// 更新用户资料
  static Future<bool> updateProfile({String? nickname, String? avatarUrl}) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;

    final response = await ApiClient().put(
      ApiEndpoints.updateUser,
      data: data,
    );
    return response.success;
  }

  /// 更新最后登录时间（每次打开App时调用）
  static Future<bool> updateLastLogin() async {
    final response = await ApiClient().post(ApiEndpoints.updateLastLogin);
    return response.success;
  }
}