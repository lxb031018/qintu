import 'package:dio/dio.dart';
import 'package:qintu/config/amap_web_config.dart';
import 'package:qintu/utils/logger.dart';

/// ============================================
/// 第三方 API 统一客户端
///
/// 集中管理所有第三方 API 的 HTTP 请求（当前主要是高德地图）
///
/// 为什么需要独立于 ApiClient：
/// - 后端 API 需要带 Token、OpenID 等认证信息
/// - 第三方 API（如高德）使用 API Key 认证，路径和认证方式不同
/// - 第三方 API 可能有不同的超时配置
///
/// 使用方式：
/// ```dart
/// final client = ThirdPartyApiClient.instance;
/// final response = await client.get('/v3/place/text', queryParameters: {...});
/// ```
///
/// 新增第三方 API 时：
/// - 只需在对应 module 的 api/ 或 core/ 中调用 ThirdPartyApiClient
/// - 无需创建新的 Dio 实例
/// - 统一配置（超时、日志）在一处生效
/// ============================================
class ThirdPartyApiClient {
  /// 单例模式，确保所有第三方 API 共用同一个 Dio 实例
  static final ThirdPartyApiClient _instance = ThirdPartyApiClient._internal();

  /// 公开访问入口
  static ThirdPartyApiClient get instance => _instance;

  ThirdPartyApiClient._internal() {
    _initDio();
  }

  /// Dio 实例
  late final Dio _dio;

  /// 初始化 Dio 配置
  void _initDio() {
    _dio = Dio(BaseOptions(
      /// 连接超时：10秒（适合高德 API）
      connectTimeout: const Duration(seconds: 10),

      /// 接收超时：15秒（路线规划等大数据量请求）
      receiveTimeout: const Duration(seconds: 15),

      /// 高德 API 的基础 URL
      baseUrl: 'https://restapi.amap.com',

      /// 默认 JSON 响应格式
      responseType: ResponseType.json,
    ));

    /// 添加日志拦截器（仅在 debug 模式）
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => Logs.api.info(obj.toString()),
    ));
  }

  /// 获取 Dio 实例
  ///
  /// 某些 API 可能有特殊的请求配置需求，
  /// 可以通过 `client.dio` 获取原始 Dio 实例进行自定义
  Dio get dio => _dio;

  /// GET 请求
  ///
  /// [path] API 路径（不含 baseUrl）
  /// [queryParameters] 查询参数
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST 请求
  ///
  /// [path] API 路径（不含 baseUrl）
  /// [data] 请求体数据
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ========================================
  // 高德 API 专用便捷方法
  // ========================================

  /// 高德 API 通用查询参数
  ///
  /// 自动注入 API Key，统一所有高德 API 的认证方式
  Map<String, dynamic> amapQueryParams({Map<String, dynamic>? extra}) {
    final params = <String, dynamic>{
      'key': AmapWebConfig.webApiKey,
      'output': 'json',
    };
    if (extra != null) {
      params.addAll(extra);
    }
    return params;
  }

  /// 检查 API Key 是否配置
  bool get hasApiKey => AmapWebConfig.webApiKey.isNotEmpty;
}
