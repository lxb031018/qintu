import '../api/poi_api.dart';

/// ============================================
/// 地点输入卡片交互服务
///
/// 纯业务逻辑，无状态，无 Flutter/Riverpod 依赖
/// ============================================

class LocationInputCardInteraction {
  /// 交换起点和终点
  ///
  /// 输入两个 POI，返回交换后的结果
  /// [origin] 当前起点
  /// [destination] 当前终点
  /// 返回 (newOrigin, newDestination)，即 (destination, origin)
  (PoiSuggestion?, PoiSuggestion?) swapPois({
    PoiSuggestion? origin,
    PoiSuggestion? destination,
  }) {
    // 如果有任意一个为空，仍然交换（空<->非空 = 非空变为另一个输入框）
    return (destination, origin);
  }

  /// 判断是否可以交换
  ///
  /// 只有当起点和终点都非空时才需要交换
  bool canSwap({
    PoiSuggestion? origin,
    PoiSuggestion? destination,
  }) {
    // 任一存在即可交换（空和非空交换有意义）
    return origin != null || destination != null;
  }
}