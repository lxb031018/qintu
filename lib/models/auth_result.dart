// 认证结果模型 - 用户登录成功后返回的认证信息

class AuthResult {
  /// 访问令牌
  final String accessToken;

  /// 刷新令牌
  final String refreshToken;

  /// Access Token 有效期（秒）
  final int accessTokenExpiresIn;

  /// Refresh Token 有效期（秒）
  final int refreshTokenExpiresIn;

  /// 用户 ID（从 sub 字段解析）
  final String uid;

  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresIn,
    required this.refreshTokenExpiresIn,
    required this.uid,
  });

  /// 从 JSON 创建实例
  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      accessTokenExpiresIn: json['expires_in'] ?? 0,
      refreshTokenExpiresIn: json['refresh_expires_in'] ?? 0,
      uid: json['sub'] ?? '',
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': accessTokenExpiresIn,
      'refresh_expires_in': refreshTokenExpiresIn,
      'sub': uid,
    };
  }

  /// Access Token 过期时间
  DateTime get accessTokenExpiresAt {
    return DateTime.now().add(Duration(seconds: accessTokenExpiresIn));
  }

  /// Refresh Token 过期时间
  DateTime get refreshTokenExpiresAt {
    return DateTime.now().add(Duration(seconds: refreshTokenExpiresIn));
  }

  /// 检查 Access Token 是否已过期
  bool get isAccessTokenExpired {
    return DateTime.now().isAfter(accessTokenExpiresAt);
  }

  /// 检查 Refresh Token 是否已过期
  bool get isRefreshTokenExpired {
    return DateTime.now().isAfter(refreshTokenExpiresAt);
  }

  @override
  String toString() {
    // 安全考虑：不输出任何 token 内容，只输出非敏感信息
    return 'AuthResult(uid: $uid, accessTokenExpiresIn: $accessTokenExpiresIn 秒, refreshTokenExpiresIn: $refreshTokenExpiresIn 秒)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResult && other.accessToken == accessToken;
  }

  @override
  int get hashCode => accessToken.hashCode;
}