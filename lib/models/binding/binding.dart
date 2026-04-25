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

  /// 绑定码（已废弃，保留向后兼容）
  @JsonKey(name: 'bind_code', includeIfNull: false)
  final String? bindCode;

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
    this.bindCode,
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

/// 待确认的绑定请求
@JsonSerializable()
class PendingRequest {
  final int id;

  @JsonKey(name: 'sender_name')
  final String? senderName;

  @JsonKey(name: 'sender_phone')
  final String? senderPhone;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'expired_at')
  final DateTime expiredAt;

  const PendingRequest({
    required this.id,
    this.senderName,
    this.senderPhone,
    required this.createdAt,
    required this.expiredAt,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json) => _$PendingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PendingRequestToJson(this);

  Duration get timeRemaining => expiredAt.difference(DateTime.now());
  bool get isExpiringSoon => timeRemaining.inHours > 0 && timeRemaining.inHours < 24;
  bool get isExpired => timeRemaining.isNegative;
}

/// 我发出的绑定请求
@JsonSerializable()
class SentRequest {
  final int id;
  final String status;

  @JsonKey(name: 'receiver_nickname')
  final String? receiverNickname;

  @JsonKey(name: 'receiver_phone')
  final String? receiverPhone;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'expired_at')
  final DateTime? expiredAt;

  @JsonKey(name: 'rejected_at')
  final DateTime? rejectedAt;

  const SentRequest({
    required this.id,
    required this.status,
    this.receiverNickname,
    this.receiverPhone,
    required this.createdAt,
    this.expiredAt,
    this.rejectedAt,
  });

  factory SentRequest.fromJson(Map<String, dynamic> json) => _$SentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SentRequestToJson(this);

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'revoked' && rejectedAt != null;
  bool get isUnbound => status == 'revoked' && rejectedAt == null;
  bool get isExpired => status == 'expired';
  bool get isActive => status == 'active';

  /// 显示用的状态文本
  String get statusText {
    switch (status) {
      case 'pending':
        return '待确认';
      case 'revoked':
        return isRejected ? '已拒绝' : '已解除';
      case 'expired':
        return '已过期';
      case 'active':
        return '已激活';
      default:
        return '未知状态';
    }
  }

  /// 过期时间显示文本
  String get expiredAtText {
    if (isTimeExpired) return '已过期';
    if (!isPending) return statusText;
    if (expiredAt == null) return '已过期';
    final hours = timeRemaining.inHours;
    if (hours < 1) return '不足1小时';
    if (hours < 24) return '$hours 小时后过期';
    final days = (hours / 24).ceil();
    return '$days 天后过期';
  }

  Duration get timeRemaining {
    if (expiredAt == null) return Duration.zero;
    return expiredAt!.difference(DateTime.now());
  }

  bool get isExpiringSoon => isPending && timeRemaining.inHours > 0 && timeRemaining.inHours < 24;
  bool get isTimeExpired => isPending && timeRemaining.isNegative;
}

/// 绑定者位置信息
@JsonSerializable()
class BindingLocation {
  final double latitude;
  final double longitude;
  final int? accuracy;
  final int? timestamp;
  final String? address;
  final bool isSharing;
  final int? distanceToDestination;

  const BindingLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.timestamp,
    this.address,
    this.isSharing = true,
    this.distanceToDestination,
  });

  factory BindingLocation.fromJson(Map<String, dynamic> json) =>
      _$BindingLocationFromJson(json);

  Map<String, dynamic> toJson() => _$BindingLocationToJson(this);

  /// 是否有效（有时间戳且在 5 分钟内）
  bool get isValid {
    if (timestamp == null) return false;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp!;
    return age < 5 * 60 * 1000; // 5 分钟
  }
}
