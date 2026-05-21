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

  /// 上传头像并更新（后端已处理数据库更新）
  static Future<String?> uploadAndUpdateAvatar(String filePath) async {
    // 后端 avatar.routes.js 已处理：
    // 1. 保存文件到 uploads/avatars/
    // 2. 删除旧头像文件
    // 3. 更新 users.avatar_url
    // 前端只需获取上传后的 URL
    return await AvatarApi.uploadAvatar(filePath);
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