// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'binding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Binding _$BindingFromJson(Map<String, dynamic> json) => Binding(
  id: (json['id'] as num).toInt(),
  bindCode: json['bind_code'] as String,
  status: $enumDecode(_$BindingStatusEnumMap, json['status']),
  remark: json['remark'] as String?,
  myRole: $enumDecodeNullable(_$MyRoleEnumMap, json['my_role']),
  partnerOpenid: json['partner_openid'] as String?,
  partnerNickname: json['partner_nickname'] as String?,
  partnerPhone: json['partner_phone'] as String?,
  partnerType: json['partner_type'] as String?,
  senderOpenid: json['sender_openid'] as String?,
  senderNickname: json['sender_nickname'] as String?,
  senderPhone: json['sender_phone'] as String?,
  receiverOpenid: json['receiver_openid'] as String?,
  receiverNickname: json['receiver_nickname'] as String?,
  receiverPhone: json['receiver_phone'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  expiredAt: json['expired_at'] == null
      ? null
      : DateTime.parse(json['expired_at'] as String),
);

Map<String, dynamic> _$BindingToJson(Binding instance) => <String, dynamic>{
  'id': instance.id,
  'bind_code': instance.bindCode,
  'status': _$BindingStatusEnumMap[instance.status]!,
  'remark': instance.remark,
  'my_role': _$MyRoleEnumMap[instance.myRole],
  'partner_openid': instance.partnerOpenid,
  'partner_nickname': instance.partnerNickname,
  'partner_phone': instance.partnerPhone,
  'partner_type': instance.partnerType,
  'sender_openid': instance.senderOpenid,
  'sender_nickname': instance.senderNickname,
  'sender_phone': instance.senderPhone,
  'receiver_openid': instance.receiverOpenid,
  'receiver_nickname': instance.receiverNickname,
  'receiver_phone': instance.receiverPhone,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'expired_at': instance.expiredAt?.toIso8601String(),
};

const _$BindingStatusEnumMap = {
  BindingStatus.pending: 'pending',
  BindingStatus.active: 'active',
  BindingStatus.expired: 'expired',
  BindingStatus.revoked: 'revoked',
};

const _$MyRoleEnumMap = {MyRole.sender: 'sender', MyRole.receiver: 'receiver'};

BindingList _$BindingListFromJson(Map<String, dynamic> json) => BindingList(
  total: (json['total'] as num).toInt(),
  asSender: (json['as_sender'] as num).toInt(),
  asReceiver: (json['as_receiver'] as num).toInt(),
  bindings: (json['bindings'] as List<dynamic>)
      .map((e) => Binding.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BindingListToJson(BindingList instance) =>
    <String, dynamic>{
      'total': instance.total,
      'as_sender': instance.asSender,
      'as_receiver': instance.asReceiver,
      'bindings': instance.bindings,
    };
