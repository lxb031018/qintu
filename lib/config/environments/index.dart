// 环境配置统一导出
//
// 使用方式：
// ```dart
// import 'package:qintu/config/environments/index.dart';
//
// // 切换环境
// EnvironmentManager.switchEnvironment(EnvironmentType.local);
//
// // 获取当前配置
// final baseUrl = EnvironmentManager.baseUrl;
// ```

export 'environment_config.dart';
export 'local_environment.dart';
export 'cloudbase_test_environment.dart';
export 'cloudbase_prod_environment.dart';
export 'production_environment.dart';
export 'environment_manager.dart';
