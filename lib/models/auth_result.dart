// 认证结果模型 - 用户登录成功后返回的认证信息

class AuthResult {
  /// 访问令牌
  final String accessToken;

  /// 刷新令牌
  final String refreshToken;

  /// Token 有效期（秒）
  final int expiresIn;

  /// 用户 ID（从 sub 字段解析）
  final String uid;

  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.uid,
  });

  /// 从 JSON 创建实例
  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      uid: json['sub'] ?? '',
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'sub': uid,
    };
  }

  /// Token 过期时间
  DateTime get expiresAt {
    return DateTime.now().add(Duration(seconds: expiresIn));
  }

  /// 检查 Token 是否已过期
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  @override
  String toString() {
    final tokenPreview = accessToken.length > 20
        ? '${accessToken.substring(0, 20)}...'
        : accessToken;
    return 'AuthResult(uid: $uid, accessToken: $tokenPreview..., expiresIn: $expiresIn 秒)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResult && other.accessToken == accessToken;
  }

  @override
  int get hashCode => accessToken.hashCode;
}