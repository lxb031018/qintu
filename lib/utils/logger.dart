import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'logger/log_config.dart';

export 'logger/log_config.dart';
export 'logger/file_logger.dart';

/// 亲途日志工具
///
/// 功能：
/// - 支持不同日志级别（debug/info/warning/error/critical）
/// - 支持标签分类
/// - 支持附加数据和堆栈跟踪
/// - 开发环境彩色输出
/// - 生产环境自动降级为 info 级别
/// - 支持文件日志（异步、自动轮转）
///
/// 使用示例：
/// ```dart
/// // 推荐方式：使用 Logs 预定义实例
/// Logs.auth.info('用户登录成功');
/// Logs.api.warning('API 请求超时');
/// Logs.app.error('应用启动失败', stackTrace: stackTrace);
///
/// // 自定义标签
/// const customLogger = Logger('CUSTOM');
/// customLogger.info('自定义日志');
/// ```
class Logger {
  /// 日志标签
  final String tag;

  const Logger(this.tag);

  // ==================== 公开 API ====================

  /// DEBUG 级别日志 - 开发调试
  void debug(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.debug, message, data: data);
  }

  /// INFO 级别日志 - 正常业务流程
  void info(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, data: data);
  }

  /// WARNING 级别日志 - 警告信息
  void warning(String message, {Map<String, dynamic>? data, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, data: data, stackTrace: stackTrace);
  }

  /// ERROR 级别日志 - 错误信息
  void error(String message, {Map<String, dynamic>? data, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, data: data, stackTrace: stackTrace);
  }

  /// CRITICAL 级别日志 - 严重错误
  void critical(String message, {Map<String, dynamic>? data, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, data: data, stackTrace: stackTrace);
  }

  // ==================== 内部实现 ====================

  /// 记录日志
  void _log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  }) {
    // 检查日志级别
    if (level.value < LogConfig.minLevel.value) {
      return;
    }

    final timestamp = DateTime.now();
    final formattedMessage = _formatLog(timestamp, level, message, data, stackTrace);

    // 输出到控制台
    _outputToConsole(formattedMessage, level);

    // 输出到 DevTools Timeline（仅开发环境）
    if (kDebugMode && data != null) {
      developer.postEvent('qintu.log', {
        'tag': tag,
        'level': level.name,
        'message': message,
        'data': data,
      });
    }

    // 输出到文件
    LogConfig.writeToFile('[$tag] $message${data != null ? ' $data' : ''}');
  }

  /// 格式化日志消息
  String _formatLog(
    DateTime timestamp,
    LogLevel level,
    String message,
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  ) {
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';

    final levelStr = _formatLevel(level);
    final tagStr = tag.isNotEmpty ? '[$tag]' : '';
    final dataStr = data != null ? '\n  数据: $data' : '';
    final stackTraceStr = stackTrace != null ? '\n$stackTrace' : '';

    return '$timeStr $levelStr $tagStr $message$dataStr$stackTraceStr';
  }

  /// 格式化日志级别
  String _formatLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛 DEBUG  ';
      case LogLevel.info:
        return 'ℹ️ INFO   ';
      case LogLevel.warning:
        return '⚠️ WARNING';
      case LogLevel.error:
        return '❌ ERROR ';
      case LogLevel.critical:
        return '🔥 CRITICAL';
    }
  }

  /// 输出到控制台
  void _outputToConsole(String message, LogLevel level) {
    if (kDebugMode) {
      // 开发环境：彩色输出
      String colorCode;
      switch (level) {
        case LogLevel.debug:
          colorCode = '\x1B[37m';
          break;
        case LogLevel.info:
          colorCode = '\x1B[36m';
          break;
        case LogLevel.warning:
          colorCode = '\x1B[33m';
          break;
        case LogLevel.error:
          colorCode = '\x1B[31m';
          break;
        case LogLevel.critical:
          colorCode = '\x1B[35m';
          break;
      }
      // ignore: avoid_print
      print('$colorCode$message\x1B[0m');
    } else {
      // 生产环境：使用 developer.log
      developer.log(
        message,
        level: _toDeveloperLevel(level),
        name: 'qintu',
      );
    }
  }

  /// 转换为 developer.log 级别
  int _toDeveloperLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 0;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1100;
    }
  }
}

// ==================== 预定义的日志实例 ====================

/// 便捷日志实例集合
///
/// 使用示例：
/// ```dart
/// Logs.auth.info('认证成功');
/// Logs.api.warning('API 超时');
/// Logs.binding.error('绑定失败');
/// ```
class Logs {
  /// API 请求日志
  static const Logger api = Logger('API');

  /// 认证相关日志
  static const Logger auth = Logger('AUTH');

  /// 绑定关系日志
  static const Logger binding = Logger('BINDING');

  /// 导航任务日志
  static const Logger task = Logger('TASK');

  /// 位置服务日志
  static const Logger location = Logger('LOCATION');

  /// UI 交互日志
  static const Logger ui = Logger('UI');

  /// 数据库操作日志
  static const Logger database = Logger('DATABASE');

  /// 网络请求日志
  static const Logger network = Logger('NETWORK');

  /// 存储相关日志
  static const Logger storage = Logger('STORAGE');

  /// 应用级别日志
  static const Logger app = Logger('APP');
}
