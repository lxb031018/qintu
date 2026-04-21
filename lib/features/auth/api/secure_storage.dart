import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/storage_keys.dart';
import '../../../config/auth_config.dart';
import '../../../models/auth/login_info.dart';
import '../../../utils/logger.dart';

/// 安全存储服务 - 负责管理用户登录状态的持久化
///
/// 安全策略：
/// - 敏感数据（access_token, refresh_token）使用 FlutterSecureStorage
/// - 非敏感数据（expires_in, phone_number 等）使用 SharedPreferencesAsync

class SecureStorage {
  /// 安全存储实例
  ///
  /// v10.0.0 更新：
  /// - 移除了已弃用的 encryptedSharedPreferences 参数
  /// - Android 自动使用自定义密码迁移
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// SharedPreferencesAsync 实例
  static final _prefs = SharedPreferencesAsync();

  // ==================== Token 存储 ====================

  /// 保存登录信息
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int accessTokenExpiresIn,
    required int refreshTokenExpiresIn,
    required String phoneNumber,
    required String userId,
  }) async {
    try {
      // 敏感数据使用安全存储
      await _secureStorage.write(key: SecureStorageKeys.accessToken, value: accessToken);
      await _secureStorage.write(key: SecureStorageKeys.refreshToken, value: refreshToken);

      // 非敏感数据使用普通存储
      await _prefs.setInt(SecureStorageKeys.tokenExpiresAt, refreshTokenExpiresIn);
      await _prefs.setString(SecureStorageKeys.phoneNumber, phoneNumber);
      await _prefs.setString(SecureStorageKeys.userId, userId);

      // 保存 Token 时间戳
      final now = DateTime.now().millisecondsSinceEpoch;
      await _prefs.setInt(SecureStorageKeys.accessTokenSaveTime, now);
      await _prefs.setInt(SecureStorageKeys.refreshTokenSaveTime, now);
    } catch (e, stackTrace) {
      Logs.database.error('保存登录信息失败:', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取 Access Token
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: SecureStorageKeys.accessToken);
  }

  /// 获取 Refresh Token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: SecureStorageKeys.refreshToken);
  }

  /// 获取手机号
  static Future<String?> getPhoneNumber() async {
    return await _prefs.getString(SecureStorageKeys.phoneNumber);
  }

  /// 获取用户 ID
  static Future<String?> getUserId() async {
    return await _prefs.getString(SecureStorageKeys.userId);
  }

  /// 检查是否已登录
  static Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _secureStorage.read(key: SecureStorageKeys.accessToken);
      final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);

      // Access Token 和 Refresh Token 都必须存在
      if (accessToken == null || refreshToken == null) {
        return false;
      }

      // 检查 Refresh Token 是否过期
      final refreshTokenSaveTime = await _prefs.getInt(SecureStorageKeys.refreshTokenSaveTime);
      final refreshTokenExpiresIn = await _prefs.getInt(SecureStorageKeys.tokenExpiresAt);

      // 如果保存时间为空，说明登录流程未完成或数据损坏
      if (refreshTokenSaveTime == null) {
        return false;
      }

      final effectiveExpiresIn = refreshTokenExpiresIn ?? AuthConfig.refreshTokenExpiresIn;
      final saveDateTime = DateTime.fromMillisecondsSinceEpoch(refreshTokenSaveTime);
      final expireDateTime = saveDateTime.add(Duration(seconds: effectiveExpiresIn));
      final now = DateTime.now();

      return !now.isAfter(expireDateTime);
    } catch (e, stackTrace) {
      Logs.auth.error('登录状态检查异常:', stackTrace: stackTrace);
      return false;
    }
  }

  /// 清除登录状态（退出登录）
  static Future<void> clearTokens() async {
    // 清除安全存储
    await _secureStorage.delete(key: SecureStorageKeys.accessToken);
    await _secureStorage.delete(key: SecureStorageKeys.refreshToken);

    // 清除普通存储
    await _prefs.remove(SecureStorageKeys.tokenExpiresAt);
    await _prefs.remove(SecureStorageKeys.phoneNumber);
    await _prefs.remove(SecureStorageKeys.userId);
    await _prefs.remove(SecureStorageKeys.accessTokenSaveTime);
    await _prefs.remove(SecureStorageKeys.refreshTokenSaveTime);
    await _prefs.remove(SecureStorageKeys.userRole);

    Logs.database.info('Token 已清除');
  }

  /// 获取完整的登录信息（强类型）
  static Future<LoginInfo?> getLoginInfo() async {
    final accessToken = await _secureStorage.read(key: SecureStorageKeys.accessToken);
    if (accessToken == null) {
      return null;
    }

    final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);

    return LoginInfo.fromStorage(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: await _prefs.getInt(SecureStorageKeys.tokenExpiresAt),
      phoneNumber: await _prefs.getString(SecureStorageKeys.phoneNumber),
      userId: await _prefs.getString(SecureStorageKeys.userId),
      accessTokenSaveTime: await _prefs.getInt(SecureStorageKeys.accessTokenSaveTime),
      refreshTokenSaveTime: await _prefs.getInt(SecureStorageKeys.refreshTokenSaveTime),
    );
  }

  /// 获取完整的登录信息（Map 格式，兼容旧代码）
  @Deprecated('使用 getLoginInfo() 代替，返回强类型 LoginInfo')
  static Future<Map<String, dynamic>?> getLoginInfoAsMap() async {
    final loginInfo = await getLoginInfo();
    return loginInfo?.toMap();
  }
}