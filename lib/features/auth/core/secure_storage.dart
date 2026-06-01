import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/storage_keys.dart';
import '../../../config/auth_config.dart';
import '../../../models/auth/login_info.dart';
import '../../../utils/logger.dart';

/// 安全存储契约
///
/// 拆分动机：把"存储能力"从"具体实现"中抽出，
/// - 上层（AuthStateNotifier / AuthService）通过 `ISecureStorage` 接口注入依赖，
///   单元测试可注入 mock，避免触碰 `flutter_secure_storage` 原生插件。
/// - 非 Riverpod 上下文（ApiClient / TokenRefreshInterceptor）通过
///   `SecureStorageRegistry` 拿全局实例，无需打破单例。
///
/// 敏感数据（access_token, refresh_token）走 `FlutterSecureStorage`；
/// 非敏感数据（expires_in, phone_number, user_id 等）走 `SharedPreferencesAsync`。
abstract interface class ISecureStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int accessTokenExpiresIn,
    required int refreshTokenExpiresIn,
    required String phoneNumber,
    required String userId,
  });

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<String?> getUserId();

  Future<bool> isLoggedIn();

  Future<void> clearTokens();

  Future<LoginInfo?> getLoginInfo();
}

/// 默认实现：基于 `flutter_secure_storage` + `shared_preferences`。
///
/// 直接实例化即可；也作为 `SecureStorageRegistry` 的默认值。
class FlutterSecureStorageImpl implements ISecureStorage {
  FlutterSecureStorageImpl();

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static final _prefs = SharedPreferencesAsync();

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int accessTokenExpiresIn,
    required int refreshTokenExpiresIn,
    required String phoneNumber,
    required String userId,
  }) async {
    try {
      await _secureStorage.write(key: SecureStorageKeys.accessToken, value: accessToken);
      await _secureStorage.write(key: SecureStorageKeys.refreshToken, value: refreshToken);

      await _prefs.setInt(SecureStorageKeys.tokenExpiresAt, refreshTokenExpiresIn);
      await _prefs.setString(SecureStorageKeys.phoneNumber, phoneNumber);
      await _prefs.setString(SecureStorageKeys.userId, userId);

      final now = DateTime.now().millisecondsSinceEpoch;
      await _prefs.setInt(SecureStorageKeys.accessTokenSaveTime, now);
      await _prefs.setInt(SecureStorageKeys.refreshTokenSaveTime, now);
    } catch (e, stackTrace) {
      Logs.database.error('保存登录信息失败:', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: SecureStorageKeys.accessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: SecureStorageKeys.refreshToken);
  }

  @override
  Future<String?> getUserId() async {
    return await _prefs.getString(SecureStorageKeys.userId);
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _secureStorage.read(key: SecureStorageKeys.accessToken);
      final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);

      if (accessToken == null || refreshToken == null) {
        return false;
      }

      final refreshTokenSaveTime = await _prefs.getInt(SecureStorageKeys.refreshTokenSaveTime);
      final refreshTokenExpiresIn = await _prefs.getInt(SecureStorageKeys.tokenExpiresAt);

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

  @override
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: SecureStorageKeys.accessToken);
    await _secureStorage.delete(key: SecureStorageKeys.refreshToken);

    await _prefs.remove(SecureStorageKeys.tokenExpiresAt);
    await _prefs.remove(SecureStorageKeys.phoneNumber);
    await _prefs.remove(SecureStorageKeys.userId);
    await _prefs.remove(SecureStorageKeys.accessTokenSaveTime);
    await _prefs.remove(SecureStorageKeys.refreshTokenSaveTime);
    await _prefs.remove(SecureStorageKeys.userRole);

    Logs.database.info('Token 已清除');
  }

  @override
  Future<LoginInfo?> getLoginInfo() async {
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
}

/// 全局存储注册表
///
/// 用途：给 `ApiClient` / `TokenRefreshInterceptor` 这种**不在 Riverpod ref
/// 上下文里**的代码用。它们不持有 ref，所以走全局句柄拿当前生效的 storage
/// 实现。
///
/// 用法：
/// - 生产：默认就是 `FlutterSecureStorageImpl()`，无需注册
/// - 测试：`SecureStorageRegistry.setInstance(MyMockStorage())`，tearDown 里 `reset()`
class SecureStorageRegistry {
  static ISecureStorage _instance = FlutterSecureStorageImpl();

  static ISecureStorage get instance => _instance;

  static void setInstance(ISecureStorage storage) {
    _instance = storage;
  }

  static void reset() {
    _instance = FlutterSecureStorageImpl();
  }
}
