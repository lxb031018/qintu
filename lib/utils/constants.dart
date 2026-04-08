/// 应用常量配置
class Constants {
  // CloudBase 配置
  static const String cloudbaseEnvId = 'qintu-cloudebase-5f5bpuj13bc6467';
  
  // 云函数 URL（部署后替换为实际地址）
  // 格式：https://<环境ID>.service.tcloudbase.com/qintu-api
  static const String cloudFunctionBaseUrl = 
      'https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api';
  
  // 本地开发时使用 localhost
  static const String localhostBaseUrl = 'http://localhost:9000';
  
  // 是否使用本地开发服务器
  static const bool useLocalServer = false;
  
  // 获取实际使用的 Base URL
  static String get baseUrl => useLocalServer ? localhostBaseUrl : cloudFunctionBaseUrl;
  
  // 绑定限制
  static const int maxReceiversPerSender = 5;  // 发送者最多绑定 5 个接收者
  static const int maxSendersPerReceiver = 3;  // 接收者最多被 3 个发送者绑定
  
  // 位置更新间隔（毫秒）
  static const int locationUpdateInterval = 5000;  // 5 秒

  // 任务轮询间隔（毫秒）
  static const int taskPollingInterval = 10000;  // 10 秒
  
  // 本地存储 Key
  static const String storageKeyOpenid = 'openid';
  static const String storageKeyPhone = 'phone';
  static const String storageKeyUserType = 'user_type';
  static const String storageKeyIsFirstLogin = 'is_first_login';
}
