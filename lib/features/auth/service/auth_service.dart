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
/// ============================================

class AuthService {
  /// 智能登录/注册
  ///
  /// 自动判断用户是新用户还是老用户：
  /// - 老用户：登录
  /// - 新用户：注册并登录
  static Future<AuthResult> signInOrSignUp({
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
  static Future<void> saveAuthResult(AuthResult result, String phone) async {
    await SecureStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      accessTokenExpiresIn: result.accessTokenExpiresIn,
      refreshTokenExpiresIn: result.refreshTokenExpiresIn,
      phoneNumber: phone,
      userId: result.uid,
    );
  }

  /// 检查是否已登录
  static Future<bool> isLoggedIn() async {
    return await SecureStorage.isLoggedIn();
  }

  /// 获取登录信息
  static Future<LoginInfo?> getLoginInfo() async {
    return await SecureStorage.getLoginInfo();
  }

  /// 清除登录状态
  static Future<void> logout() async {
    final accessToken = await SecureStorage.getAccessToken();
    final deviceId = await DeviceManager.getDeviceId();

    if (accessToken != null) {
      try {
        await AuthApi.signOut(accessToken, deviceId);
      } catch (_) {}
    }

    await SecureStorage.clearTokens();
  }
}
