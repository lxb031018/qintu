import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../constants/app_roles.dart';
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
    String? role,
  }) async {
    Logs.database.info('开始保存登录信息，角色: ${role ?? "未设置"}');

    try {
      // 敏感数据使用安全存储
      await _secureStorage.write(key: AppConfig.accessTokenKey, value: accessToken);
      await _secureStorage.write(key: AppConfig.refreshTokenKey, value: refreshToken);

      // 根据角色获取正确的 Refresh Token 有效期
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

      // 清除缓存
      _prefsCache = null;

      Logs.database.info('Token 已保存，角色: ${role ?? "未设置"}');
    } catch (e, stackTrace) {
      Logs.database.error('保存登录信息失败: $e', stackTrace: stackTrace);
      rethrow;
    }
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
    Logs.database.info('开始保存用户角色: $role');
    
    try {
      final prefs = await _getPrefs();
      await prefs.setString(AppConfig.userRoleKey, role);

      // 更新 Refresh Token 保存时间和有效期（根据角色重新计算）
      await prefs.setInt(AppConfig.refreshTokenSaveTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      // 更新 Refresh Token 有效期为角色配置
      final effectiveExpiresIn = AppConfig.getRefreshTokenExpiresIn(role);
      await prefs.setInt(AppConfig.expiresInKey, effectiveExpiresIn);

      // 清除缓存，确保下次读取时获取最新数据
      _prefsCache = null;

      Logs.database.info('角色已保存: $role, Refresh Token 有效期: ${effectiveExpiresIn}s (${effectiveExpiresIn ~/ 86400}天)');
    } catch (e, stackTrace) {
      Logs.database.info('保存角色失败: $e\n$stackTrace');
      rethrow;
    }
  }

  /// 检查是否已登录
  static Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _secureStorage.read(key: AppConfig.accessTokenKey);
      final refreshToken = await _secureStorage.read(key: AppConfig.refreshTokenKey);

      // Access Token 和 Refresh Token 都必须存在
      if (accessToken == null || refreshToken == null) {
        Logs.auth.info('登录状态检查: Token 不存在 (accessToken: ${accessToken == null}, refreshToken: ${refreshToken == null})');
        return false;
      }

      // 获取用户角色，根据角色判断 Refresh Token 有效期
      final prefs = await _getPrefs();
      final role = prefs.getString(AppConfig.userRoleKey);
      final refreshTokenSaveTime = prefs.getInt(AppConfig.refreshTokenSaveTimeKey);
      final refreshTokenExpiresIn = prefs.getInt(AppConfig.expiresInKey);

      Logs.auth.info('登录状态检查: role=$role, saveTime=$refreshTokenSaveTime, expiresIn=$refreshTokenExpiresIn');

      // 如果保存时间为空，说明登录流程未完成或数据损坏
      if (refreshTokenSaveTime == null) {
        Logs.app.warning('登录状态检查: refreshTokenSaveTime 不存在，可能登录流程中断');
        return false;
      }
      
      // 根据角色获取 Refresh Token 有效期
      final effectiveExpiresIn = _getEffectiveRefreshTokenExpiresIn(role, refreshTokenExpiresIn);

      final saveDateTime = DateTime.fromMillisecondsSinceEpoch(refreshTokenSaveTime);
      final expireDateTime = saveDateTime.add(Duration(seconds: effectiveExpiresIn));
      final now = DateTime.now();

      final daysRemaining = expireDateTime.difference(now).inDays;
      Logs.auth.info('Token 有效期：保存于 ${saveDateTime.toString().substring(0, 19)}, 过期于 ${expireDateTime.toString().substring(0, 19)}, 剩余 $daysRemaining 天');

      if (now.isAfter(expireDateTime)) {
        Logs.app.warning('Refresh Token 已过期（角色: $role），需要重新登录');
        return false;
      }

      Logs.auth.info('✅ 已登录（角色: $role，Token 剩余有效期: $daysRemaining 天）');
      return true;
    } catch (e, stackTrace) {
      Logs.auth.info('登录状态检查异常: $e\n$stackTrace');
      return false;
    }
  }

  /// 根据角色获取 Refresh Token 实际有效期
  static int _getEffectiveRefreshTokenExpiresIn(String? role, int? serverExpiresIn) {
    // 如果服务端返回的 Refresh Token 有效期存在，优先使用（适配服务端实际配置）
    if (serverExpiresIn != null && serverExpiresIn > 0) {
      return serverExpiresIn;
    }

    // 根据角色返回对应的 Refresh Token 有效期
    switch (role) {
      case AppRoles.receiver:
        return AppConfig.receiverRefreshTokenExpiresIn; // 1 年
      case AppRoles.sender:
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

    Logs.database.info('Token 已清除');
  }

  /// 获取完整的登录信息（强类型）
  static Future<LoginInfo?> getLoginInfo() async {
    final accessToken = await _secureStorage.read(key: AppConfig.accessTokenKey);
    if (accessToken == null) {
      return null;
    }

    final refreshToken = await _secureStorage.read(key: AppConfig.refreshTokenKey);
    final prefs = await _getPrefs();

    return LoginInfo.fromStorage(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: prefs.getInt(AppConfig.expiresInKey),
      phoneNumber: prefs.getString(AppConfig.phoneNumberKey),
      userId: prefs.getString(AppConfig.userIdKey),
      userRole: prefs.getString(AppConfig.userRoleKey),
      accessTokenSaveTime: prefs.getInt(AppConfig.accessTokenSaveTimeKey),
      refreshTokenSaveTime: prefs.getInt(AppConfig.refreshTokenSaveTimeKey),
    );
  }

  /// 获取完整的登录信息（Map 格式，兼容旧代码）
  @Deprecated('使用 getLoginInfo() 代替，返回强类型 LoginInfo')
  static Future<Map<String, dynamic>?> getLoginInfoAsMap() async {
    final loginInfo = await getLoginInfo();
    return loginInfo?.toMap();
  }
}