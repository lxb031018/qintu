import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'environment_config.dart';

/// 正式生产服务器环境配置
///
/// 适用场景：
/// - 正式上线后的生产环境
/// - 需要完全控制和可扩展性
///
/// 特点：
/// - 完全自主控制，无第三方限制
/// - 可自定义域名和 SSL 证书
/// - 可根据负载动态扩展
/// - 需要自己维护服务器和域名
///
/// 上线前准备：
/// 1. 购买域名（如 api.qintu.com）
/// 2. 配置 SSL 证书（HTTPS）
/// 3. 部署后端服务（Docker/K8s）
/// 4. 配置 CDN（可选）
/// 5. 设置监控和告警
class ProductionEnvironment implements EnvironmentConfig {
  /// 从 .env 文件读取生产服务器地址
  String get prodUrl => dotenv.env['PRODUCTION_BASE_URL'] ?? 'https://api.qintu.com';

  @override
  String get name => 'Production';

  @override
  String get baseUrl => prodUrl;

  @override
  bool get enableDebugLogs => false;

  @override
  bool get enableNetworkLogs => false;

  @override
  bool get useMockData => false;

  @override
  String? get cloudBaseEnvId => null;

  @override
  int get connectTimeout => 30;

  @override
  int get receiveTimeout => 30;

  @override
  String toString() => 'ProductionEnvironment(url: $prodUrl)';
}
