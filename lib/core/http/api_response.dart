/// API 响应包装器
/// 
/// 封装 HTTP 响应,提供统一的响应处理接口
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
