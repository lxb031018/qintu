/// ============================================
/// 自定义异常类
///
/// 统一定义应用中使用的各种异常类型
/// 便于类型安全的错误处理
/// ============================================

/// 基础异常类
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    this.message = '未知错误',
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (code != null) {
      return '$runtimeType [$code]: $message';
    }
    return '$runtimeType: $message';
  }
}

/// ============================================
/// 认证相关异常
/// ============================================

/// 认证失败异常（登录、注册失败）
class AuthException extends AppException {
  const AuthException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 验证码相关异常
class VerificationCodeException extends AppException {
  const VerificationCodeException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Token 过期异常
class TokenExpiredException extends AppException {
  const TokenExpiredException({
    String message = 'Token 已过期，请重新登录',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Token 无效异常
class TokenInvalidException extends AppException {
  const TokenInvalidException({
    String message = 'Token 无效',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// ============================================
/// 网络相关异常
/// ============================================

/// 网络连接异常（无法连接服务器）
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required String message,
    this.statusCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() {
    if (statusCode != null) {
      return '$runtimeType [$statusCode]: $message';
    }
    return '$runtimeType: $message';
  }
}

/// 请求超时异常
class TimeoutException extends AppException {
  const TimeoutException({
    String message = '请求超时，请检查网络连接',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// HTTP 请求异常（服务端返回错误状态码）
class HttpException extends AppException {
  final int statusCode;

  const HttpException({
    required this.statusCode,
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() {
    return '$runtimeType [$statusCode]: $message';
  }
}

/// ============================================
/// 数据相关异常
/// ============================================

/// 数据解析异常（JSON 解析失败等）
class ParseException extends AppException {
  const ParseException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 数据未找到异常
class NotFoundException extends AppException {
  const NotFoundException({
    String message = '数据未找到',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// ============================================
/// 位置服务相关异常
/// ============================================

/// 位置权限被拒绝
class LocationPermissionDeniedException extends AppException {
  const LocationPermissionDeniedException({
    String message = '位置权限被拒绝',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 位置服务未启用
class LocationServiceDisabledException extends AppException {
  const LocationServiceDisabledException({
    String message = '位置服务未启用',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 位置获取失败
class LocationFetchException extends AppException {
  const LocationFetchException({
    String message = '位置获取失败',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// ============================================
/// 通用业务异常
/// ============================================

/// 操作频率过高异常
class RateLimitException extends AppException {
  const RateLimitException({
    String message = '操作过于频繁，请稍后再试',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 权限不足异常
class PermissionDeniedException extends AppException {
  const PermissionDeniedException({
    String message = '权限不足',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// 未知异常
class UnknownException extends AppException {
  const UnknownException({
    String message = '未知错误',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
