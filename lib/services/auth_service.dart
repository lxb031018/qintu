import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/auth_result.dart';
import '../utils/logger.dart';
import '../utils/exceptions.dart';

/// CloudBase 认证服务 - 封装所有与用户登录相关的 HTTP API 调用

class CloudBaseAuthService {
  /// CloudBase 环境配置
  static String get envId => AppConfig.envId;

  /// 认证 API 基础地址（统一来源：ApiEndpoints）
  static String get authBaseUrl => ApiEndpoints.authBaseUrl;

  /// Publishable Key（从环境变量读取）
  static String get publishableKey => AppConfig.publishableKey;

  /// 通用的请求头（包含 Publishable Key 认证）
  static Map<String, String> get _headers {
    final key = publishableKey;
    // 打印 Key 的前 10 位以确认是否加载成功，避免泄露完整 Key
    Logs.auth.info('🔑 获取请求头, Publishable Key: ${key.isEmpty ? "未加载 (空字符串)" : key.substring(0, 10) + "..."}');
    
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
    final url = Uri.parse('$authBaseUrl${ApiEndpoints.sendVerificationCode}');

    Logs.auth.info('发送验证码');
    Logs.api.info('API请求: POST ${url.toString()}');
    Logs.api.info('请求体: phone_number=$phoneNumber');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      Logs.api.info('API响应: ${response.statusCode}');
      Logs.api.info('响应体: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logs.auth.info('发送成功，verification_id: ${data['verification_id']}');
        return data['verification_id'];
      } else {
        final error = jsonDecode(response.body);
        Logs.auth.warning('发送失败: ${error['message'] ?? response.body}');

        // 根据错误码抛出具体异常
        switch (error['code']) {
          case 'INVALID_PARAMETER':
            throw const VerificationCodeException(
              message: '手机号格式错误',
            );
          case 'TASK_IN_PROGRESS':
            throw const RateLimitException(
              message: '验证码发送过于频繁，请稍后再试',
            );
          default:
            throw NetworkException(
              message: error['message'] ?? '验证码发送失败',
              statusCode: response.statusCode,
            );
        }
      }
    } on RateLimitException {
      rethrow;
    } on VerificationCodeException {
      rethrow;
    } on http.ClientException catch (e) {
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
    final url = Uri.parse('$authBaseUrl${ApiEndpoints.verifyCode}');

    Logs.auth.info('验证验证码');
    Logs.api.info('API请求: POST ${url.toString()}');
    Logs.api.info('请求体: verification_id=$verificationId, code=$code');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'verification_id': verificationId,
          'verification_code': code,
        }),
      );

      Logs.api.info('API响应: ${response.statusCode}');
      Logs.api.info('响应体: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logs.auth.info('验证成功，verification_token: ${data['verification_token']}');
        return data['verification_token'];
      } else {
        final error = jsonDecode(response.body);
        Logs.auth.warning('验证失败: ${error['message'] ?? response.body}');

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
    } on http.ClientException catch (e) {
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
  /// - 新用户：自动注册
  /// - 老用户：直接登录
  ///
  /// [verificationToken] 第 2 步返回的 verification_token
  /// [phoneNumber] 手机号，格式为 "+86 13800138000"
  ///
  /// 返回：AuthResult 认证结果
  static Future<AuthResult> signInOrSignUp({
    required String verificationToken,
    required String phoneNumber,
  }) async {
    Logs.auth.info('智能登录/注册');

    try {
      // 先尝试登录（老用户）
      Logs.auth.info('尝试登录（老用户）...');
      final loginUrl = Uri.parse('$authBaseUrl${ApiEndpoints.signIn}');

      Logs.api.info('API请求: POST ${loginUrl.toString()}');
      Logs.api.info('请求体: verification_token=${verificationToken.substring(0, 20)}...');

      final loginResponse = await http.post(
        loginUrl,
        headers: _headers,
        body: jsonEncode({
          'verification_token': verificationToken,
        }),
      );

      Logs.api.info('API响应: ${loginResponse.statusCode}');
      Logs.api.info('响应体: ${loginResponse.body}');

      if (loginResponse.statusCode == 200) {
        Logs.auth.info('登录成功（老用户）');
        final data = jsonDecode(loginResponse.body);
        return AuthResult.fromJson(data);
      }

      // 如果登录失败，尝试注册
      Logs.auth.info('登录失败，尝试注册（新用户）...');

      final signupUrl = Uri.parse('$authBaseUrl${ApiEndpoints.signUp}');
      Logs.api.info('API请求: POST ${signupUrl.toString()}');
      Logs.api.info('请求体: verification_token=..., phone_number=$phoneNumber');

      final signupResponse = await http.post(
        signupUrl,
        headers: _headers,
        body: jsonEncode({
          'verification_token': verificationToken,
          'phone_number': phoneNumber,
        }),
      );

      Logs.api.info('API响应: ${signupResponse.statusCode}');
      Logs.api.info('响应体: ${signupResponse.body}');

      if (signupResponse.statusCode == 200) {
        Logs.auth.info('注册成功（新用户）');
        final data = jsonDecode(signupResponse.body);
        return AuthResult.fromJson(data);
      } else {
        final signupError = jsonDecode(signupResponse.body);
        Logs.auth.warning('注册失败: ${signupError['message']}');
        throw AuthException(
          message: signupError['message'] ?? '注册失败，请稍后重试',
          code: signupError['code'],
        );
      }
    } on AuthException {
      rethrow;
    } on http.ClientException catch (e) {
      Logs.auth.warning('HTTP 客户端异常: $e');
      throw NetworkException(
        message: '网络请求失败',
        originalError: e,
      );
    } catch (e) {
      Logs.auth.warning('异常: $e');
      if (e is NetworkException) rethrow;

      throw const NetworkException(
        message: '网络连接异常，请检查网络设置',
      );
    }
  }

  /// ==========================================
  /// 完整登录流程（一键调用）
  /// ==========================================
  ///
  /// 这个方法把上面 3 步合并成一个方法，方便调用
  /// 但在学习阶段，建议分开调用以理解流程
  static Future<AuthResult> loginWithPhone({
    required String phoneNumber,
    required String code,
    required String verificationId,
  }) async {
    // 第 2 步：验证验证码
    final verificationToken = await verifyCode(verificationId, code);

    // 第 3 步：智能登录/注册
    return await signInOrSignUp(
      verificationToken: verificationToken,
      phoneNumber: phoneNumber,
 );
  }
}