import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_durations.dart';
import '../config/cloudbase_config.dart';
import '../config/environments/environment_manager.dart';
import '../models/auth_result.dart';
import '../utils/logger.dart';
import '../utils/exceptions.dart';
import '../utils/phone_utils.dart';

/// ============================================
/// 认证服务（双模式自适应）
/// ============================================
///
/// 根据当前运行环境自动选择认证路径：
/// - 本地环境 → 自建后端 /auth/v1/* 接口
/// - CloudBase 环境 → CloudBase Auth v2 官方 API
///
/// 与 AuthApiService 的区别：
/// - 本服务：处理验证码发送/验证/登录注册
/// - AuthApiService：调用自建后端通用认证接口（如 refresh-token）
/// ============================================

class CloudBaseAuthService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: AppDurations.networkTimeout,
    receiveTimeout: AppDurations.networkTimeout,
    sendTimeout: AppDurations.networkTimeout,
  ));

  /// 是否本地环境（自建后端）
  static bool get _isLocal => EnvironmentManager.isLocal;

  /// 认证 API 基础地址
  /// - 本地环境 → 自建后端 baseUrl（完整路径由 ApiEndpoints 提供）
  /// - CloudBase 环境 → CloudBase 网关
  static String get _authBaseUrl {
    return EnvironmentManager.baseUrl;
  }

  /// CloudBase 环境 ID（仅 CloudBase 环境需要）
  static String get envId => CloudBaseConfig.envId;

  /// Publishable Key（仅 CloudBase 环境需要）
  static String get publishableKey => CloudBaseConfig.publishableKey;

  /// 通用的请求头
  /// - 本地环境：不需要 Publishable Key
  /// - CloudBase 环境：需要 Bearer {publishableKey}
  static Map<String, String> get _headers {
    if (_isLocal) {
      return {
        'Content-Type': 'application/json',
      };
    }
    final key = publishableKey;
    Logs.auth.info('🔑 CloudBase Auth, Publishable Key: ${key.isEmpty ? "未加载" : "${key.substring(0, 10)}..."}');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $key',
    };
  }

  /// ==========================================
  /// 第 1 步：发送短信验证码
  /// ==========================================
  ///
  /// [phoneNumber] 手机号，格式必须为 "+86 13800138000"（带空格）
  ///
  /// 返回：verification_id（用于第 2 步验证）
  static Future<String> sendVerificationCode(String phoneNumber) async {
    final url = Uri.parse('$_authBaseUrl${ApiEndpoints.sendVerificationCode}');

    Logs.auth.info('发送验证码 (${_isLocal ? "本地自建" : "CloudBase"})');
    Logs.api.info('API请求: POST $url');
    Logs.api.info('请求体: phone_number=${PhoneUtils.maskForLog(phoneNumber)}');

    try {
      final response = await _dio.post(
        url.toString(),
        options: Options(headers: _headers),
        data: jsonEncode({
          'target': 'ANY',  // CloudBase 官方 API 要求：不限制用户是否存在
          'phone_number': phoneNumber,
        }),
      );

      Logs.api.info('API响应: ${response.statusCode}');
      Logs.api.info('响应体: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        Logs.auth.info('发送成功，verification_id: ${data['verification_id']}');
        return data['verification_id'];
      } else {
        final error = response.data is String ? jsonDecode(response.data) : response.data;
        Logs.auth.warning('发送失败: ${error['error_description'] ?? error['error'] ?? response.data}');

        // 根据错误类型抛出具体异常
        final errorCode = error['error'];
        if (errorCode == 'invalid_phone_number') {
          throw const VerificationCodeException(message: '手机号格式错误');
        } else if (errorCode == 'rate_limit_exceeded') {
          throw const RateLimitException(message: '验证码发送过于频繁，请稍后再试');
        } else {
          throw NetworkException(
            message: error['error_description'] ?? '验证码发送失败',
            statusCode: response.statusCode,
          );
        }
      }
    } on RateLimitException {
      rethrow;
    } on VerificationCodeException {
      rethrow;
    } on DioException catch (e) {
      Logs.auth.warning('HTTP 客户端异常: $e');
      throw NetworkException(
        message: '网络请求失败',
        originalError: e,
      );
    } catch (e) {
      Logs.auth.warning('网络请求异常: $e');
      if (e is NetworkException) rethrow;

      throw const NetworkException(
        message: '网络连接异常，请检查网络设置',
      );
    }
  }

  /// ==========================================
  /// 第 2 步：验证验证码
  /// ==========================================
  ///
  /// [verificationId] 第 1 步返回的 verification_id
  /// [code] 用户收到的 6 位验证码，如 "123456"
  ///
  /// 返回：verification_token（用于第 3 步登录）
  static Future<String> verifyCode(String verificationId, String code) async {
    final url = Uri.parse('$_authBaseUrl${ApiEndpoints.verifyCode}');

    Logs.auth.info('验证验证码');
    Logs.api.info('API请求: POST $url');
    Logs.api.info('请求体: verification_id=$verificationId, code=$code');

    try {
      final response = await _dio.post(
        url.toString(),
        options: Options(headers: _headers),
        data: jsonEncode({
          'verification_id': verificationId,
          'verification_code': code,
        }),
      );

      Logs.api.info('API响应: ${response.statusCode}');
      Logs.api.info('响应体: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        Logs.auth.info('验证成功，verification_token: ${data['verification_token']}');
        return data['verification_token'];
      } else {
        final error = response.data is String ? jsonDecode(response.data) : response.data;
        Logs.auth.warning('验证失败: ${error['message'] ?? response.data}');

        // 根据错误码抛出具体异常
        switch (error['code']) {
          case 'INVALID_VERIFICATION_CODE':
            throw const VerificationCodeException(
              message: '验证码错误或已过期，请重新获取',
            );
          default:
            throw NetworkException(
              message: error['message'] ?? '验证码验证失败',
              statusCode: response.statusCode,
            );
        }
      }
    } on VerificationCodeException {
      rethrow;
    } on DioException catch (e) {
      Logs.auth.warning('HTTP 客户端异常: $e');
      throw NetworkException(
        message: '网络请求失败',
        originalError: e,
      );
    } catch (e) {
      Logs.auth.warning('网络请求异常: $e');
      if (e is NetworkException) rethrow;

      throw const NetworkException(
        message: '网络连接异常，请检查网络设置',
      );
    }
  }

  /// ==========================================
  /// 第 3 步：智能登录/注册（自动判断）
  /// ==========================================
  ///
  /// 自动判断用户是新用户还是老用户：
  /// - 老用户：调用 signin 直接登录
  /// - 新用户：调用 signup 注册并登录
  ///
  /// [verificationToken] 第 2 步返回的 verification_token
  /// [phoneNumber] 手机号，格式为 "+86 13800138000"
  ///
  /// 返回：AuthResult 认证结果
  static Future<AuthResult> signInOrSignUp({
    required String verificationToken,
    required String phoneNumber,
  }) async {
    Logs.auth.info('智能登录/注册 (${_isLocal ? "本地" : "CloudBase"})');

    try {
      // 先尝试登录（老用户）
      Logs.auth.info('尝试登录...');
      final loginUrl = Uri.parse('$_authBaseUrl${ApiEndpoints.signIn}');

      Logs.api.info('API请求: POST $loginUrl');
      Logs.api.info('请求体: verification_token=${verificationToken.substring(0, 20)}...');

      final loginResponse = await _dio.post(
        loginUrl.toString(),
        options: Options(headers: _headers),
        data: jsonEncode({
          'verification_token': verificationToken,
        }),
      );

      Logs.api.info('API响应: ${loginResponse.statusCode}');
      Logs.api.info('响应体: ${loginResponse.data}');

      if (loginResponse.statusCode == 200) {
        Logs.auth.info('登录成功（老用户）');
        final data = loginResponse.data is String ? jsonDecode(loginResponse.data) : loginResponse.data;
        return AuthResult.fromJson(data);
      }

      // 如果登录失败（非 404 错误），抛出异常
      final loginError = loginResponse.data is String ? jsonDecode(loginResponse.data) : loginResponse.data;
      Logs.auth.warning('登录失败: ${loginError['error_description'] ?? loginError['error']}');

      throw AuthException(
        message: loginError['error_description'] ?? loginError['error'] ?? '登录失败',
        code: loginError['error_code'],
      );
    } on DioException catch (e) {
      // 如果是 404，说明用户不存在，走注册流程
      if (e.response?.statusCode == 404) {
        Logs.auth.info('用户不存在，尝试注册...');
        return _register(verificationToken: verificationToken, phoneNumber: phoneNumber);
      }
      Logs.auth.warning('HTTP 客户端异常: $e');
      throw NetworkException(
        message: '网络请求失败',
        originalError: e,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      Logs.auth.warning('异常: $e');
      if (e is NetworkException) rethrow;

      throw const NetworkException(
        message: '网络连接异常，请检查网络设置',
      );
    }
  }

  /// ==========================================
  /// 内部方法：注册新用户
  /// ==========================================
  static Future<AuthResult> _register({
    required String verificationToken,
    required String phoneNumber,
  }) async {
    final signupUrl = Uri.parse('$_authBaseUrl${ApiEndpoints.signUp}');
    Logs.api.info('API请求: POST $signupUrl');
    Logs.api.info('请求体: verification_token=${verificationToken.substring(0, 20)}..., phone_number=${PhoneUtils.maskForLog(phoneNumber)}');

    final signupResponse = await _dio.post(
      signupUrl.toString(),
      options: Options(headers: _headers),
      data: jsonEncode({
        'phone_number': phoneNumber,  // CloudBase 官方 API 要求：注册时必须传手机号
        'verification_token': verificationToken,
      }),
    );

    Logs.api.info('API响应: ${signupResponse.statusCode}');
    Logs.api.info('响应体: ${signupResponse.data}');

    if (signupResponse.statusCode == 200) {
      Logs.auth.info('注册并登录成功（新用户）');
      final data = signupResponse.data is String ? jsonDecode(signupResponse.data) : signupResponse.data;
      return AuthResult.fromJson(data);
    } else {
      final signupError = signupResponse.data is String ? jsonDecode(signupResponse.data) : signupResponse.data;
      Logs.auth.warning('注册失败: ${signupError['error_description'] ?? signupError['error']}');
      throw AuthException(
        message: signupError['error_description'] ?? signupError['error'] ?? '注册失败，请稍后重试',
        code: signupError['error_code'],
      );
    }
  }
}