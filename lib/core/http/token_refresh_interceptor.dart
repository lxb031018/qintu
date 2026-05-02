import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:qintu/features/auth/core/secure_storage.dart';
import 'package:qintu/constants/api_endpoints.dart';
import 'package:qintu/config/environments/environment_manager.dart';
import 'package:qintu/utils/logger.dart';
import '../../constants/app_durations.dart';

/// Token 刷新拦截器
///
/// 负责处理 401 响应，自动刷新 Token 并重试请求
class TokenRefreshInterceptor extends Interceptor {
  static final Dio _refreshDio = Dio(BaseOptions(
    baseUrl: EnvironmentManager.baseUrl,
    connectTimeout: AppDurations.networkTimeout,
    receiveTimeout: AppDurations.networkTimeout,
    sendTimeout: AppDurations.networkTimeout,
    headers: {'Content-Type': 'application/json'},
  ));

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    Logs.network.warning('🔐 收到 401，正在尝试刷新 Token...');

    final errorData = err.response?.data;
    if (errorData is Map && errorData['code'] == 'SESSION_REVOKED') {
      Logs.network.warning('⚠️ 会话已被废弃（另一设备登录），强制登出');
      return handler.next(err);
    }

    try {
      final refreshed = await _refreshToken();
      if (refreshed) {
        Logs.network.info('✅ Token 刷新成功，重试原请求');
        return handler.next(err);
      }
    } catch (e) {
      Logs.network.error('❌ Token 刷新失败: $e');
    }

    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        Logs.network.warning('⚠️ 无 Refresh Token，跳过刷新');
        return false;
      }

      final response = await _refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;

        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          final loginInfo = await SecureStorage.getLoginInfo();
          if (loginInfo != null) {
            await SecureStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
              accessTokenExpiresIn: data['expires_in'] ?? 7200,
              refreshTokenExpiresIn: data['refresh_expires_in'] ?? 0,
              phoneNumber: loginInfo.phoneNumber ?? '',
              userId: loginInfo.userId ?? '',
            );
            Logs.network.info('✅ 新 Token 已保存');
            return true;
          }
        }
      }
    } catch (e) {
      Logs.network.error('❌ Token 刷新异常: $e');
    }
    return false;
  }
}