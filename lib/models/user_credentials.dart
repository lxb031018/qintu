import '../utils/phone_utils.dart';

/// 用户凭据
///
/// 封装用户认证信息，用于页面导航时传递
/// 避免每次导航都重复传递 userId、phone、accessToken 等多个参数
class UserCredentials {
  final String userId;
  final String phone;
  final String accessToken;

  const UserCredentials({
    required this.userId,
    required this.phone,
    required this.accessToken,
  });

  /// 从 Map 创建（兼容旧代码）
  factory UserCredentials.fromMap(Map<String, dynamic> map) {
    return UserCredentials(
      userId: map['userId'] ?? map['user_id'] ?? '',
      phone: map['phone'] ?? map['phone_number'] ?? '',
      accessToken: map['accessToken'] ?? map['access_token'] ?? '',
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'phone': phone,
      'accessToken': accessToken,
    };
  }

  /// 复制并修改部分字段
  UserCredentials copyWith({
    String? userId,
    String? phone,
    String? accessToken,
  }) {
    return UserCredentials(
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  @override
  String toString() {
    return 'UserCredentials(userId: $userId, phone: ${PhoneUtils.maskPhone(phone)})';
  }
}
