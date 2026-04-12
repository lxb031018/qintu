import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';
import '../config/auth_config.dart';
import '../models/login_info.dart';
import '../utils/logger.dart';

/// 安全存储服务 - 负责管理用户登录状态的持久化
///
/// 安全策略：
/// - 敏感数据（access_token, refresh_token）使用 FlutterSecureStorage
/// - 非敏感数据（expires_in, phone_number 等）使用 SharedPreferences
///
/// 重构说明（2026-04-05）：
/// - 引入 LoginInfo 强类型模型，替代 `Map<String, dynamic>`
/// - 引入 UserCredentials 封装导航参数
/// - 优化日志记录，统一错误处理

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
    Logs.database.info('========== 开始保存登录信息 ==========');
    Logs.database.info('用户ID: $userId');
    Logs.database.info('手机号: $phoneNumber');
    Logs.database.info('AccessToken 有效期: $accessTokenExpiresIn秒 (${accessTokenExpiresIn ~/ 3600}小时)');
    Logs.database.info('RefreshToken 有效期: $refreshTokenExpiresIn秒 (${refreshTokenExpiresIn ~/ 86400}天)');

    try {
      // 敏感数据使用安全存储
      Logs.database.info('正在保存 AccessToken 到 SecureStorage...');
      await _secureStorage.write(key: SecureStorageKeys.accessToken, value: accessToken);
      Logs.database.info('正在保存 RefreshToken 到 SecureStorage...');
      await _secureStorage.write(key: SecureStorageKeys.refreshToken, value: refreshToken);

      // 非敏感数据使用普通存储
      final prefs = await _getPrefs();
      
      Logs.database.info('正在保存 RefreshToken 有效期到 SharedPreferences...');
      await prefs.setInt(SecureStorageKeys.tokenExpiresAt, refreshTokenExpiresIn);
      
      Logs.database.info('正在保存手机号到 SharedPreferences...');
      await prefs.setString(SecureStorageKeys.phoneNumber, phoneNumber);
      
      Logs.database.info('正在保存用户ID到 SharedPreferences...');
      await prefs.setString(SecureStorageKeys.userId, userId);

      // 分别保存 Access Token 和 Refresh Token 的时间
      final now = DateTime.now().millisecondsSinceEpoch;
      final nowDate = DateTime.fromMillisecondsSinceEpoch(now);
      Logs.database.info('正在保存 Token 时间戳: $nowDate');
      
      await prefs.setInt(SecureStorageKeys.accessTokenSaveTime, now);
      await prefs.setInt(SecureStorageKeys.refreshTokenSaveTime, now);

      // 验证保存是否成功
      final verifyAccessToken = await _secureStorage.read(key: SecureStorageKeys.accessToken);
      final verifyRefreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);
      final verifyUserId = prefs.getString(SecureStorageKeys.userId);
      final verifySaveTime = prefs.getInt(SecureStorageKeys.refreshTokenSaveTime);

      Logs.database.info('========== 保存结果验证 ==========');
      Logs.database.info('AccessToken 保存成功: ${verifyAccessToken != null ? "✅ 是" : "❌ 否"}');
      Logs.database.info('RefreshToken 保存成功: ${verifyRefreshToken != null ? "✅ 是" : "❌ 否"}');
      Logs.database.info('UserId 保存成功: ${verifyUserId != null ? "✅ 是 ($verifyUserId)" : "❌ 否"}');
      Logs.database.info('SaveTime 保存成功: ${verifySaveTime != null ? "✅ 是 ($nowDate)" : "❌ 否"}');
      Logs.database.info('========== 登录信息保存完成 ==========');
    } catch (e, stackTrace) {
      Logs.database.error('保存登录信息失败: $e', stackTrace: stackTrace);
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
    final prefs = await _getPrefs();
    return prefs.getString(SecureStorageKeys.phoneNumber);
  }

  /// 获取用户 ID
  static Future<String?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getString(SecureStorageKeys.userId);
  }

  /// 检查是否已登录
  static Future<bool> isLoggedIn() async {
    Logs.auth.info('========== 开始检查登录状态 ==========');
    
    try {
      Logs.auth.info('步骤 1/5: 正在读取 AccessToken...');
      final accessToken = await _secureStorage.read(key: SecureStorageKeys.accessToken);
      Logs.auth.info('步骤 1/5 完成: accessToken = ${accessToken != null ? "✅ 存在 (${accessToken.length}字符)" : "❌ null"}');
      
      Logs.auth.info('步骤 2/5: 正在读取 RefreshToken...');
      final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);
      Logs.auth.info('步骤 2/5 完成: refreshToken = ${refreshToken != null ? "✅ 存在 (${refreshToken.length}字符)" : "❌ null"}');

      // Access Token 和 Refresh Token 都必须存在
      if (accessToken == null || refreshToken == null) {
        Logs.auth.info('❌ 登录状态检查失败: Token 不存在 (accessToken: ${accessToken == null}, refreshToken: ${refreshToken == null})');
        Logs.auth.info('========================================');
        return false;
      }

      // 检查 Refresh Token 是否过期
      Logs.auth.info('步骤 3/5: 正在读取 Token 时间戳...');
      final prefs = await _getPrefs();
      final refreshTokenSaveTime = prefs.getInt(SecureStorageKeys.refreshTokenSaveTime);
      final refreshTokenExpiresIn = prefs.getInt(SecureStorageKeys.tokenExpiresAt);

      Logs.auth.info('步骤 3/5 完成:');
      Logs.auth.info('  - refreshTokenSaveTime = ${refreshTokenSaveTime ?? -1}');
      Logs.auth.info('  - refreshTokenExpiresIn = ${refreshTokenExpiresIn ?? -1}');

      // 如果保存时间为空，说明登录流程未完成或数据损坏
      if (refreshTokenSaveTime == null) {
        Logs.auth.warning('❌ 登录状态检查失败: refreshTokenSaveTime 不存在，可能登录流程中断');
        Logs.auth.info('========================================');
        return false;
      }

      Logs.auth.info('步骤 4/5: 正在计算 Token 有效期...');
      final effectiveExpiresIn = refreshTokenExpiresIn ?? AuthConfig.refreshTokenExpiresIn;
      final saveDateTime = DateTime.fromMillisecondsSinceEpoch(refreshTokenSaveTime);
      final expireDateTime = saveDateTime.add(Duration(seconds: effectiveExpiresIn));
      final now = DateTime.now();

      final daysRemaining = expireDateTime.difference(now).inDays;
      final hoursRemaining = expireDateTime.difference(now).inHours;
      
      Logs.auth.info('步骤 4/5 完成:');
      Logs.auth.info('  - 保存时间: $saveDateTime');
      Logs.auth.info('  - 过期时间: $expireDateTime');
      Logs.auth.info('  - 当前时间: $now');
      Logs.auth.info('  - 有效期配置: $effectiveExpiresIn秒 (${effectiveExpiresIn ~/ 86400}天)');
      Logs.auth.info('  - 剩余有效期: $daysRemaining 天 $hoursRemaining 小时');

      Logs.auth.info('步骤 5/5: 正在检查是否过期...');
      if (now.isAfter(expireDateTime)) {
        Logs.auth.info('步骤 5/5 完成: ❌ Refresh Token 已过期');
        Logs.auth.info('  - 过期时间: $expireDateTime');
        Logs.auth.info('  - 当前时间: $now');
        Logs.auth.info('  - 过期时长: ${now.difference(expireDateTime).inDays} 天');
        Logs.auth.info('========================================');
        return false;
      }

      Logs.auth.info('步骤 5/5 完成: ✅ Refresh Token 有效');
      Logs.auth.info('========================================');
      Logs.auth.info('✅ 登录状态检查通过: 已登录（Token 剩余有效期: $daysRemaining 天）');
      Logs.auth.info('========================================');
      return true;
    } catch (e, stackTrace) {
      Logs.auth.error('❌ 登录状态检查异常: $e', stackTrace: stackTrace);
      Logs.auth.info('========================================');
      return false;
    }
  }

  /// 清除登录状态（退出登录）
  static Future<void> clearTokens() async {
    // 清除安全存储
    await _secureStorage.delete(key: SecureStorageKeys.accessToken);
    await _secureStorage.delete(key: SecureStorageKeys.refreshToken);

    // 清除普通存储
    final prefs = await _getPrefs();
    await prefs.remove(SecureStorageKeys.tokenExpiresAt);
    await prefs.remove(SecureStorageKeys.phoneNumber);
    await prefs.remove(SecureStorageKeys.userId);
    await prefs.remove(SecureStorageKeys.accessTokenSaveTime);
    await prefs.remove(SecureStorageKeys.refreshTokenSaveTime);
    await prefs.remove(SecureStorageKeys.userRole);

    Logs.database.info('Token 已清除');
  }

  /// 获取完整的登录信息（强类型）
  static Future<LoginInfo?> getLoginInfo() async {
    final accessToken = await _secureStorage.read(key: SecureStorageKeys.accessToken);
    if (accessToken == null) {
      return null;
    }

    final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);
    final prefs = await _getPrefs();

    return LoginInfo.fromStorage(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: prefs.getInt(SecureStorageKeys.tokenExpiresAt),
      phoneNumber: prefs.getString(SecureStorageKeys.phoneNumber),
      userId: prefs.getString(SecureStorageKeys.userId),
      accessTokenSaveTime: prefs.getInt(SecureStorageKeys.accessTokenSaveTime),
      refreshTokenSaveTime: prefs.getInt(SecureStorageKeys.refreshTokenSaveTime),
    );
  }

  /// 获取完整的登录信息（Map 格式，兼容旧代码）
  @Deprecated('使用 getLoginInfo() 代替，返回强类型 LoginInfo')
  static Future<Map<String, dynamic>?> getLoginInfoAsMap() async {
    final loginInfo = await getLoginInfo();
    return loginInfo?.toMap();
  }
}