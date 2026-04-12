import '../constants/api_endpoints.dart';
import '../services/api_client.dart';
import '../utils/logger.dart';

/// 认证相关 API 服务
///
/// 负责与后端认证接口交互:
/// - Token 刷新
/// - 用户登出
class AuthApiService {
  static final AuthApiService _instance = AuthApiService._internal();
  factory AuthApiService() => _instance;
  AuthApiService._internal();

  static AuthApiService get instance => _instance;

  /// 刷新 Access Token
  ///
  /// 调用后端 POST /api/auth/refresh-token
  /// 返回新的 access_token 和 refresh_token
  Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
    Logs.auth.info('🔄 开始调用后端刷新 Token 接口...');

    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        '${ApiEndpoints.apiPrefix}/auth/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      if (!response.isSuccessful || response.data == null) {
        throw Exception('Token 刷新失败: ${response.message}');
      }

      final data = response.data!;
      
      // 后端返回格式:
      // {
      //   "access_token": "xxx",
      //   "refresh_token": "xxx",
      //   "expires_in": 86400,
      //   "refresh_expires_in": 604800
      // }
      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;
      final expiresIn = data['expires_in'] as int?;
      final refreshExpiresIn = data['refresh_expires_in'] as int?;

      if (newAccessToken == null || newRefreshToken == null) {
        throw Exception('Token 刷新响应格式错误');
      }

      Logs.auth.info('✅ Token 刷新成功, Access Token 有效期: ${expiresIn ?? 86400}s');

      return {
        'accessToken': newAccessToken,
        'refreshToken': newRefreshToken,
        'expiresIn': expiresIn ?? 86400,
        'refreshExpiresIn': refreshExpiresIn ?? 604800,
      };
    } catch (e) {
      Logs.auth.error('❌ 调用 Token 刷新接口异常: $e');
      rethrow;
    }
  }

  /// 用户登出
  ///
  /// 调用后端 POST /api/auth/sign-out
  Future<void> signOut() async {
    Logs.auth.info('🚪 开始调用后端登出接口...');

    try {
      final response = await ApiClient.instance.post(
        '${ApiEndpoints.apiPrefix}/auth/sign-out',
      );

      if (response.isSuccessful) {
        Logs.auth.info('✅ 后端登出成功');
      } else {
        Logs.auth.warning('⚠️ 后端登出失败: ${response.message}');
      }
    } catch (e) {
      Logs.auth.error('❌ 调用登出接口异常: $e');
      // 即使后端失败,也要清除本地状态
    }
  }
}
