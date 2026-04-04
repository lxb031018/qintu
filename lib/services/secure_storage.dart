import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// 安全存储服务 - 负责管理用户登录状态的持久化
///
/// 安全策略：
/// - 敏感数据（access_token, refresh_token）使用 FlutterSecureStorage
/// - 非敏感数据（expires_in, phone_number 等）使用 SharedPreferences

class SecureStorage {
  /// 安全存储实例
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// SharedPreferences 缓存实例
  static SharedPreferences? _prefsCache;

  /// 获取 SharedPreferences 实例（带缓存）
  static Future<SharedPreferences> _getPrefs() async {
    _prefsCache ??= await SharedPreferences.getInstance();
    return _prefsCache!;
  }

  /// 保存登录信息
  ///
  /// [accessToken] 访问令牌（安全存储）
  /// [refreshToken] 刷新令牌（安全存储）
  /// [accessTokenExpiresIn] Access Token 过期时间（秒）- 来自服务端
  /// [refreshTokenExpiresIn] Refresh Token 过期时间（秒）- 来自服务端
  /// [phoneNumber] 手机号
  /// [userId] 用户 ID
  /// [role] 用户角色（receiver/sender）- 未设置时使用默认配置
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int accessTokenExpiresIn,
    required int refreshTokenExpiresIn,
    required String phoneNumber,
    required String userId,
    String? role,
  }) async {
    // 敏感数据使用安全存储
    await _secureStorage.write(key: AppConfig.accessTokenKey, value: accessToken);
    await _secureStorage.write(key: AppConfig.refreshTokenKey, value: refreshToken);

    // 根据角色获取正确的 Refresh Token 有效期（优先使用角色配置）
    final effectiveRefreshTokenExpiresIn = AppConfig.getRefreshTokenExpiresIn(role);

    // 非敏感数据使用普通存储
    final prefs = await _getPrefs();
    await prefs.setInt(AppConfig.expiresInKey, effectiveRefreshTokenExpiresIn);
    await prefs.setString(AppConfig.phoneNumberKey, phoneNumber);
    await prefs.setString(AppConfig.userIdKey, userId);
    
    // 分别保存 Access Token 和 Refresh Token 的时间
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(AppConfig.accessTokenSaveTimeKey, now);
    await prefs.setInt(AppConfig.refreshTokenSaveTimeKey, now);

    // 存储用户角色
    if (role != null) {
      await prefs.setString(AppConfig.userRoleKey, role);
    }

    Logger.database('Token 已保存，角色: ${role ?? "未设置"}, Refresh Token 有效期: ${effectiveRefreshTokenExpiresIn}s (${effectiveRefreshTokenExpiresIn ~/ 86400}天)');
  }

  /// 获取 Access Token
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConfig.accessTokenKey);
  }

  /// 获取 Refresh Token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConfig.refreshTokenKey);
  }

  /// 获取手机号
  static Future<String?> getPhoneNumber() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConfig.phoneNumberKey);
  }

  /// 获取用户 ID
  static Future<String?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConfig.userIdKey);
  }

  /// 获取用户角色
  static Future<String?> getUserRole() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConfig.userRoleKey);
  }

  /// 保存用户角色（单独调用）
  /// 当用户选择角色时，需要更新 Refresh Token 的有效期
  static Future<void> saveRole(String role) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConfig.userRoleKey, role);

    // 更新 Refresh Token 保存时间和有效期（根据角色重新计算）
    await prefs.setInt(AppConfig.refreshTokenSaveTimeKey, DateTime.now().millisecondsSinceEpoch);
    
    // 更新 Refresh Token 有效期为角色配置
    final effectiveExpiresIn = AppConfig.getRefreshTokenExpiresIn(role);
    await prefs.setInt(AppConfig.expiresInKey, effectiveExpiresIn);

    Logger.database('角色已保存: $role, Refresh Token 有效期: ${effectiveExpiresIn}s (${effectiveExpiresIn ~/ 86400}天)');
  }

  /// 检查是否已登录
  static Future<bool> isLoggedIn() async {
    final accessToken = await _secureStorage.read(key: AppConfig.accessTokenKey);
    final refreshToken = await _secureStorage.read(key: AppConfig.refreshTokenKey);
    
    // Access Token 和 Refresh Token 都必须存在
    if (accessToken == null || refreshToken == null) {
      return false;
    }

    // 获取用户角色，根据角色判断 Refresh Token 有效期
    final prefs = await _getPrefs();
    final role = prefs.getString(AppConfig.userRoleKey);
    final refreshTokenSaveTime = prefs.getInt(AppConfig.refreshTokenSaveTimeKey);
    final refreshTokenExpiresIn = prefs.getInt(AppConfig.expiresInKey);

    if (refreshTokenSaveTime != null) {
      // 根据角色获取 Refresh Token 有效期
      final effectiveExpiresIn = _getEffectiveRefreshTokenExpiresIn(role, refreshTokenExpiresIn);

      final saveDateTime = DateTime.fromMillisecondsSinceEpoch(refreshTokenSaveTime);
      final expireDateTime = saveDateTime.add(Duration(seconds: effectiveExpiresIn));
      final now = DateTime.now();

      if (now.isAfter(expireDateTime)) {
        Logger.warning('Refresh Token 已过期（角色: ${role ?? "未设置"}），需要重新登录');
        return false;
      }
      
      Logger.auth('Token 有效（角色: ${role ?? "未设置"}），已登录');
    }

    return true;
  }

  /// 根据角色获取 Refresh Token 实际有效期
  static int _getEffectiveRefreshTokenExpiresIn(String? role, int? serverExpiresIn) {
    // 如果服务端返回的 Refresh Token 有效期存在，优先使用（适配服务端实际配置）
    if (serverExpiresIn != null && serverExpiresIn > 0) {
      return serverExpiresIn;
    }

    // 根据角色返回对应的 Refresh Token 有效期
    switch (role) {
      case 'receiver':
        return AppConfig.receiverRefreshTokenExpiresIn; // 1 年
      case 'sender':
        return AppConfig.senderRefreshTokenExpiresIn; // 30 天
      default:
        return AppConfig.refreshTokenExpiresIn; // 30 天（默认）
    }
  }

  /// 清除登录状态（退出登录）
  static Future<void> clearTokens() async {
    // 清除安全存储
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);

    // 清除普通存储
    final prefs = await _getPrefs();
    await prefs.remove(AppConfig.expiresInKey);
    await prefs.remove(AppConfig.phoneNumberKey);
    await prefs.remove(AppConfig.userIdKey);
    await prefs.remove(AppConfig.accessTokenSaveTimeKey);
    await prefs.remove(AppConfig.refreshTokenSaveTimeKey);
    await prefs.remove(AppConfig.userRoleKey);

    Logger.database('Token 已清除');
  }

  /// 获取完整的登录信息
  static Future<Map<String, dynamic>?> getLoginInfo() async {
    final accessToken = await _secureStorage.read(key: AppConfig.accessTokenKey);
    if (accessToken == null) {
      return null;
    }

    final refreshToken = await _secureStorage.read(key: AppConfig.refreshTokenKey);
    final prefs = await _getPrefs();

    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': prefs.getInt(AppConfig.expiresInKey),
      'phone_number': prefs.getString(AppConfig.phoneNumberKey),
      'user_id': prefs.getString(AppConfig.userIdKey),
      'user_role': prefs.getString(AppConfig.userRoleKey),
      'access_token_save_time': prefs.getInt(AppConfig.accessTokenSaveTimeKey),
      'refresh_token_save_time': prefs.getInt(AppConfig.refreshTokenSaveTimeKey),
    };
  }
}