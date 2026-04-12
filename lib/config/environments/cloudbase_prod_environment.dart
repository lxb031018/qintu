import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'environment_config.dart';

/// CloudBase 生产环境配置
///
/// 适用场景：
/// - 接近上线前的最终测试
/// - 确保 CloudBase 配额足够
///
/// 特点：
/// - 与测试环境类似，但使用正式路径
/// - 需要严格控制配额使用
class CloudBaseProdEnvironment implements EnvironmentConfig {
  /// 从 .env 文件读取环境 ID
  String get envId => dotenv.env['CLOUDBASE_ENV_ID'] ?? 'qintu-cloudbase-5f5bpuj13bc6467';

  /// 从 .env 文件读取网关路径
  String get gatewayPath => dotenv.env['CLOUDBASE_PROD_GATEWAY_PATH'] ?? 'qintu-api';

  @override
  String get name => 'CloudBase Production';

  @override
  String get baseUrl => 'https://$envId.service.tcloudbase.com/$gatewayPath';

  @override
  bool get enableDebugLogs => false;

  @override
  bool get enableNetworkLogs => false;

  @override
  bool get useMockData => false;

  @override
  String? get cloudBaseEnvId => envId;

  @override
  int get connectTimeout => 30;

  @override
  int get receiveTimeout => 30;

  @override
  String toString() => 'CloudBaseProdEnvironment(envId: $envId)';
}
