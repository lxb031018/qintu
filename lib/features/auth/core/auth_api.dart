import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../constants/api_endpoints.dart';
import '../../../constants/app_durations.dart';
import '../../../config/environments/environment_manager.dart';
import '../../../models/auth/auth_result.dart';
import '../../../utils/logger.dart';
import '../../../utils/errors/exceptions.dart';
import '../../../utils/platform/phone_utils.dart';

/// ============================================
/// 认证 API 层
///
/// 纯 HTTP 调用，返回数据模型，无 Flutter 依赖
/// ============================================

class AuthApi {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: AppDurations.networkTimeout,
    receiveTimeout: AppDurations.networkTimeout,
    sendTimeout: AppDurations.networkTimeout,
  ));

  /// 认证 API 基础地址
  static String get _baseUrl => EnvironmentManager.baseUrl;

  /// 通用请求头
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  /// ==========================================
  /// 第 1 步：发送短信验证码
  /// ==========================================
  static Future<String> sendVerificationCode(String phoneNumber) async {
    final url = Uri.parse('$_baseUrl${ApiEndpoints.sendVerificationCode}');

    Logs.auth.info('API请求: POST $url');
    Logs.api.info('请求体: phone_number=${PhoneUtils.maskForLog(phoneNumber)}');

    try {
      final response = await _dio.post(
        url.toString(),
        options: Options(headers: _headers),
        data: jsonEncode({
          'target': 'ANY',
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
      throw NetworkException(message: '网络请求失败', originalError: e);
    } catch (e) {
      Logs.auth.warning('网络请求异常: $e');
      if (e is NetworkException) rethrow;
      throw const NetworkException(message: '网络连接异常，请检查网络设置');
    }
  }

  /// ==========================================
  /// 第 2 步：验证验证码
  /// ==========================================
  static Future<String> verifyCode(String verificationId, String code) async {
    final url = Uri.parse('$_baseUrl${ApiEndpoints.verifyCode}');

    Logs.auth.info('API请求: POST $url');
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
      throw NetworkException(message: '网络请求失败', originalError: e);
    } catch (e) {
      Logs.auth.warning('网络请求异常: $e');
      if (e is NetworkException) rethrow;
      throw const NetworkException(message: '网络连接异常，请检查网络设置');
    }
  }

  /// ==========================================
  /// 第 3 步：登录（老用户）
  /// ==========================================
  static Future<AuthResult> signIn(String verificationToken) async {
    final url = Uri.parse('$_baseUrl${ApiEndpoints.signIn}');

    Logs.auth.info('API请求: POST $url');

    try {
      final response = await _dio.post(
        url.toString(),
        options: Options(headers: _headers),
        data: jsonEncode({
          'verification_token': verificationToken,
        }),
      );

      Logs.api.info('API响应: ${response.statusCode}');
      Logs.api.info('响应体: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        Logs.auth.info('登录成功（老用户）');
        return AuthResult.fromJson(data);
      }

      final error = response.data is String ? jsonDecode(response.data) : response.data;
      Logs.auth.warning('登录失败: ${error['error_description'] ?? error['error']}');
      throw AuthException(
        message: error['error_description'] ?? error['error'] ?? '登录失败',
        code: error['error_code'],
      );
    } on DioException catch (e) {
      Logs.auth.warning('HTTP 客户端异常: $e');
      throw NetworkException(message: '网络请求失败', originalError: e);
    } on AuthException {
      rethrow;
    } catch (e) {
      Logs.auth.warning('异常: $e');
      if (e is NetworkException) rethrow;
      throw const NetworkException(message: '网络连接异常，请检查网络设置');
    }
  }

  /// ==========================================
  /// 第 4 步：注册（ 新用户）
  /// ==========================================
  static Future<AuthResult> signUp({
    required String verificationToken,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$_baseUrl${ApiEndpoints.signUp}');

    Logs.auth.info('API请求: POST $url');

    try {
      final response = await _dio.post(
        url.toString(),
        options: Options(headers: _headers),
        data: jsonEncode({
          'phone_number': phoneNumber,
          'verification_token': verificationToken,
        }),
      );

      Logs.api.info('API响应: ${response.statusCode}');
      Logs.api.info('响应体: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        Logs.auth.info('注册成功（新用户）');
        return AuthResult.fromJson(data);
      }

      final error = response.data is String ? jsonDecode(response.data) : response.data;
      Logs.auth.warning('注册失败: ${error['error_description'] ?? error['error']}');
      throw AuthException(
        message: error['error_description'] ?? error['error'] ?? '注册失败，请稍后重试',
        code: error['error_code'],
      );
    } on DioException catch (e) {
      Logs.auth.warning('HTTP 客户端异常: $e');
      throw NetworkException(message: '网络请求失败', originalError: e);
    } on AuthException {
      rethrow;
    } catch (e) {
      Logs.auth.warning('异常: $e');
      if (e is NetworkException) rethrow;
      throw const NetworkException(message: '网络连接异常，请检查网络设置');
    }
  }
}
