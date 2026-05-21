import '../core/user_profile_api.dart';
import '../core/user_profile.dart';

/// 用户资料服务层
class UserProfileService {
  /// 获取当前用户资料
  static Future<UserProfile?> getCurrentUserProfile() async {
    return await UserProfileApi.getCurrentUser();
  }

  /// 更新昵称
  static Future<bool> updateNickname(String nickname) async {
    return await UserProfileApi.updateProfile(nickname: nickname);
  }

  /// 更新头像
  static Future<bool> updateAvatar(String avatarUrl) async {
    return await UserProfileApi.updateProfile(avatarUrl: avatarUrl);
  }

  /// 更新整个资料
  static Future<bool> updateProfile({String? nickname, String? avatarUrl}) async {
    return await UserProfileApi.updateProfile(nickname: nickname, avatarUrl: avatarUrl);
  }
}