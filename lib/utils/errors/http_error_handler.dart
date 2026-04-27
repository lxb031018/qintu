import 'package:dio/dio.dart';
import '../logger.dart';

/// HTTP 错误处理工具
/// 提供 Dio 错误的统一处理和错误消息映射
class HttpErrorHandler {
  /// 处理 Dio 错误
  static String handleDioError(DioException error, [dynamic responseData]) {
    String message = '网络请求失败';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '请求超时，请检查网络连接';
        break;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        message = getErrorMessageByStatusCode(statusCode, responseData);
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
    return message;
  }

  /// 根据状态码获取错误信息
  static String getErrorMessageByStatusCode(int? statusCode, [dynamic responseData]) {
    // 优先使用后端返回的具体错误消息
    if (responseData != null && responseData is Map) {
      final message = responseData['message'] ?? responseData['error'];
      if (message != null && message is String && message.isNotEmpty) {
        return message;
      }
    }

    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '没有权限访问';
      case 404:
        return '请求的资源不存在';
      case 409:
        return '操作冲突，请稍后重试';
      case 500:
        return '服务器错误，请稍后重试';
      case 502:
      case 503:
        return '服务暂时不可用，请稍后重试';
      default:
        return '请求失败 (状态码: $statusCode)';
    }
  }
}
