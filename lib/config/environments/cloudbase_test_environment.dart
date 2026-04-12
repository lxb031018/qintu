import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'environment_config.dart';

/// CloudBase 测试环境配置
///
/// 适用场景：
/// - 内部测试和演示
/// - 小规模用户体验测试
/// - 需要持久化数据但不想搭建正式服务器
///
/// 特点：
/// - 数据持久化存储在云端
/// - 任何网络都可访问
/// - 消耗 CloudBase 免费额度
/// - 可能有冷启动延迟
class CloudBaseTestEnvironment implements EnvironmentConfig {
  /// 从 .env 文件读取环境 ID
  String get envId => dotenv.env['CLOUDBASE_ENV_ID'] ?? 'qintu-cloudbase-5f5bpuj13bc6467';

  /// 从 .env 文件读取网关路径
  String get gatewayPath => dotenv.env['CLOUDBASE_TEST_GATEWAY_PATH'] ?? 'qintu-api-test';

  @override
  String get name => 'CloudBase Test';

  @override
  String get baseUrl => 'https://$envId.service.tcloudbase.com/$gatewayPath';

  @override
  bool get enableDebugLogs => true;

  @override
  bool get enableNetworkLogs => true;

  @override
  bool get useMockData => false;

  @override
  String? get cloudBaseEnvId => envId;

  @override
  int get connectTimeout => 30;

  @override
  int get receiveTimeout => 30;

  @override
  String toString() => 'CloudBaseTestEnvironment(envId: $envId)';
}
