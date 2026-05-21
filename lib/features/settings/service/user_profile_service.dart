import 'dart:typed_data';
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

  /// 上传头像并更新（返回URL）
  static Future<String?> uploadAvatarBytes(Uint8List bytes) async {
    return await AvatarApi.uploadAvatarBytes(bytes);
  }
}