import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_result.freezed.dart';

// 认证结果模型 - 用户登录成功后返回的认证信息

@freezed
class AuthResult with _$AuthResult {
  const factory AuthResult({
    @Default('') String accessToken,
    @Default('') String refreshToken,
    @Default(0) int accessTokenExpiresIn,
    @Default(0) int refreshTokenExpiresIn,
    @Default('') String uid,
    @Default(0) int pendingCount,
  }) = _AuthResult;

  const AuthResult._();

  // Getters implemented to satisfy mixin - delegates to _AuthResult
  @override
  String get accessToken => this is _AuthResult ? (this as _AuthResult).accessToken : '';
  @override
  String get refreshToken => this is _AuthResult ? (this as _AuthResult).refreshToken : '';
  @override
  int get accessTokenExpiresIn => this is _AuthResult ? (this as _AuthResult).accessTokenExpiresIn : 0;
  @override
  int get refreshTokenExpiresIn => this is _AuthResult ? (this as _AuthResult).refreshTokenExpiresIn : 0;
  @override
  String get uid => this is _AuthResult ? (this as _AuthResult).uid : '';
  @override
  int get pendingCount => this is _AuthResult ? (this as _AuthResult).pendingCount : 0;

  /// 从 JSON 创建实例
  factory AuthResult.fromJson(Map<String, dynamic> json) {
    // CloudBase Auth v2 API 响应格式:
    // - access_token: 访问令牌
    // - refresh_token: 刷新令牌
    // - expires_in: Access Token 有效期（秒）
    // - 注意：CloudBase Auth v2 不返回 refresh_expires_in
    //   Refresh Token 有效期需要使用默认值（AuthConfig.refreshTokenExpiresIn）
    return AuthResult(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      accessTokenExpiresIn: json['expires_in'] ?? 0,
      refreshTokenExpiresIn: 0, // CloudBase 不返回此字段，使用 0 表示需要使用默认值
      uid: json['openid'] ?? json['sub'] ?? json['uid'] ?? '',
      pendingCount: json['pending_count'] ?? 0,
    );
  }

  /// 检查 Access Token 是否已过期
  bool get isAccessTokenExpired {
    return DateTime.now().isAfter(accessTokenExpiresAt);
  }

  /// 检查 Refresh Token 是否已过期
  bool get isRefreshTokenExpired {
    return DateTime.now().isAfter(refreshTokenExpiresAt);
  }

  /// Access Token 过期时间
  DateTime get accessTokenExpiresAt {
    return DateTime.now().add(Duration(seconds: accessTokenExpiresIn));
  }

  /// Refresh Token 过期时间
  DateTime get refreshTokenExpiresAt {
    return DateTime.now().add(Duration(seconds: refreshTokenExpiresIn));
  }
}