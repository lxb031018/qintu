// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  openid: json['openid'] as String,
  phone: json['phone'] as String?,
  nickname: json['nickname'] as String?,
  userType: $enumDecode(_$UserRoleEnumMap, json['user_type']),
  avatarUrl: json['avatarUrl'] as String?,
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.active,
  lastLoginAt: json['last_login_at'] == null
      ? null
      : DateTime.parse(json['last_login_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'openid': instance.openid,
  'phone': instance.phone,
  'nickname': instance.nickname,
  'user_type': _$UserRoleEnumMap[instance.userType]!,
  'avatarUrl': instance.avatarUrl,
  'status': _$UserStatusEnumMap[instance.status]!,
  'last_login_at': instance.lastLoginAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$UserRoleEnumMap = {
  UserRole.sender: 'sender',
  UserRole.receiver: 'receiver',
  UserRole.both: 'both',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.disabled: 'disabled',
};
