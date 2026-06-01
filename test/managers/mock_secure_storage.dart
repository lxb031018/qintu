import 'package:qintu/features/auth/core/secure_storage.dart';
import 'package:qintu/models/auth/login_info.dart';

/// 手写的 `ISecureStorage` 测试用 fake
///
/// 设计目标：
/// - 不引入 mocktail（保持依赖最小）
/// - 关键方法暴露"是否被调用"和"调用参数"以便断言
/// - 默认所有方法返回 `Future.value(null)`，调用方拿到 null 时按未登录处理
class MockSecureStorage implements ISecureStorage {
  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  bool _loggedIn = false;

  // —— saveTokens 调用记录 ——
  int saveTokensCallCount = 0;
  String? lastAccessToken;
  String? lastRefreshToken;
  int? lastAccessTokenExpiresIn;
  int? lastRefreshTokenExpiresIn;
  String? lastPhoneNumber;
  String? lastUserId;

  // —— clearTokens 调用记录 ——
  int clearTokensCallCount = 0;

  // —— getAccessToken / getRefreshToken / getUserId 预设返回值 ——
  void setAccessToken(String? token) => _accessToken = token;
  void setRefreshToken(String? token) => _refreshToken = token;
  void setUserId(String? userId) => _userId = userId;
  void setLoggedIn(bool value) => _loggedIn = value;

  // —— 错误注入 ——
  Exception? saveTokensException;
  Exception? clearTokensException;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int accessTokenExpiresIn,
    required int refreshTokenExpiresIn,
    required String phoneNumber,
    required String userId,
  }) async {
    saveTokensCallCount++;
    lastAccessToken = accessToken;
    lastRefreshToken = refreshToken;
    lastAccessTokenExpiresIn = accessTokenExpiresIn;
    lastRefreshTokenExpiresIn = refreshTokenExpiresIn;
    lastPhoneNumber = phoneNumber;
    lastUserId = userId;
    if (saveTokensException != null) throw saveTokensException!;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<String?> getUserId() async => _userId;

  @override
  Future<bool> isLoggedIn() async => _loggedIn;

  @override
  Future<void> clearTokens() async {
    clearTokensCallCount++;
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _loggedIn = false;
    if (clearTokensException != null) throw clearTokensException!;
  }

  @override
  Future<LoginInfo?> getLoginInfo() async {
    final accessToken = _accessToken;
    if (accessToken == null) return null;
    return LoginInfo.fromStorage(
      accessToken: accessToken,
      refreshToken: _refreshToken,
      expiresIn: null,
      phoneNumber: null,
      userId: _userId,
      accessTokenSaveTime: null,
      refreshTokenSaveTime: null,
    );
  }
}
