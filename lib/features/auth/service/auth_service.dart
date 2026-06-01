import 'package:dio/dio.dart';
import 'package:qintu/models/auth/auth_result.dart';
import 'package:qintu/models/auth/login_info.dart';
import 'package:qintu/utils/logger.dart';
import '../../../core/device/device_manager.dart';
import '../core/auth_api.dart';
import '../core/secure_storage.dart';

/// ============================================
/// 认证服务层
///
/// 纯业务逻辑，调用 API 层编排流程
/// 不持有状态，不继承 ChangeNotifier
///
/// 重构：从全 static 方法类改为可注入实例，构造时接受 `ISecureStorage`。
/// 这样测试可注入 mock storage，避免触碰 `flutter_secure_storage` 原生插件。
/// ============================================

class AuthService {
  AuthService(this._storage);

  final ISecureStorage _storage;

  /// 智能登录/注册
  ///
  /// 自动判断用户是新用户还是老用户：
  /// - 老用户：登录
  /// - 新用户：注册并登录
  Future<AuthResult> signInOrSignUp({
    required String verificationToken,
    required String phone,
  }) async {
    final deviceId = await DeviceManager.getDeviceId();

    try {
      return await AuthApi.signIn(verificationToken, deviceId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        Logs.auth.info('用户不存在，尝试注册...');
        return await AuthApi.signUp(
          verificationToken: verificationToken,
          phoneNumber: phone,
          deviceId: deviceId,
        );
      }
      rethrow;
    }
  }

  /// 保存认证结果到安全存储
  Future<void> saveAuthResult(AuthResult result, String phone) async {
    await _storage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      accessTokenExpiresIn: result.accessTokenExpiresIn,
      refreshTokenExpiresIn: result.refreshTokenExpiresIn,
      phoneNumber: phone,
      userId: result.uid,
    );
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  /// 获取登录信息
  Future<LoginInfo?> getLoginInfo() async {
    return await _storage.getLoginInfo();
  }

  /// 清除登录状态
  Future<void> logout() async {
    final accessToken = await _storage.getAccessToken();
    final deviceId = await DeviceManager.getDeviceId();

    if (accessToken != null) {
      try {
        await AuthApi.signOut(accessToken, deviceId);
      } catch (_) {}
    }

    await _storage.clearTokens();
  }
}
