import 'package:flutter/foundation.dart';
import 'file_logger.dart';

/// 日志配置
///
/// 管理日志级别、文件日志等配置
class LogConfig {
  /// 日志级别
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// 文件日志器
  static final FileLogger _fileLogger = FileLogger();

  /// 是否已初始化文件日志
  static bool _fileLogInitialized = false;

  /// 获取当前日志级别
  static LogLevel get minLevel => _minLevel;

  /// 获取文件日志器
  static FileLogger get fileLogger => _fileLogger;

  /// 设置日志级别
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// 启用文件日志
  static Future<bool> enableFileLog() async {
    if (_fileLogInitialized) {
      return _fileLogger.isEnabled;
    }

    _fileLogInitialized = true;
    return await _fileLogger.initialize();
  }

  /// 禁用文件日志
  static Future<void> disableFileLog() async {
    await _fileLogger.dispose();
    _fileLogInitialized = false;
  }

  /// 写入文件日志
  static void writeToFile(String message) {
    if (_fileLogInitialized && _fileLogger.isEnabled) {
      _fileLogger.write(message);
    }
  }

  /// 刷新文件日志缓冲区
  static void flushFileLog() {
    if (_fileLogInitialized && _fileLogger.isEnabled) {
      // 触发立即刷新（通过写入空消息）
      _fileLogger.write('');
    }
  }
}

/// 日志级别
enum LogLevel {
  debug(0),
  info(1),
  warning(2),
  error(3),
  critical(4);

  final int value;
  const LogLevel(this.value);
}
