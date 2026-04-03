import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import '../constants/api_endpoints.dart';
import '../constants/app_config.dart';
import '../constants/app_strings.dart';
import '../models/auth_result.dart';

/// ============================================
/// CloudBase 认证服务
///
/// 封装所有与用户登录相关的 HTTP API 调用
/// ============================================

class CloudBaseAuthService {
  /// CloudBase 环境配置
  static const String envId = AppConfig.envId;

  /// 认证 API 基础地址
  static const String authBaseUrl = ApiEndpoints.authBaseUrl;

  /// Publishable Key（用于客户端认证，可以公开）
  static const String publishableKey = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjlkMWRjMzFlLWI0ZDAtNDQ4Yi1hNzZmLWIwY2M2M2Q4MTQ5OCJ9.eyJpc3MiOiJodHRwczovL3FpbnR1LWNsb3VkZWJhc2UtNWY1YnB1ajEzYmM2NDY3LmFwLXNoYW5naGFpLnRjYi1hcGkudGVuY2VudGNsb3VkYXBpLmNvbSIsInN1YiI6ImFub24iLCJhdWQiOiJxaW50dS1jbG91ZGViYXNlLTVmNWJwdWoxM2JjNjQ2NyIsImV4cCI6NDA3ODg3MDg5MywiaWF0IjoxNzc1MTg3NjkzLCJub25jZSI6IjZOeTVQbHBtU215WHdIZjZ2eWFnTlEiLCJhdF9oYXNoIjoiNk55NVBscG1TbXlYd0hmNnZ5YWdOUSIsIm5hbWUiOiJBbm9ueW1vdXMiLCJzY29wZSI6ImFub255bW91cyIsInByb2plY3RfaWQiOiJxaW50dS1jbG91ZGViYXNlLTVmNWJwdWoxM2JjNjQ2NyIsIm1ldGEiOnsicGxhdGZvcm0iOiJQdWJsaXNoYWJsZUtleSJ9LCJ1c2VyX3R5cGUiOiIiLCJjbGllbnRfdHlwZSI6ImNsaWVudF91c2VyIiwiaXNfc3lzdGVtX2FkbWluIjpmYWxzZX0.oLl3ED22kCq_1tnWzxGb-jV4xsJMNlsnLBZ_eEptkGs5Q0Wfe3T75HC3HsuAbFogS7PnlLBieLkYLXGflMdz_IZN_RUZCd4SC9HTH1N9wf4Ov7OfucNO1qQgpaQU74XUAWC70gwnRsNjnmXOgKuDI0-iPOzsMSPWtV-3ci95zFlu2oG1EF7A3M0NWBuS5nNkYeLfQLWskNHt-4bnsNjGvStGKbs2Kz7JqI2PoV07an9WcfOtVKXafzCJwLJUesrlR2jq6d15pbBSStsPgZ4EAkMBzPsBUJFiq8SKhsTOgwhhLow3Ax_JcnhYXcUH43iJ11ky4n7BCemx_r_hbus0Ow';

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

    developer.log('========== 发送验证码 ==========', name: 'AuthService');
    developer.log('URL: $url', name: 'AuthService');
    developer.log('手机号: $phoneNumber', name: 'AuthService');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'phone_number': phoneNumber,
          'target': ApiEndpoints.targetAny,
        }),
      );

      developer.log('响应状态码: ${response.statusCode}', name: 'AuthService');
      developer.log('响应内容: ${response.body}', name: 'AuthService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log('✅ 发送成功，verification_id: ${data['verification_id']}', name: 'AuthService');
        return data['verification_id'];
      } else {
        final error = jsonDecode(response.body);
        developer.log('❌ 发送失败: ${error['message'] ?? response.body}', name: 'AuthService');

        if (error['error_code'] == 429) {
          throw Exception(AppStrings.codeSendTooFrequent);
        }
        throw Exception(AppStrings.codeSendFailed);
      }
    } catch (e) {
      developer.log('❌ 网络请求异常: $e', name: 'AuthService');

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

    developer.log('========== 验证验证码 ==========', name: 'AuthService');
    developer.log('URL: $url', name: 'AuthService');
    developer.log('verification_id: $verificationId', name: 'AuthService');
    developer.log('验证码: $code', name: 'AuthService');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'verification_id': verificationId,
          'verification_code': code,
        }),
      );

      developer.log('响应状态码: ${response.statusCode}', name: 'AuthService');
      developer.log('响应内容: ${response.body}', name: 'AuthService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log('✅ 验证成功，verification_token: ${data['verification_token']}', name: 'AuthService');
        return data['verification_token'];
      } else {
        final error = jsonDecode(response.body);
        developer.log('❌ 验证失败: ${error['message'] ?? response.body}', name: 'AuthService');

        if (error['error_code'] == 3) {
          throw Exception(AppStrings.codeInvalidOrExpired);
        }
        throw Exception(AppStrings.codeInvalid);
      }
    } catch (e) {
      developer.log('❌ 网络请求异常: $e', name: 'AuthService');

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
    developer.log('========== 智能登录/注册 ==========', name: 'AuthService');

    try {
      // 先尝试登录（老用户）
      developer.log('尝试登录（老用户）...', name: 'AuthService');
      final loginUrl = Uri.parse('$authBaseUrl${ApiEndpoints.signIn}');

      final loginResponse = await http.post(
        loginUrl,
        headers: _headers,
        body: jsonEncode({
          'verification_token': verificationToken,
        }),
      );

      if (loginResponse.statusCode == 200) {
        developer.log('✅ 登录成功（老用户）', name: 'AuthService');
        final data = jsonDecode(loginResponse.body);
        return AuthResult.fromJson(data);
      }

      // 如果登录失败，检查错误类型
      final error = jsonDecode(loginResponse.body);
      developer.log('登录失败: ${error['error_description']}', name: 'AuthService');

      // 如果是"用户不存在"错误，尝试注册
      if (error['error_code'] == 5 || error['error'] == 'not_found') {
        developer.log('用户不存在，尝试注册（新用户）...', name: 'AuthService');

        final signupUrl = Uri.parse('$authBaseUrl${ApiEndpoints.signUp}');
        final signupResponse = await http.post(
          signupUrl,
          headers: _headers,
          body: jsonEncode({
            'verification_token': verificationToken,
            'phone_number': phoneNumber,
          }),
        );

        if (signupResponse.statusCode == 200) {
          developer.log('✅ 注册成功（新用户）', name: 'AuthService');
          final data = jsonDecode(signupResponse.body);
          return AuthResult.fromJson(data);
        } else {
          final signupError = jsonDecode(signupResponse.body);
          developer.log('❌ 注册失败: ${signupError['error_description']}', name: 'AuthService');
          throw Exception(AppStrings.registerFailed);
        }
      } else {
        throw Exception(AppStrings.loginFailed);
      }
    } catch (e) {
      developer.log('❌ 异常: $e', name: 'AuthService');

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