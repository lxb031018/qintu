import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'environment_config.dart';

/// 本地开发环境配置
///
/// 适用场景：
/// - 本地开发和调试
/// - 双设备功能测试
/// - 快速原型验证
///
/// 特点：
/// - 零成本，不消耗 CloudBase 额度
/// - 响应速度快（局域网）
/// - 实时查看服务器日志
/// - 数据存储在内存中，重启丢失
class LocalEnvironment implements EnvironmentConfig {
  /// 从 .env 文件读取局域网 IP
  String get localIp => dotenv.env['LOCAL_SERVER_IP'] ?? '192.168.99.106';

  /// 从 .env 文件读取端口
  int get port => int.tryParse(dotenv.env['LOCAL_SERVER_PORT'] ?? '9000') ?? 9000;

  @override
  String get name => 'Local Development';

  @override
  String get baseUrl => 'http://$localIp:$port';

  @override
  bool get enableDebugLogs => true;

  @override
  bool get enableNetworkLogs => true;

  @override
  bool get useMockData => false;

  @override
  String? get cloudBaseEnvId => null;

  @override
  int get connectTimeout => 15;

  @override
  int get receiveTimeout => 15;

  @override
  String toString() => 'LocalEnvironment(ip: $localIp, port: $port)';
}
