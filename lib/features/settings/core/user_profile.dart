/// 用户资料
class UserProfile {
  final String userId;
  final String phone;
  final String nickname;
  final String? avatarUrl;

  const UserProfile({
    required this.userId,
    required this.phone,
    required this.nickname,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      phone: json['phone'] ?? '',
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'phone': phone,
      'nickname': nickname,
      'avatar_url': avatarUrl,
    };
  }

  UserProfile copyWith({
    String? userId,
    String? phone,
    String? nickname,
    String? avatarUrl,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}