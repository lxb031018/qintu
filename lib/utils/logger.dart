import 'package:flutter/foundation.dart';

// 日志工具类 - 提供统一的日志输出接口

class Logger {
  // ==================== 敏感字段 ====================

  /// 需要脱敏的字段名列表
  static const List<String> _sensitiveFields = [
    'access_token',
    'refresh_token',
    'verification_token',
    'verification_id',
    'verification_code',
    'phone_number',
    'uid',
    'password',
    'Authorization',
  ];

  /// 脱敏处理：将敏感字段的值替换为 ***
  static String _sanitize(String content) {
    String result = content;
    for (final field in _sensitiveFields) {
      // 匹配 "field":"value" 或 "field": "value" 格式
      final pattern = RegExp('"$field"\\s*:\\s*"[^"]*"');
      result = result.replaceAllMapped(pattern, (match) {
        return '"$field":"***"';
      });
    }
    return result;
  }

  // ==================== 模块开关 ====================
  // 根据需要开启/关闭不同模块的日志

  /// 认证模块日志（登录、注册、验证码等）
  static const bool enableAuthLogs = false;

  /// API 请求日志（网络请求、响应等）
  static const bool enableApiLogs = true;

  /// UI 模块日志（页面跳转、用户交互等）
  static const bool enableUiLogs = true;

  /// 数据库模块日志
  static const bool enableDatabaseLogs = true;

  /// 其他模块日志
  static const bool enableOtherLogs = true;

  // ==================== 基础配置 ====================

  /// 是否启用日志（默认在调试模式下启用）
  static bool get isEnabled => kDebugMode;

  // ==================== 认证模块日志 ====================

  /// 认证模块 - 普通日志
  static void auth(String message) {
    if (isEnabled && enableAuthLogs) {
      debugPrint('🔐 [AUTH] $message');
    }
  }

  /// 认证模块 - 成功日志
  static void authSuccess(String message) {
    if (isEnabled && enableAuthLogs) {
      debugPrint('✅ [AUTH] $message');
    }
  }

  /// 认证模块 - 错误日志
  static void authError(String message) {
    if (isEnabled && enableAuthLogs) {
      debugPrint('❌ [AUTH] $message');
    }
  }

  /// 认证模块 - 分隔线
  static void authSeparator(String title) {
    if (isEnabled && enableAuthLogs) {
      debugPrint('========== $title ==========');
    }
  }

  // ==================== API 模块日志 ====================

  /// API 模块 - 普通日志
  static void api(String message) {
    if (isEnabled && enableApiLogs) {
      debugPrint('🌐 [API] $message');
    }
  }

  /// API 模块 - 请求日志
  static void apiRequest(String url, [Map<String, dynamic>? body]) {
    if (isEnabled && enableApiLogs) {
      debugPrint('📤 [API] Request: $url');
      if (body != null) {
        final sanitizedBody = body.map((key, value) =>
            MapEntry(key, _sensitiveFields.contains(key) ? '***' : value));
        debugPrint('📤 [API] Body: $sanitizedBody');
      }
    }
  }

  /// API 模块 - 响应日志
  static void apiResponse(int statusCode, String body) {
    if (isEnabled && enableApiLogs) {
      debugPrint('📥 [API] Status: $statusCode');
      debugPrint('📥 [API] Response: ${_sanitize(body)}');
    }
  }

  // ==================== UI 模块日志 ====================

  /// UI 模块 - 普通日志
  static void ui(String message) {
    if (isEnabled && enableUiLogs) {
      debugPrint('📱 [UI] $message');
    }
  }

  /// UI 模块 - 导航日志
  static void navigation(String from, String to) {
    if (isEnabled && enableUiLogs) {
      debugPrint('🧭 [NAV] $from → $to');
    }
  }

  // ==================== 数据库模块日志 ====================

  /// 数据库模块 - 普通日志
  static void database(String message) {
    if (isEnabled && enableDatabaseLogs) {
      debugPrint('💾 [DB] $message');
    }
  }

  /// 数据库模块 - 查询日志
  static void dbQuery(String query, [Map<String, dynamic>? params]) {
    if (isEnabled && enableDatabaseLogs) {
      debugPrint('🔍 [DB] Query: $query');
      if (params != null) {
        debugPrint('🔍 [DB] Params: $params');
      }
    }
  }

  // ==================== 通用日志方法 ====================

  /// 普通日志
  static void log(String message) {
    if (isEnabled && enableOtherLogs) {
      debugPrint(message);
    }
  }

  /// 信息日志
  static void info(String message) {
    if (isEnabled && enableOtherLogs) {
      debugPrint('ℹ️ $message');
    }
  }

  /// 成功日志
  static void success(String message) {
    if (isEnabled && enableOtherLogs) {
      debugPrint('✅ $message');
    }
  }

  /// 警告日志
  static void warning(String message) {
    if (isEnabled && enableOtherLogs) {
      debugPrint('⚠️ $message');
    }
  }

  /// 错误日志
  static void error(String message) {
    if (isEnabled && enableOtherLogs) {
      debugPrint('❌ $message');
    }
  }

  /// 调试日志
  static void debug(String message) {
    if (isEnabled && enableOtherLogs) {
      debugPrint('🔍 $message');
    }
  }

  /// 分隔线
  static void separator(String title) {
    if (isEnabled && enableOtherLogs) {
      debugPrint('========== $title ==========');
    }
  }
}