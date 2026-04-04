import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

/// 文件日志输出器
///
/// 功能：
/// - 异步写入日志文件
/// - 自动日志轮转（按大小）
/// - 错误处理和优雅降级
class FileLogger {
  /// 日志文件路径
  File? _logFile;

  /// 日志写入流
  IOSink? _logSink;

  /// 最大日志文件大小（默认 10MB）
  final int maxFileSize;

  /// 保留的旧日志文件数量（默认 5 个）
  final int maxRotatedFiles;

  /// 当前文件大小
  int _currentFileSize = 0;

  /// 是否已初始化
  bool _initialized = false;

  /// 是否启用文件日志
  bool get isEnabled => _initialized && _logSink != null;

  /// 缓冲区，批量写入
  final List<String> _buffer = [];
  Timer? _flushTimer;
  static const _flushInterval = Duration(seconds: 2);
  static const _maxBufferSize = 50;

  FileLogger({
    this.maxFileSize = 10 * 1024 * 1024, // 10MB
    this.maxRotatedFiles = 5,
  });

  /// 初始化文件日志
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // 获取应用文档目录
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      // 创建日志目录（如果不存在）
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // 日志文件路径
      final logPath = '${logDir.path}/qintu.log';
      _logFile = File(logPath);

      // 检查文件大小，决定是否需要轮转
      if (await _logFile!.exists()) {
        _currentFileSize = await _logFile!.length();
        if (_currentFileSize >= maxFileSize) {
          await _rotateLogFile();
        }
      }

      // 打开文件用于追加写入
      _logSink = _logFile!.openWrite(mode: FileMode.append);
      _initialized = true;

      _writeToBuffer('[INFO] 文件日志已初始化: $logPath');
      return true;
    } catch (e, stackTrace) {
      // 初始化失败，降级到控制台
      _initialized = false;
      _logSink = null;
      // ignore: avoid_print
      print('[ERROR] 文件日志初始化失败: $e\n$stackTrace');
      return false;
    }
  }

  /// 写入日志
  void write(String message) {
    if (!_initialized || _logSink == null) {
      return;
    }

    _writeToBuffer(message);
  }

  /// 写入缓冲区
  void _writeToBuffer(String message) {
    final timestamp = DateTime.now().toString().substring(0, 23);
    _buffer.add('$timestamp $message');

    // 如果缓冲区满，立即刷新
    if (_buffer.length >= _maxBufferSize) {
      _flush();
    } else {
      // 否则延迟刷新
      _flushTimer?.cancel();
      _flushTimer = Timer(_flushInterval, _flush);
    }
  }

  /// 刷新缓冲区到文件
  void _flush() {
    if (_buffer.isEmpty || _logSink == null) {
      return;
    }

    try {
      final content = _buffer.join('\n') + '\n';
      _logSink!.write(content);
      _currentFileSize += content.length;
      _buffer.clear();

      // 检查文件大小，决定是否需要轮转
      if (_currentFileSize >= maxFileSize) {
        _rotateLogFile();
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ERROR] 写入日志文件失败: $e');
      _buffer.clear();
    }
  }

  /// 轮转日志文件
  Future<void> _rotateLogFile() async {
    try {
      // 关闭当前文件
      await _logSink?.close();
      _logSink = null;

      // 删除最旧的日志文件
      final oldestFile = File('${_logFile!.path}.$maxRotatedFiles');
      if (await oldestFile.exists()) {
        await oldestFile.delete();
      }

      // 重命名旧文件（qintu.log.4 -> qintu.log.5, qintu.log.3 -> qintu.log.4, ...）
      for (int i = maxRotatedFiles - 1; i >= 1; i--) {
        final oldFile = File('${_logFile!.path}.$i');
        final newFile = File('${_logFile!.path}.${i + 1}');
        if (await oldFile.exists()) {
          await oldFile.rename(newFile.path);
        }
      }

      // 重命名当前文件
      await _logFile!.rename('${_logFile!.path}.1');

      // 创建新文件
      _logFile = File(_logFile!.path);
      _logSink = _logFile!.openWrite(mode: FileMode.append);
      _currentFileSize = 0;

      _buffer.add('[INFO] 日志文件已轮转');
    } catch (e) {
      // ignore: avoid_print
      print('[ERROR] 日志文件轮转失败: $e');
      // 重新打开原文件
      _logSink = _logFile!.openWrite(mode: FileMode.append);
    }
  }

  /// 关闭文件日志
  Future<void> dispose() async {
    // 刷新缓冲区
    _flushTimer?.cancel();
    _flush();

    // 关闭文件
    try {
      await _logSink?.close();
      _logSink = null;
      _initialized = false;
    } catch (e) {
      // ignore: avoid_print
      print('[ERROR] 关闭日志文件失败: $e');
    }
  }
}
