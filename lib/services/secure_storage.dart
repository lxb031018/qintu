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

  /// 保存登录信息
  ///
  /// [accessToken] 访问令牌（安全存储）
  /// [refreshToken] 刷新令牌（安全存储）
  /// [expiresIn] 过期时间（秒）
  /// [phoneNumber] 手机号
  /// [userId] 用户 ID
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required String phoneNumber,
    required String userId,
  }) async {
    // 敏感数据使用安全存储
    await _secureStorage.write(key: AppConfig.accessTokenKey, value: accessToken);
    await _secureStorage.write(key: AppConfig.refreshTokenKey, value: refreshToken);

    // 非敏感数据使用普通存储
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConfig.expiresInKey, expiresIn);
    await prefs.setString(AppConfig.phoneNumberKey, phoneNumber);
    await prefs.setString(AppConfig.userIdKey, userId);
    await prefs.setInt(AppConfig.saveTimeKey, DateTime.now().millisecondsSinceEpoch);

    Logger.database('Token 已安全保存');
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
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.phoneNumberKey);
  }

  /// 获取用户 ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.userIdKey);
  }

  /// 检查是否已登录
  static Future<bool> isLoggedIn() async {
    final accessToken = await _secureStorage.read(key: AppConfig.accessTokenKey);
    if (accessToken == null) {
      return false;
    }

    // 检查是否过期
    final prefs = await SharedPreferences.getInstance();
    final saveTime = prefs.getInt(AppConfig.saveTimeKey);
    final expiresIn = prefs.getInt(AppConfig.expiresInKey);

    if (saveTime != null && expiresIn != null) {
      final saveDateTime = DateTime.fromMillisecondsSinceEpoch(saveTime);
      final expireDateTime = saveDateTime.add(Duration(seconds: expiresIn));
      final now = DateTime.now();

      if (now.isAfter(expireDateTime)) {
        Logger.warning('Token 已过期');
        return false;
      }
    }

    return true;
  }

  /// 清除登录状态（退出登录）
  static Future<void> clearTokens() async {
    // 清除安全存储
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);

    // 清除普通存储
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.expiresInKey);
    await prefs.remove(AppConfig.phoneNumberKey);
    await prefs.remove(AppConfig.userIdKey);
    await prefs.remove(AppConfig.saveTimeKey);

    Logger.database('Token 已清除');
  }

  /// 获取完整的登录信息
  static Future<Map<String, dynamic>?> getLoginInfo() async {
    final accessToken = await _secureStorage.read(key: AppConfig.accessTokenKey);
    if (accessToken == null) {
      return null;
    }

    final refreshToken = await _secureStorage.read(key: AppConfig.refreshTokenKey);
    final prefs = await SharedPreferences.getInstance();

    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': prefs.getInt(AppConfig.expiresInKey),
      'phone_number': prefs.getString(AppConfig.phoneNumberKey),
      'user_id': prefs.getString(AppConfig.userIdKey),
      'save_time': prefs.getInt(AppConfig.saveTimeKey),
    };
  }
}