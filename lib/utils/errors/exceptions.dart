// ============================================
// 自定义异常类
//
// 统一定义应用中使用的各种异常类型
// 便于类型安全的错误处理
// ============================================

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
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// 验证码相关异常
class VerificationCodeException extends AppException {
  const VerificationCodeException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Token 过期异常
class TokenExpiredException extends AppException {
  const TokenExpiredException({
    super.message = 'Token 已过期，请重新登录',
    super.originalError,
    super.stackTrace,
  });
}

/// Token 无效异常
class TokenInvalidException extends AppException {
  const TokenInvalidException({
    super.message = 'Token 无效',
    super.originalError,
    super.stackTrace,
  });
}

/// ============================================
/// 网络相关异常
/// ============================================

/// 网络连接异常（无法连接服务器）
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    this.statusCode,
    super.originalError,
    super.stackTrace,
  });

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
    super.message = '请求超时，请检查网络连接',
    super.originalError,
    super.stackTrace,
  });
}

/// HTTP 请求异常（服务端返回错误状态码）
class HttpException extends AppException {
  final int statusCode;

  const HttpException({
    required this.statusCode,
    required super.message,
    super.originalError,
    super.stackTrace,
  });

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
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// 数据未找到异常
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = '数据未找到',
    super.originalError,
    super.stackTrace,
  });
}

/// ============================================
/// 位置服务相关异常
/// ============================================

/// 位置权限被拒绝
class LocationPermissionDeniedException extends AppException {
  const LocationPermissionDeniedException({
    super.message = '位置权限被拒绝',
    super.originalError,
    super.stackTrace,
  });
}

/// 位置服务未启用
class LocationServiceDisabledException extends AppException {
  const LocationServiceDisabledException({
    super.message = '位置服务未启用',
    super.originalError,
    super.stackTrace,
  });
}

/// 位置获取失败
class LocationFetchException extends AppException {
  const LocationFetchException({
    super.message = '位置获取失败',
    super.originalError,
    super.stackTrace,
  });
}

/// ============================================
/// 通用业务异常
/// ============================================

/// 操作频率过高异常
class RateLimitException extends AppException {
  const RateLimitException({
    super.message = '操作过于频繁，请稍后再试',
    super.originalError,
    super.stackTrace,
  });
}

/// 权限不足异常
class PermissionDeniedException extends AppException {
  const PermissionDeniedException({
    super.message = '权限不足',
    super.originalError,
    super.stackTrace,
  });
}

/// 未知异常
class UnknownException extends AppException {
  const UnknownException({
    super.message = '未知错误',
    super.originalError,
    super.stackTrace,
  });
}
