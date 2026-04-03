import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../config/app_config.dart';
import '../constants/app_strings.dart';
import '../models/auth_result.dart';
import '../utils/logger.dart';

/// CloudBase 认证服务 - 封装所有与用户登录相关的 HTTP API 调用

class CloudBaseAuthService {
  /// CloudBase 环境配置
  static String get envId => AppConfig.envId;

  /// 认证 API 基础地址（统一来源：ApiEndpoints）
  static String get authBaseUrl => ApiEndpoints.authBaseUrl;

  /// Publishable Key（从环境变量读取）
  static String get publishableKey => AppConfig.publishableKey;

  /// 通用的请求头（包含 Publishable Key 认证）
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $publishableKey',
      };

  /// ==========================================
  /// 第 1 步：发送短信验证码
  /// ==========================================
  ///
  /// [phoneNumber] 手机号，格式必须为 "+86 13800138000"（带空格）
  ///
  /// 返回：verification_id（用于第 2 步验证）
  static Future<String> sendVerificationCode(String phoneNumber) async {
    final url = Uri.parse('$authBaseUrl${ApiEndpoints.sendVerificationCode}');

    Logger.authSeparator('发送验证码');
    Logger.apiRequest(url.toString(), {'phone_number': phoneNumber, 'target': ApiEndpoints.targetAny});

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'phone_number': phoneNumber,
          'target': ApiEndpoints.targetAny,
        }),
      );

      Logger.apiResponse(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logger.authSuccess('发送成功，verification_id: ${data['verification_id']}');
        return data['verification_id'];
      } else {
        final error = jsonDecode(response.body);
        Logger.authError('发送失败: ${error['message'] ?? response.body}');

        if (error['error_code'] == 429) {
          throw Exception(AppStrings.codeSendTooFrequent);
        }
        throw Exception(AppStrings.codeSendFailed);
      }
    } catch (e) {
      Logger.authError('网络请求异常: $e');

      if (e is Exception && e.toString().contains('验证码')) {
        rethrow;
      }

      throw Exception(AppStrings.networkException);
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

    Logger.authSeparator('验证验证码');
    Logger.apiRequest(url.toString(), {
      'verification_id': verificationId,
      'verification_code': code,
    });

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'verification_id': verificationId,
          'verification_code': code,
        }),
      );

      Logger.apiResponse(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logger.authSuccess('验证成功，verification_token: ${data['verification_token']}');
        return data['verification_token'];
      } else {
        final error = jsonDecode(response.body);
        Logger.authError('验证失败: ${error['message'] ?? response.body}');

        if (error['error_code'] == 3) {
          throw Exception(AppStrings.codeInvalidOrExpired);
        }
        throw Exception(AppStrings.codeInvalid);
      }
    } catch (e) {
      Logger.authError('网络请求异常: $e');

      if (e is Exception && (e.toString().contains('验证码') || e.toString().contains('验证'))) {
        rethrow;
      }

      throw Exception(AppStrings.networkException);
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
    Logger.authSeparator('智能登录/注册');

    try {
      // 先尝试登录（老用户）
      Logger.auth('尝试登录（老用户）...');
      final loginUrl = Uri.parse('$authBaseUrl${ApiEndpoints.signIn}');

      Logger.apiRequest(loginUrl.toString(), {'verification_token': verificationToken});

      final loginResponse = await http.post(
        loginUrl,
        headers: _headers,
        body: jsonEncode({
          'verification_token': verificationToken,
        }),
      );

      Logger.apiResponse(loginResponse.statusCode, loginResponse.body);

      if (loginResponse.statusCode == 200) {
        Logger.authSuccess('登录成功（老用户）');
        final data = jsonDecode(loginResponse.body);
        return AuthResult.fromJson(data);
      }

      // 如果登录失败，检查错误类型
      final error = jsonDecode(loginResponse.body);
      Logger.auth('登录失败: ${error['error_description']}');

      // 如果是"用户不存在"错误，尝试注册
      if (error['error_code'] == 5 || error['error'] == 'not_found') {
        Logger.auth('用户不存在，尝试注册（新用户）...');

        final signupUrl = Uri.parse('$authBaseUrl${ApiEndpoints.signUp}');
        Logger.apiRequest(signupUrl.toString(), {
          'verification_token': verificationToken,
          'phone_number': phoneNumber,
        });

        final signupResponse = await http.post(
          signupUrl,
          headers: _headers,
          body: jsonEncode({
            'verification_token': verificationToken,
            'phone_number': phoneNumber,
          }),
        );

        Logger.apiResponse(signupResponse.statusCode, signupResponse.body);

        if (signupResponse.statusCode == 200) {
          Logger.authSuccess('注册成功（新用户）');
          final data = jsonDecode(signupResponse.body);
          return AuthResult.fromJson(data);
        } else {
          final signupError = jsonDecode(signupResponse.body);
          Logger.authError('注册失败: ${signupError['error_description']}');
          throw Exception(AppStrings.registerFailed);
        }
      } else {
        throw Exception(AppStrings.loginFailed);
      }
    } catch (e) {
      Logger.authError('异常: $e');

      if (e is Exception && e.toString().contains('失败')) {
        rethrow;
      }

      throw Exception(AppStrings.networkException);
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