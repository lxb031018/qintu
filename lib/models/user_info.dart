/// ============================================
/// 用户信息模型
///
/// 用户的详细信息
/// ============================================

class UserInfo {
  /// 用户唯一标识
  final String uid;

  /// 手机号
  final String phoneNumber;

  /// 注册时间
  final String createTime;

  /// 最后登录时间
  final String lastLoginTime;

  /// 登录次数
  final int loginCount;

  /// 用户角色（elder/junior）
  final String? role;

  /// 用户昵称
  final String? nickname;

  /// 头像 URL
  final String? avatarUrl;

  /// 构造函数
  UserInfo({
    required this.uid,
    required this.phoneNumber,
    required this.createTime,
    required this.lastLoginTime,
    required this.loginCount,
    this.role,
    this.nickname,
    this.avatarUrl,
  });

  /// 从 JSON 创建实例
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      uid: json['uid'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      createTime: json['create_time'] ?? '',
      lastLoginTime: json['last_login_time'] ?? '',
      loginCount: json['login_count'] ?? 0,
      role: json['role'],
      nickname: json['nickname'],
      avatarUrl: json['avatar_url'],
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phone_number': phoneNumber,
      'create_time': createTime,
      'last_login_time': lastLoginTime,
      'login_count': loginCount,
      'role': role,
      'nickname': nickname,
      'avatar_url': avatarUrl,
    };
  }

  /// 格式化注册时间
  String get formattedCreateTime {
    return _formatTime(createTime);
  }

  /// 格式化最后登录时间
  String get formattedLastLoginTime {
    return _formatTime(lastLoginTime);
  }

  /// 格式化时间字符串
  static String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '未知';
    try {
      final dateTime = DateTime.parse(timeStr);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeStr;
    }
  }

  /// 是否是长辈
  bool get isElder => role == 'elder';

  /// 是否是晚辈
  bool get isJunior => role == 'junior';

  /// 复制并修改
  UserInfo copyWith({
    String? uid,
    String? phoneNumber,
    String? createTime,
    String? lastLoginTime,
    int? loginCount,
    String? role,
    String? nickname,
    String? avatarUrl,
  }) {
    return UserInfo(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createTime: createTime ?? this.createTime,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      loginCount: loginCount ?? this.loginCount,
      role: role ?? this.role,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() {
    return 'UserInfo(uid: $uid, phone: $phoneNumber, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInfo && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}