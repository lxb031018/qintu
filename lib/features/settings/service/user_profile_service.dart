import '../core/user_profile_api.dart';
import '../core/user_profile.dart';
import '../core/avatar_api.dart';

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

  /// 上传头像并更新
  static Future<String?> uploadAndUpdateAvatar(String filePath) async {
    // 先上传头像
    final avatarUrl = await AvatarApi.uploadAvatar(filePath);
    if (avatarUrl == null) return null;

    // 再更新资料
    final success = await UserProfileApi.updateProfile(avatarUrl: avatarUrl);
    return success ? avatarUrl : null;
  }

  /// 更新头像URL（仅更新数据库，不上传）
  static Future<bool> updateAvatar(String avatarUrl) async {
    return await UserProfileApi.updateProfile(avatarUrl: avatarUrl);
  }

  /// 更新整个资料
  static Future<bool> updateProfile({String? nickname, String? avatarUrl}) async {
    return await UserProfileApi.updateProfile(nickname: nickname, avatarUrl: avatarUrl);
  }
}