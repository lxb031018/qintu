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

  /// Publishable Key（从环境变量读取）
  static String get publishableKey => dotenv.env['CLOUDBASE_PUBLISHABLE_KEY'] ?? '';
}
