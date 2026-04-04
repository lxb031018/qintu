import 'package:json_annotation/json_annotation.dart';

part 'binding.g.dart';

/// 绑定状态
enum BindingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('expired')
  expired,
  @JsonValue('revoked')
  revoked,
}

/// 用户在绑定关系中的角色
enum MyRole {
  @JsonValue('sender')
  sender,
  @JsonValue('receiver')
  receiver,
}

/// 绑定关系数据模型
@JsonSerializable()
class Binding {
  /// 绑定关系 ID
  final int id;
  
  /// 绑定码（8 位字母数字）
  @JsonKey(name: 'bind_code')
  final String bindCode;
  
  /// 绑定状态
  final BindingStatus status;
  
  /// 备注
  final String? remark;
  
  /// 我在绑定关系中的角色
  @JsonKey(name: 'my_role')
  final MyRole? myRole;
  
  /// 对方 openid
  @JsonKey(name: 'partner_openid')
  final String? partnerOpenid;
  
  /// 对方昵称
  @JsonKey(name: 'partner_nickname')
  final String? partnerNickname;
  
  /// 对方手机号
  @JsonKey(name: 'partner_phone')
  final String? partnerPhone;
  
  /// 对方用户类型
  @JsonKey(name: 'partner_type')
  final String? partnerType;
  
  /// 发送者 openid（完整信息时包含）
  @JsonKey(name: 'sender_openid')
  final String? senderOpenid;
  
  /// 发送者昵称（完整信息时包含）
  @JsonKey(name: 'sender_nickname')
  final String? senderNickname;
  
  /// 发送者手机号（完整信息时包含）
  @JsonKey(name: 'sender_phone')
  final String? senderPhone;
  
  /// 接收者 openid（完整信息时包含）
  @JsonKey(name: 'receiver_openid')
  final String? receiverOpenid;
  
  /// 接收者昵称（完整信息时包含）
  @JsonKey(name: 'receiver_nickname')
  final String? receiverNickname;
  
  /// 接收者手机号（完整信息时包含）
  @JsonKey(name: 'receiver_phone')
  final String? receiverPhone;
  
  /// 创建时间
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  /// 更新时间
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  
  /// 过期时间
  @JsonKey(name: 'expired_at')
  final DateTime? expiredAt;

  const Binding({
    required this.id,
    required this.bindCode,
    required this.status,
    this.remark,
    this.myRole,
    this.partnerOpenid,
    this.partnerNickname,
    this.partnerPhone,
    this.partnerType,
    this.senderOpenid,
    this.senderNickname,
    this.senderPhone,
    this.receiverOpenid,
    this.receiverNickname,
    this.receiverPhone,
    required this.createdAt,
    this.updatedAt,
    this.expiredAt,
  });

  factory Binding.fromJson(Map<String, dynamic> json) => _$BindingFromJson(json);

  Map<String, dynamic> toJson() => _$BindingToJson(this);

  /// 绑定是否生效中
  bool get isActive => status == BindingStatus.active;

  /// 绑定是否已过期
  bool get isExpired {
    if (expiredAt != null) {
      return DateTime.now().isAfter(expiredAt!);
    }
    return status == BindingStatus.expired;
  }

  @override
  String toString() {
    return 'Binding(id: $id, bindCode: $bindCode, status: $status, partner: $partnerNickname)';
  }
}

/// 绑定关系列表响应
@JsonSerializable()
class BindingList {
  /// 总绑定数量
  final int total;
  
  /// 作为发送者的绑定数量
  @JsonKey(name: 'as_sender')
  final int asSender;
  
  /// 作为接收者的绑定数量
  @JsonKey(name: 'as_receiver')
  final int asReceiver;
  
  /// 绑定列表
  final List<Binding> bindings;

  const BindingList({
    required this.total,
    required this.asSender,
    required this.asReceiver,
    required this.bindings,
  });

  factory BindingList.fromJson(Map<String, dynamic> json) => _$BindingListFromJson(json);

  Map<String, dynamic> toJson() => _$BindingListToJson(this);
}
