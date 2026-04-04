import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../services/secure_storage.dart';
import '../utils/logger.dart';
import '../utils/exceptions.dart';

/// API 响应包装器
class ApiResponse<T> {
  final int statusCode;
  final T? data;
  final String? message;
  final bool success;

  ApiResponse({
    required this.statusCode,
    this.data,
    this.message,
    required this.success,
  });

  bool get isSuccessful => success && statusCode >= 200 && statusCode < 300;
  bool get hasError => !success || statusCode >= 400;

  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, success: $success, message: $message)';
  }
}

/// 统一的 HTTP 客户端
///
/// 基于 Dio 封装，提供：
/// - 统一的请求/响应处理
/// - 自动 Token 注入
/// - 错误处理和重试机制
/// - 请求/响应拦截器
class ApiClient {
  late final Dio _dio;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.cloudBaseApiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  /// 获取单例实例
  static ApiClient get instance => _instance;

  /// 获取 Dio 实例（用于特殊场景）
  Dio get dio => _dio;

  /// 设置拦截器
  void _setupInterceptors() {
    // 请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        Logs.network.info('🌐 发起请求: ${options.method} ${options.uri}');
        
        // 自动注入 Token
        final accessToken = await SecureStorage.getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
          Logs.network.info('🔑 已注入 Access Token');
        }
        
        // 脱敏日志
        if (options.data != null) {
          final dataStr = options.data.toString();
          final sanitizedData = _sanitizeData(dataStr);
          Logs.network.info('📤 请求数据: $sanitizedData');
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logs.network.info('✅ 响应成功: ${response.statusCode} ${response.requestOptions.uri}');
        Logs.network.info('📥 响应数据: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        Logs.network.info('❌ 请求失败: ${error.requestOptions.uri}');
        Logs.network.info('错误状态: ${error.response?.statusCode}');
        Logs.network.info('错误信息: ${error.message}');
        return handler.next(error);
      },
    ));

    // Token 刷新拦截器
    _dio.interceptors.add(TokenRefreshInterceptor());
  }

  /// 数据脱敏（隐藏敏感信息）
  String _sanitizeData(String data) {
    String sanitized = data;
    
    // 隐藏手机号中间4位
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(\d{3})\d{4}(\d{4})'),
      (match) => '${match.group(1)}****${match.group(2)}',
    );
    
    // 隐藏 Token
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'"(access_token|refresh_token|token)"\s*:\s*"[^"]+"'),
      (match) => '${match.group(1)}: "***HIDDEN***"',
    );
    
    return sanitized;
  }

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      
      return ApiResponse<T>(
        statusCode: response.statusCode ?? 0,
        data: response.data,
        success: true,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      Logs.network.info('未知错误: $e');
      return ApiResponse<T>(
        statusCode: 0,
        success: false,
        message: '未知错误: ${e.toString()}',
      );
    }
  }

  /// POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return ApiResponse<T>(
        statusCode: response.statusCode ?? 0,
        data: response.data,
        success: true,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      Logs.network.info('未知错误: $e');
      return ApiResponse<T>(
        statusCode: 0,
        success: false,
        message: '未知错误: ${e.toString()}',
      );
    }
  }

  /// PUT 请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return ApiResponse<T>(
        statusCode: response.statusCode ?? 0,
        data: response.data,
        success: true,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      Logs.network.info('未知错误: $e');
      return ApiResponse<T>(
        statusCode: 0,
        success: false,
        message: '未知错误: ${e.toString()}',
      );
    }
  }

  /// DELETE 请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return ApiResponse<T>(
        statusCode: response.statusCode ?? 0,
        data: response.data,
        success: true,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      Logs.network.info('未知错误: $e');
      return ApiResponse<T>(
        statusCode: 0,
        success: false,
        message: '未知错误: ${e.toString()}',
      );
    }
  }

  /// 处理 Dio 错误
  ApiResponse<T> _handleDioError<T>(DioException error) {
    String message = '网络请求失败';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '请求超时，请检查网络连接';
        break;
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        message = _getErrorMessageByStatusCode(statusCode);
        break;
        
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
        
      case DioExceptionType.badCertificate:
        message = '证书验证失败';
        break;
        
      case DioExceptionType.connectionError:
        message = '网络连接失败';
        break;
        
      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException')) {
          message = '网络连接失败，请检查网络设置';
        } else {
          message = '网络请求异常';
        }
        break;
    }
    
    Logs.network.info('❌ 请求失败: $message');
    
    return ApiResponse<T>(
      statusCode: error.response?.statusCode ?? 0,
      success: false,
      message: message,
    );
  }

  /// 根据状态码获取错误信息
  String _getErrorMessageByStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '没有权限访问';
      case 404:
        return '请求的资源不存在';
      case 500:
        return '服务器错误，请稍后重试';
      case 502:
      case 503:
        return '服务暂时不可用，请稍后重试';
      default:
        return '请求失败 (状态码: $statusCode)';
    }
  }

  /// 重置 Base URL
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    Logs.network.info('🔧 Base URL 已更新: $baseUrl');
  }

  /// 清除所有 Token
  Future<void> clearTokens() async {
    _dio.options.headers.remove('Authorization');
    Logs.network.info('🔓 Authorization Header 已清除');
  }
}

/// Token 刷新拦截器
class TokenRefreshInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<ErrorInterceptorHandler> _queue = [];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 只处理 401 错误（未授权）
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _queue.add(handler);
      await _refreshToken();
    } else if (err.response?.statusCode == 401 && _isRefreshing) {
      _queue.add(handler);
    } else {
      super.onError(err, handler);
    }
  }

  /// 刷新 Token
  Future<void> _refreshToken() async {
    _isRefreshing = true;
    
    try {
      Logs.network.info('🔄 开始刷新 Token...');
      
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const AppException(message: '没有可用的 Refresh Token，需要重新登录');
      }
      
      // TODO: 实现 Token 刷新逻辑
      // 这里需要调用后端的 Token 刷新接口
      // 例如: final response = await ApiClient().post('/auth/refresh', data: {'refresh_token': refreshToken});
      
      Logs.network.info('⚠️ Token 刷新功能尚未实现，需要后端支持');
      
      // 暂时直接拒绝所有请求
      _rejectAll(message: 'Token 已过期，请重新登录');
    } catch (e) {
      Logs.network.info('❌ Token 刷新失败: $e');
      _rejectAll(message: 'Token 刷新失败: ${e.toString()}');
    } finally {
      _isRefreshing = false;
      _queue.clear();
    }
  }

  /// 拒绝所有排队的请求
  void _rejectAll({required String message}) {
    for (final handler in _queue) {
      handler.reject(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: AppException(message: message),
        ),
      );
    }
  }
}
