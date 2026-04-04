import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// 用户角色类型
enum UserRole {
  @JsonValue('sender')
  sender,      // 发送者
  @JsonValue('receiver')
  receiver,    // 接收者
  @JsonValue('both')
  both,        // 两者皆可
}

/// 用户状态
enum UserStatus {
  @JsonValue('active')
  active,
  @JsonValue('disabled')
  disabled,
}

/// 用户数据模型
@JsonSerializable()
class User {
  /// CloudBase Auth 用户唯一标识
  final String openid;
  
  /// 手机号（带国家码：+86 13800138000）
  final String? phone;
  
  /// 用户昵称
  final String? nickname;
  
  /// 用户角色类型
  @JsonKey(name: 'user_type')
  final UserRole userType;
  
  /// 头像 URL
  final String? avatarUrl;
  
  /// 账号状态
  final UserStatus status;
  
  /// 最后登录时间
  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;
  
  /// 创建时间
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  /// 更新时间
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const User({
    required this.openid,
    this.phone,
    this.nickname,
    required this.userType,
    this.avatarUrl,
    this.status = UserStatus.active,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// 创建副本（用于更新部分字段）
  User copyWith({
    String? openid,
    String? phone,
    String? nickname,
    UserRole? userType,
    String? avatarUrl,
    UserStatus? status,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      openid: openid ?? this.openid,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      userType: userType ?? this.userType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 是否可以作为发送者
  bool get canBeSender => userType == UserRole.sender || userType == UserRole.both;

  /// 是否可以作为接收者
  bool get canBeReceiver => userType == UserRole.receiver || userType == UserRole.both;

  @override
  String toString() {
    return 'User(openid: $openid, nickname: $nickname, userType: $userType)';
  }
}
