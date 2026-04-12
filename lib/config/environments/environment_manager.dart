// 环境管理器
//
// 统一管理应用的所有环境配置
//
// 使用方式：
// ```dart
// // 1. 应用启动时初始化（在 main.dart 中调用）
// await EnvironmentManager.initialize();
//
// // 2. 获取当前环境配置
// final config = EnvironmentManager.current;
// print(config.baseUrl);
//
// // 3. 切换环境
// EnvironmentManager.switchEnvironment(EnvironmentType.local);
//
// // 4. 检查当前环境
// if (EnvironmentManager.isLocal) {
//   // 本地开发逻辑
// }
// ```
import 'package:flutter/foundation.dart';
import 'environment_config.dart';
import 'local_environment.dart';
import 'cloudbase_test_environment.dart';
import 'cloudbase_prod_environment.dart';
import 'production_environment.dart';

/// 环境类型枚举
enum EnvironmentType {
  /// 本地开发环境
  local,

  /// CloudBase 测试环境
  cloudbaseTest,

  /// CloudBase 生产环境
  cloudbaseProd,

  /// 正式生产环境
  production,
}

/// 环境变化监听器类型
typedef EnvironmentChangeListener = void Function(
  EnvironmentType oldEnv,
  EnvironmentType newEnv,
);

class EnvironmentManager {
  EnvironmentManager._();

  /// 当前运行环境
  static EnvironmentType _currentEnv = EnvironmentType.local;

  /// 是否已初始化
  static bool _initialized = false;

  /// 环境变化监听器列表
  static final List<EnvironmentChangeListener> _listeners = [];

  /// 环境配置缓存（延迟初始化）
  static final Map<EnvironmentType, EnvironmentConfig> _configs = {};

  /// 获取环境配置（懒加载）
  static EnvironmentConfig _getConfig(EnvironmentType type) {
    if (!_configs.containsKey(type)) {
      switch (type) {
        case EnvironmentType.local:
          _configs[type] = LocalEnvironment();
          break;
        case EnvironmentType.cloudbaseTest:
          _configs[type] = CloudBaseTestEnvironment();
          break;
        case EnvironmentType.cloudbaseProd:
          _configs[type] = CloudBaseProdEnvironment();
          break;
        case EnvironmentType.production:
          _configs[type] = ProductionEnvironment();
          break;
      }
    }
    return _configs[type]!;
  }

  /// 初始化环境管理器
  ///
  /// 必须在 [dotenv] 加载完成后调用
  /// 通常在 main() 中调用：await EnvironmentManager.initialize();
  static void initialize() {
    if (_initialized) return;
    _initialized = true;
    debugPrint('✅ EnvironmentManager 已初始化: ${current.name}');
  }

  /// 获取当前环境配置
  static EnvironmentConfig get current {
    return _getConfig(_currentEnv);
  }

  /// 获取当前环境类型
  static EnvironmentType get currentType => _currentEnv;

  /// 获取当前环境名称
  static String get currentName => current.name;

  /// 获取当前 API 基础 URL
  static String get baseUrl => current.baseUrl;

  /// 切换环境
  ///
  /// 参数：
  /// - [env]: 目标环境类型
  static void switchEnvironment(EnvironmentType env) {
    final oldEnv = _currentEnv;
    if (oldEnv == env) return;

    _currentEnv = env;
    debugPrint('🔄 环境已切换: ${current.name}');
    debugPrint('📍 API 地址: ${current.baseUrl}');
    debugPrint('🐛 调试日志: ${current.enableDebugLogs ? "开启" : "关闭"}');

    // 通知所有监听器
    _notifyListeners(oldEnv, env);
  }

  /// 添加环境变化监听器
  static void addListener(EnvironmentChangeListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  /// 移除环境变化监听器
  static void removeListener(EnvironmentChangeListener listener) {
    _listeners.remove(listener);
  }

  /// 通知所有监听器
  static void _notifyListeners(EnvironmentType oldEnv, EnvironmentType newEnv) {
    for (final listener in List.of(_listeners)) {
      try {
        listener(oldEnv, newEnv);
      } catch (e) {
        debugPrint('❌ 环境变化监听器异常: $e');
      }
    }
  }

  /// 是否本地环境
  static bool get isLocal => _currentEnv == EnvironmentType.local;

  /// 是否 CloudBase 测试环境
  static bool get isCloudBaseTest => _currentEnv == EnvironmentType.cloudbaseTest;

  /// 是否 CloudBase 生产环境
  static bool get isCloudBaseProd => _currentEnv == EnvironmentType.cloudbaseProd;

  /// 是否生产环境
  static bool get isProduction => _currentEnv == EnvironmentType.production;

  /// 是否开发环境（本地或 CloudBase 测试）
  static bool get isDevelopment =>
      _currentEnv == EnvironmentType.local ||
      _currentEnv == EnvironmentType.cloudbaseTest;

  /// 获取所有可用环境列表
  static List<Map<String, dynamic>> get availableEnvironments {
    return EnvironmentType.values.map((type) {
      final config = _getConfig(type);
      return {
        'type': type,
        'name': config.name,
        'baseUrl': config.baseUrl,
        'config': config,
        'isCurrent': type == _currentEnv,
      };
    }).toList();
  }

  /// 打印当前环境信息（调试用）
  static void printEnvironmentInfo() {
    debugPrint('========================================');
    debugPrint('  当前环境: ${current.name}');
    debugPrint('  API 地址: ${current.baseUrl}');
    debugPrint('  调试日志: ${current.enableDebugLogs ? "✅" : "❌"}');
    debugPrint('  网络日志: ${current.enableNetworkLogs ? "✅" : "❌"}');
    debugPrint('  连接超时: ${current.connectTimeout}s');
    debugPrint('  接收超时: ${current.receiveTimeout}s');
    if (current.cloudBaseEnvId != null) {
      debugPrint('  CloudBase: ${current.cloudBaseEnvId}');
    }
    debugPrint('========================================');
  }
}
