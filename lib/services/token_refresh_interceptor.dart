import 'package:dio/dio.dart';
import '../services/secure_storage.dart';
import '../services/auth_api_service.dart';
import '../services/api_client.dart';
import '../utils/logger.dart';
import '../utils/exceptions.dart';

/// Token 刷新拦截器
///
/// 当收到 401 错误时自动刷新 Token,并重试失败的请求
class TokenRefreshInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<Function()> _retryQueue = [];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 只处理 401 错误(未授权)
    if (err.response?.statusCode == 401) {
      if (!_isRefreshing) {
        // 第一个 401 错误,开始刷新 Token
        _isRefreshing = true;
        try {
          await _refreshToken();
          // Token 刷新成功,重试当前请求
          final response = await _retryRequest(err.requestOptions);
          handler.resolve(response);
        } catch (e) {
          // Token 刷新失败,拒绝请求
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: AppException(message: 'Token 已过期,请重新登录'),
            ),
          );
        } finally {
          _isRefreshing = false;
          // 重试所有排队的请求
          await _retryAll();
          _retryQueue.clear();
        }
      } else {
        // Token 正在刷新,将请求加入队列
        _retryQueue.add(() async {
          try {
            final response = await _retryRequest(err.requestOptions);
            handler.resolve(response);
          } catch (e) {
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                error: AppException(message: '重试失败: ${e.toString()}'),
              ),
            );
          }
        });
      }
    } else {
      super.onError(err, handler);
    }
  }

  /// 重试单个请求
  /// 使用 ApiClient 的 Dio 实例，保持拦截器和配置一致
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    // 使用 ApiClient 单例重试请求
    final apiClient = ApiClient();
    return await apiClient.dio.fetch(requestOptions);
  }

  /// 刷新 Token
  Future<void> _refreshToken() async {
    Logs.network.info('🔄 开始刷新 Token...');

    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const AppException(message: '没有可用的 Refresh Token,需要重新登录');
    }

    // 调用后端 Token 刷新接口
    final tokens = await AuthApiService.instance.refreshAccessToken(refreshToken);

    // 保存新的 Token
    await SecureStorage.saveTokens(
      accessToken: tokens['accessToken'],
      refreshToken: tokens['refreshToken'],
      accessTokenExpiresIn: tokens['expiresIn'],
      refreshTokenExpiresIn: tokens['refreshExpiresIn'],
      phoneNumber: await SecureStorage.getPhoneNumber() ?? '',
      userId: await SecureStorage.getUserId() ?? '',
      role: await SecureStorage.getUserRole(),
    );

    Logs.network.info('✅ Token 刷新成功,已保存新 Token');
  }

  /// 重试所有排队的请求
  Future<void> _retryAll() async {
    for (final retryFunc in _retryQueue) {
      try {
        await retryFunc();
      } catch (e) {
        Logs.network.warning('重试请求失败: $e');
      }
    }
  }
}
