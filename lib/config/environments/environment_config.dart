/// 环境配置接口
/// 
/// 所有环境配置必须实现此接口
abstract class EnvironmentConfig {
  /// 环境名称
  String get name;
  
  /// API 基础 URL
  String get baseUrl;
  
  /// 是否启用调试日志
  bool get enableDebugLogs;
  
  /// 是否启用详细网络日志
  bool get enableNetworkLogs;
  
  /// 是否使用 Mock 数据
  bool get useMockData;
  
  /// CloudBase 环境 ID（仅 CloudBase 环境需要）
  String? get cloudBaseEnvId;
  
  /// 连接超时时间（秒）
  int get connectTimeout;
  
  /// 接收超时时间（秒）
  int get receiveTimeout;
}
