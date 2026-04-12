import 'package:dio/dio.dart';
import '../config/environments/environment_manager.dart';
import '../constants/app_durations.dart';
import '../services/secure_storage.dart';
import '../services/api_response.dart';
import '../services/token_refresh_interceptor.dart';
import '../utils/logger.dart';
import '../utils/http_error_handler.dart';

/// 统一的 HTTP 客户端
///
/// 基于 Dio 封装,提供:
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
      baseUrl: EnvironmentManager.baseUrl,
      connectTimeout: Duration(seconds: EnvironmentManager.current.connectTimeout),
      receiveTimeout: Duration(seconds: EnvironmentManager.current.receiveTimeout),
      sendTimeout: AppDurations.networkTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();

    // 注册环境变化监听器
    _registerEnvironmentListener();
  }

  /// 获取单例实例
  static ApiClient get instance => _instance;

  /// 获取 Dio 实例(用于特殊场景)
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

        // 注入 OpenID（后端认证中间件需要）
        final userId = await SecureStorage.getUserId();
        if (userId != null && userId.isNotEmpty) {
          options.headers['X-User-OpenID'] = userId;
          Logs.network.info('👤 已注入 X-User-OpenID: $userId');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logs.network.info('✅ 响应成功: ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) {
        Logs.network.info('❌ 请求失败: ${error.requestOptions.uri}');
        return handler.next(error);
      },
    ));

    // Token 刷新拦截器
    _dio.interceptors.add(TokenRefreshInterceptor());
  }

  /// 注册环境变化监听器
  ///
  /// 当环境切换时，自动更新 Dio 的 baseUrl 和超时配置
  void _registerEnvironmentListener() {
    EnvironmentManager.addListener((oldEnv, newEnv) {
      final config = EnvironmentManager.current;
      _dio.options.baseUrl = config.baseUrl;
      _dio.options.connectTimeout = Duration(seconds: config.connectTimeout);
      _dio.options.receiveTimeout = Duration(seconds: config.receiveTimeout);
      Logs.network.info('🔄 环境已切换: ${config.name}');
      Logs.network.info('📍 新 API 地址: ${config.baseUrl}');
    });
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
      return _handleError<T>(e);
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
      return _handleError<T>(e);
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
      return _handleError<T>(e);
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
      return _handleError<T>(e);
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
  ApiResponse<T> _handleError<T>(DioException error) {
    final message = HttpErrorHandler.handleDioError(error, error.response?.data);
    return ApiResponse<T>(
      statusCode: error.response?.statusCode ?? 0,
      success: false,
      message: message,
    );
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
