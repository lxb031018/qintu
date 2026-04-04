import 'package:flutter_dotenv/flutter_dotenv.dart';

/// CloudBase 环境配置
/// 负责管理 CloudBase 相关的环境信息

class CloudBaseConfig {
  /// CloudBase 环境 ID
  static String get envId => dotenv.env['CLOUDBASE_ENV_ID'] ?? 'qintu-cloudebase-5f5bpuj13bc6467';

  /// CloudBase 网关地址
  static String get gatewayUrl => 'https://$envId.api.tcloudbasegateway.com';

  /// CloudBase 服务地址
  static String get serviceUrl => 'https://$envId.service.tcloudbase.com';

  /// 云函数基础地址（通过 HTTP 触发器直接访问）
  /// 注意：不需要包含云函数名称前缀，触发器会直接路由到函数
  static String get functionBaseUrl => serviceUrl;

  /// 认证 API 基础地址
  /// 使用 CloudBase 官方 Auth HTTP API
  /// 官方文档：https://docs.cloudbase.net/authentication/http-api
  static String get authBaseUrl => 'https://$envId.api.tcloudbasegateway.com';

  /// Publishable Key（从环境变量读取）
  static String get publishableKey => dotenv.env['CLOUDBASE_PUBLISHABLE_KEY'] ?? '';
}
