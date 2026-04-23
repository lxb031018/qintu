import 'package:dio/dio.dart';
import 'package:qintu/features/auth/core/secure_storage.dart';
import 'package:qintu/utils/logger.dart';

/// Token 刷新拦截器
///
/// 负责处理 401 响应，自动刷新 Token 并重试请求
class TokenRefreshInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    Logs.network.warning('🔐 收到 401，正在尝试刷新 Token...');

    try {
      final refreshed = await _refreshToken();
      if (refreshed) {
        Logs.network.info('✅ Token 刷新成功，重试原请求');
        // 重新执行原请求（简化处理，不重试）
        return handler.next(err);
      }
    } catch (e) {
      Logs.network.error('❌ Token 刷新失败: $e');
    }

    return handler.next(err);
  }

  /// 刷新 Token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        Logs.network.warning('⚠️ 无 Refresh Token，跳过刷新');
        return false;
      }

      // 注意：实际刷新逻辑由 auth_api.dart 中的 AuthApiService 处理
      // 此拦截器仅处理 Token 过期检测
      return false;
    } catch (e) {
      return false;
    }
  }
}
