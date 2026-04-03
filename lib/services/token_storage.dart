import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_config.dart';
import '../constants/app_strings.dart';

/// ============================================
/// Token 存储服务
///
/// 负责管理用户登录状态的持久化：
/// - 保存 access_token 和 refresh_token
/// - 读取已保存的 token
/// - 清除登录状态（退出登录）
/// - 检查是否已登录
/// ============================================

class TokenStorage {
  /// ==========================================
  /// 保存登录信息
  /// ==========================================
  ///
  /// [accessToken] 访问令牌
  /// [refreshToken] 刷新令牌
  /// [expiresIn] 过期时间（秒）
  /// [phoneNumber] 手机号
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required String phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(AppConfig.accessTokenKey, accessToken);
    await prefs.setString(AppConfig.refreshTokenKey, refreshToken);
    await prefs.setInt(AppConfig.expiresInKey, expiresIn);
    await prefs.setString(AppConfig.phoneNumberKey, phoneNumber);
    await prefs.setInt(AppConfig.saveTimeKey, DateTime.now().millisecondsSinceEpoch);

    print('✅ Token 已保存');
  }

  /// ==========================================
  /// 获取 Access Token
  /// ==========================================
  ///
  /// 返回：access_token，如果不存在则返回 null
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.accessTokenKey);
  }

  /// ==========================================
  /// 获取 Refresh Token
  /// ==========================================
  ///
  /// 返回：refresh_token，如果不存在则返回 null
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.refreshTokenKey);
  }

  /// ==========================================
  /// 获取手机号
  /// ==========================================
  ///
  /// 返回：手机号，如果不存在则返回 null
  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.phoneNumberKey);
  }

  /// ==========================================
  /// 检查是否已登录
  /// ==========================================
  ///
  /// 检查逻辑：
  /// 1. 是否存在 access_token
  /// 2. token 是否过期（根据保存时间和有效期判断）
  ///
  /// 返回：true=已登录，false=未登录
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString(AppConfig.accessTokenKey);
    if (accessToken == null) {
      return false;
    }

    // 检查是否过期
    final saveTime = prefs.getInt(AppConfig.saveTimeKey);
    final expiresIn = prefs.getInt(AppConfig.expiresInKey);

    if (saveTime != null && expiresIn != null) {
      final saveDateTime = DateTime.fromMillisecondsSinceEpoch(saveTime);
      final expireDateTime = saveDateTime.add(Duration(seconds: expiresIn));
      final now = DateTime.now();

      // 如果 token 已过期，返回 false
      if (now.isAfter(expireDateTime)) {
        print('⚠️ Token 已过期');
        return false;
      }
    }

    return true;
  }

  /// ==========================================
  /// 清除登录状态（退出登录）
  /// ==========================================
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(AppConfig.accessTokenKey);
    await prefs.remove(AppConfig.refreshTokenKey);
    await prefs.remove(AppConfig.expiresInKey);
    await prefs.remove(AppConfig.phoneNumberKey);
    await prefs.remove(AppConfig.saveTimeKey);

    print('✅ Token 已清除');
  }

  /// ==========================================
  /// 获取完整的登录信息
  /// ==========================================
  ///
  /// 返回：包含所有登录信息的 Map，如果未登录则返回 null
  static Future<Map<String, dynamic>?> getLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString(AppConfig.accessTokenKey);
    if (accessToken == null) {
      return null;
    }

    return {
      'access_token': accessToken,
      'refresh_token': prefs.getString(AppConfig.refreshTokenKey),
      'expires_in': prefs.getInt(AppConfig.expiresInKey),
      'phone_number': prefs.getString(AppConfig.phoneNumberKey),
      'save_time': prefs.getInt(AppConfig.saveTimeKey),
    };
  }
}