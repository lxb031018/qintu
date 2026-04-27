import '../logger.dart';

/// ============================================
/// 高德地图错误码处理工具
///
/// 将高德 API 错误码转换为可读的错误消息
/// 参考: https://lbs.amap.com/api/webservice/guide/tools/info-code
/// ============================================
class AmapErrorHandler {
  /// 根据错误码获取错误消息
  static String getErrorMessage(int errorCode) {
    switch (errorCode) {
      // 服务错误码 (1000-1099)
      case 1000:
        return '服务正常';
      case 1001:
        return '签名错误';
      case 1002:
        return '无效的用户Key';
      case 1003:
        return '服务正在维护中';
      case 1004:
        return '服务每日调用量已超限';
      case 1005:
        return '单位时间内访问过于频繁';
      case 1006:
        return '无效的IP';
      case 1007:
        return '无效的域名';
      case 1008:
        return '无效的权限key';
      case 1009:
        return 'key与平台不匹配';
      case 1010:
        return 'IP请求超出日配额';
      case 1011:
        return '服务不支持HTTPS';
      case 1012:
        return '权限不足，请检查控制台是否开通该服务';
      case 1013:
        return 'key已被注销';
      case 1014:
        return '签名算法不匹配';
      case 1015:
        return '有效时间过期';
      case 1016:
        return '内容校验失败';
      case 1017:
        return '签名超时';
      case 1018:
        return '访问频率超限';
      case 1019:
        return '距离排序失败';
      case 1020:
        return '顾问淘金KEY被限制';
      case 1021:
        return '行政区域编码错误';

      // 引擎返回错误码 (1100-1199)
      case 1100:
        return '引擎返回状态异常';
      case 1101:
        return '引擎返回数据异常';
      case 1102:
        return '连接引擎超时';
      case 1103:
        return '引擎返回内容为空';

      // 服务通用错误码 (1200-1299)
      case 1200:
        return '请求参数无效';
      case 1201:
        return '缺少必填参数';
      case 1202:
        return '请求协议非法';
      case 1203:
        return '未知错误';
      case 1204:
        return '格式错误';
      case 1205:
        return '请求服务不存在';
      case 1206:
        return '请求已过期';
      case 1207:
        return '请求正在处理中';
      case 1208:
        return '个人认证用户当日配额已用完';
      case 1209:
        return '服务可用但配额已用完';

      // SDK 返回错误码 (1800-1999)
      case 1800:
        return '缺少安全密钥';
      case 1801:
        return '安全密钥校验失败';
      case 1802:
        return '网络连接超时';
      case 1803:
        return '无效的URL';
      case 1804:
        return '无法解析域名';
      case 1806:
        return '网络连接异常';
      case 1807:
        return '地图渲染初始化失败';
      case 1808:
        return 'GPS定位失败';
      case 1809:
        return '地图服务初始化失败';
      case 1810:
        return '定位参数错误';
      case 1811:
        return '定位权限被拒绝';
      case 1812:
        return '定位服务不可用';
      case 1813:
        return '地图初始化失败';
      case 1900:
        return '未知错误';
      case 1901:
        return '无效的参数';
      case 1902:
        return 'IO操作异常';
      case 1903:
        return '空指针异常';

      // 路径规划错误码 (3000-3099)
      case 3000:
        return '路线规划服务暂停';
      case 3001:
        return '起点或终点不在路网范围内';
      case 3002:
        return '路线规划失败';
      case 3003:
        return '导航方向超出范围';

      // 短传分享错误码 (4000-4099)
      case 4000:
        return '短串分享服务暂停';
      case 4001:
        return '短串生成失败';

      // 输入提示错误码 (2000-2099)
      case 2000:
        return 'tableID无效';
      case 2001:
        return 'id不存在';
      case 2002:
        return '服务维护中';
      case 2003:
        return 'tableID不存在';

      default:
        return '未知错误 (错误码: $errorCode)';
    }
  }

  /// 判断是否为严重错误（需要用户注意的）
  static bool isSevereError(int errorCode) {
    return errorCode == 1002 ||  // 无效的Key
           errorCode == 1012 ||  // 权限不足
           errorCode == 1013 ||  // Key已被注销
           errorCode == 1100 ||  // 引擎返回异常
           errorCode == 1200;    // 参数错误
  }

  /// 判断是否为临时性错误（可以重试的）
  static bool isRetryableError(int errorCode) {
    return errorCode == 1005 ||  // 访问过于频繁
           errorCode == 1006 ||  // 无效IP
           errorCode == 1018 ||  // 访问频率超限
           errorCode == 1102 ||  // 连接超时
           errorCode == 1103;    // 返回超时
  }

  /// 获取友好的错误提示
  static String getFriendlyMessage(int errorCode) {
    switch (errorCode) {
      case 1002:
        return '地图服务未正确配置，请联系管理员';
      case 1012:
        return '地图服务权限不足，请检查服务是否开通';
      case 1013:
        return '地图服务已被禁用，请联系管理员';
      case 1004:
        return '今日地图搜索次数已用完，请明天再试';
      case 1005:
      case 1018:
        return '操作太频繁，请稍后再试';
      case 1102:
      case 1103:
        return '网络连接不稳定，请检查网络后重试';
      case 3001:
        return '无法找到合适的路线，请尝试调整起点或终点';
      case 3002:
        return '路线规划失败，请稍后重试';
      case 1806:
        return '网络连接异常，请检查网络设置';
      case 1808:
        return '定位失败，请检查定位权限';
      default:
        return getErrorMessage(errorCode);
    }
  }

  /// 记录错误日志
  static void logError(int errorCode, String context) {
    final message = getErrorMessage(errorCode);
    Logs.map.warning('[$context] 高德API错误 $errorCode: $message');
  }
}

/// 建议城市数据模型
class SuggestionCity {
  final String name;       // 城市名称
  final String cityCode;    // 城市区号
  final String adCode;      // 城市编码

  const SuggestionCity({
    required this.name,
    required this.cityCode,
    required this.adCode,
  });

  factory SuggestionCity.fromJson(Map<String, dynamic> json) {
    return SuggestionCity(
      name: json['name']?.toString() ?? '',
      cityCode: json['citycode']?.toString() ?? '',
      adCode: json['adcode']?.toString() ?? '',
    );
  }

  @override
  String toString() => '$name ($cityCode, $adCode)';
}
