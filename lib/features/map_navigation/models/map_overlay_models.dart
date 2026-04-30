import 'package:qintu/features/map_navigation/models/poi_models.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';

/// ============================================
/// 地图覆盖物数据模型
/// ============================================

// ============ POI 标注层相关 ============

/// POI 标注点数据模型
///
/// 用于在地图上显示 POI 标记
class PoiMarkerData {
  final String id;
  final String name;
  final String? address;
  final LatLng position;
  final String? snippet;  // 详情描述

  const PoiMarkerData({
    required this.id,
    required this.name,
    this.address,
    required this.position,
    this.snippet,
  });

  /// 从 PoiSuggestion 创建
  factory PoiMarkerData.fromSuggestion(PoiSuggestion suggestion) {
    return PoiMarkerData(
      id: suggestion.id,
      name: suggestion.name,
      address: suggestion.address,
      position: suggestion.latLng ?? const LatLng(0, 0),
      snippet: suggestion.address,
    );
  }
}

/// 路线颜色配置
class RouteColors {
  /// 驾车路线颜色
  static const int driving = 0xFF1890FF; // 蓝色

  /// 步行路线颜色
  static const int walking = 0xFF52C41A; // 绿色

  /// 骑行路线颜色
  static const int riding = 0xFFFAAD14; // 橙色

  /// 公交地铁路线颜色
  static const int transit = 0xFF722ED1; // 紫色

  /// 公交步行段颜色
  static const int transitWalk = 0xFF8C8C8C; // 灰色

  /// 公交车段颜色
  static const int transitBus = 0xFF1890FF; // 蓝色

  /// 地铁段颜色
  static const int transitSubway = 0xFFFF4D4F; // 红色

  /// 获取路线类型对应的颜色
  static int getColor(RouteType type) {
    switch (type) {
      case RouteType.driving:
        return driving;
      case RouteType.walking:
        return walking;
      case RouteType.riding:
        return riding;
      case RouteType.transit:
        return transit;
    }
  }

  /// 选中状态高亮颜色
  static const int selected = 0xFFFF4D4F; // 红色高亮

  /// 未选中状态淡化颜色（基于原色的淡化）
  static int getDimmedColor(RouteType type) {
    switch (type) {
      case RouteType.driving:
        return 0x801890FF; // 蓝色淡化
      case RouteType.walking:
        return 0x8052C41A; // 绿色淡化
      case RouteType.riding:
        return 0x80FAAD14; // 橙色淡化
      case RouteType.transit:
        return 0x80722ED1; // 紫色淡化
    }
  }
}

/// 路线结果数据模型（供 UI 使用）
class RouteResultItem {
  final String distance;
  final String formattedDistance;
  final String duration;
  final String formattedDuration;
  final String strategy;
  final double? tolls;

  const RouteResultItem({
    required this.distance,
    required this.formattedDistance,
    required this.duration,
    required this.formattedDuration,
    required this.strategy,
    this.tolls,
  });
}