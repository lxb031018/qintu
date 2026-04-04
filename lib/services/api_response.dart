/// API 响应包装器
class ApiResponse<T> {
  /// 响应代码
  final String code;
  
  /// 响应消息
  final String message;
  
  /// 响应数据
  final T? data;
  
  /// HTTP 状态码
  final int? statusCode;

  const ApiResponse({
    required this.code,
    required this.message,
    this.data,
    this.statusCode,
  });

  /// 是否成功
  bool get isSuccess => code == 'SUCCESS';

  /// 是否失败
  bool get isFailure => !isSuccess;

  /// 创建成功响应
  static ApiResponse<T> success<T>({
    required T data,
    String message = '操作成功',
    int? statusCode,
  }) {
    return ApiResponse<T>(
      code: 'SUCCESS',
      message: message,
      data: data,
      statusCode: statusCode ?? 200,
    );
  }

  /// 创建失败响应
  static ApiResponse<T> failure<T>({
    required String code,
    required String message,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      code: code,
      message: message,
      statusCode: statusCode ?? 400,
    );
  }

  /// 从 JSON 创建
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      code: json['code'] as String,
      message: json['message'] as String,
      data: json['data'] as T?,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(code: $code, message: $message, data: $data)';
  }
}

/// API 异常类
class ApiException implements Exception {
  /// 错误代码
  final String code;
  
  /// 错误消息
  final String message;
  
  /// HTTP 状态码
  final int? statusCode;
  
  /// 原始异常
  final dynamic originalError;

  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    return 'ApiException($code: $message)';
  }
}
