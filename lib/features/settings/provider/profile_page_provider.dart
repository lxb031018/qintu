import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/user_profile.dart';
import '../service/user_profile_service.dart';
import '../../../providers/auth_state_manager.dart';

/// 个人信息编辑页状态
class ProfilePageState {
  final UserProfile? profile;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const ProfilePageState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  ProfilePageState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return ProfilePageState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

/// 个人信息编辑页 Notifier
class ProfilePageNotifier extends Notifier<ProfilePageState> {
  @override
  ProfilePageState build() {
    return const ProfilePageState();
  }

  /// 加载用户资料
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final profile = await UserProfileService.getCurrentUserProfile();
      if (profile != null) {
        state = state.copyWith(profile: profile, isLoading: false);
      } else {
        // 使用本地缓存的用户信息
        final authState = ref.read(authStateProvider);
        state = state.copyWith(
          profile: UserProfile(
            userId: authState.userId ?? '',
            phone: authState.phoneNumber ?? '',
            nickname: '',
          ),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 保存昵称
  Future<bool> saveNickname(String nickname) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final success = await UserProfileService.updateNickname(nickname);
      if (success && state.profile != null) {
        final updatedProfile = UserProfile(
          userId: state.profile!.userId,
          phone: state.profile!.phone,
          nickname: nickname,
          avatarUrl: state.profile!.avatarUrl,
        );
        state = state.copyWith(profile: updatedProfile, isSaving: false);
      } else {
        state = state.copyWith(isSaving: false, errorMessage: '保存失败');
      }
      return success;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  /// 保存头像
  Future<bool> saveAvatar(String avatarUrl) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final success = await UserProfileService.updateAvatar(avatarUrl);
      if (success && state.profile != null) {
        final updatedProfile = UserProfile(
          userId: state.profile!.userId,
          phone: state.profile!.phone,
          nickname: state.profile!.nickname,
          avatarUrl: avatarUrl,
        );
        state = state.copyWith(profile: updatedProfile, isSaving: false);
      } else {
        state = state.copyWith(isSaving: false, errorMessage: '保存失败');
      }
      return success;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  /// 上传并保存头像
  Future<bool> uploadAvatar(String filePath) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final avatarUrl = await UserProfileService.uploadAndUpdateAvatar(filePath);
      if (avatarUrl != null && state.profile != null) {
        final updatedProfile = UserProfile(
          userId: state.profile!.userId,
          phone: state.profile!.phone,
          nickname: state.profile!.nickname,
          avatarUrl: avatarUrl,
        );
        state = state.copyWith(profile: updatedProfile, isSaving: false);
        return true;
      } else {
        state = state.copyWith(isSaving: false, errorMessage: '上传失败');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }
}

/// Provider
final profilePageProvider = NotifierProvider<ProfilePageNotifier, ProfilePageState>(
  ProfilePageNotifier.new,
);