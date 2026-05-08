import 'package:flutter/material.dart';
import 'route_segment_models.dart';
import 'bus_route_models.dart';

/// 出行方式枚举
enum RouteType {
  driving,
  walking,
  riding,
  transit,
}

/// 路线规划结果
class RouteOption {
  final int routeId;        // 原生路线 ID（用于 SDK 渲染）
  final double distance;    // 米
  final double duration;    // 秒
  final String strategy;
  final double tolls;       // 过路费（元）或公交费用
  final List<LatLng> points; // 路线坐标点
  final RouteType routeType; // 出行方式
  final int strategyId;      // 算路策略编号 (0-6)
  final List<BusTransitSegment>? transitSegments; // 公共交通段详情（仅 transit 类型）
  final List<WalkStep>? walkSteps; // 步行导航步骤详情（仅 walking 类型）
  final List<WalkStep>? rideSteps; // 骑行导航步骤详情（仅 riding 类型，结构与 WalkStep 相同）
  final List<DriveStep>? driveSteps; // 驾车导航步骤详情（仅 driving 类型）
  final LatLng? userOrigin; // transit 类型的用户真实起点（用于步行补充）
  final LatLng? userDest;   // transit 类型的用户真实终点（用于步行补充）
  final double? walkDistance;   // 总步行距离（米）
  final double? busDistance;    // 总公交距离（米）
  final bool? isNightBus;       // 是否包含夜班车
  final double? taxiCost;       // 打车费用估算（元）
  final int? strategyMode;      // 公交算路策略原始值 (0-5)
  final int trafficLights;      // 途经交通灯数量
  final int? routeSubType;      // 路线子类型（1=驾车,2=骑行,3=步行,4=电动自行车）
  final String? mainRoadInfo;   // 主要道路信息
  final int cameraCount;        // 摄像头数量
  final List<String>? cityCodes; // 起点城市区号（用于地铁颜色匹配）
  final List<Map<String, dynamic>>? trafficStatuses; // 交通路况列表
  final Map<String, dynamic>? restrictionInfo; // 限行信息
  final int naviGuideGroupCount; // 导航引导组数量
  final double? tollDistance;   // 收费路段距离（米）
  final String? tollRoad;       // 收费道路名称
  final int? restriction;       // 限行结果（0=不限行, 1=限行）

  const RouteOption({
    this.routeId = -1,
    required this.distance,
    required this.duration,
    required this.strategy,
    required this.tolls,
    required this.points,
    required this.routeType,
    this.transitSegments,
    this.walkSteps,
    this.rideSteps,
    this.driveSteps,
    this.userOrigin,
    this.userDest,
    this.walkDistance,
    this.busDistance,
    this.isNightBus,
    this.taxiCost,
    this.strategyMode,
    this.trafficLights = 0,
    this.strategyId = 0,
    this.routeSubType,
    this.mainRoadInfo,
    this.cameraCount = 0,
    this.cityCodes,
    this.trafficStatuses,
    this.restrictionInfo,
    this.naviGuideGroupCount = 0,
    this.tollDistance,
    this.tollRoad,
    this.restriction,
  });

  /// 距离显示文本
  String get distanceText {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}公里';
    }
    return '${distance.toInt()}米';
  }

  /// 耗时显示文本
  String get durationText {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600 ~/ 60);
    if (hours > 0) {
      return '$hours小时$minutes分钟';
    }
    return '$minutes分钟';
  }

  /// 费用显示文本
  String get tollsText {
    switch (routeType) {
      case RouteType.driving:
        if (tolls > 0) return '过路费 ¥$tolls';
        return '无过路费';
      case RouteType.walking:
        return '免费';
      case RouteType.riding:
        return '免费';
      case RouteType.transit:
        return '票价 ¥$tolls';
    }
  }

  /// 策略显示文本
  String get strategyText {
    switch (routeType) {
      case RouteType.driving:
        switch (strategyId) {
          case 0: return '速度最快';
          case 1: return '避免收费';
          case 2: return '距离最短';
          case 3: return '避免拥堵';
          case 4: return '避免拥堵+高速优先';
          case 5: return '避免收费+高速优先';
          case 6: return '避开高速';
          default:
            if (strategy.isNotEmpty) return strategy;
            return '速度最快';
        }
      case RouteType.walking:
        if (strategy.isNotEmpty) return strategy;
        return '步行路线';
      case RouteType.riding:
        if (strategy.isNotEmpty) return strategy;
        return '骑行路线';
      case RouteType.transit:
        if (strategyMode != null) {
          switch (strategyMode!) {
            case 0: return '较快捷';
            case 1: return '少换乘';
            case 2: return '少步行';
            case 3: return '不乘地铁';
            case 4: return '较舒适';
            case 5: return '较经济';
          }
        }
        return '公共交通';
    }
  }

  /// 出行方式图标
  IconData get routeIcon {
    switch (routeType) {
      case RouteType.driving:
        return Icons.directions_car;
      case RouteType.walking:
        return Icons.directions_walk;
      case RouteType.riding:
        return Icons.directions_bike;
      case RouteType.transit:
        return Icons.directions_bus;
    }
  }

  /// 获取公共交通路线详情文本
  /// 例如: "步行500米 → 地铁1号线(6站) → 步行200米 → 公交45路(4站)"
  String? get transitSummaryText {
    if (routeType != RouteType.transit || transitSegments == null) {
      return null;
    }

    final parts = <String>[];
    for (final seg in transitSegments!) {
      if (seg.hasWalking) {
        final walkDist = seg.distance >= 1000
            ? '${(seg.distance / 1000).toStringAsFixed(1)}公里'
            : '${seg.distance.toInt()}米';
        parts.add('步行$walkDist');
      }
      if (seg.hasTransit) {
        final typeLabel = seg.type == TransitSegmentType.subway ? '地铁' : '公交';
        final name = seg.lineName ?? '';
        if (seg.stationCount != null && seg.stationCount! > 0) {
          parts.add('$typeLabel$name(${seg.stationCount}站)');
        } else {
          parts.add('$typeLabel$name');
        }
      }
    }
    return parts.join(' → ');
  }

  /// 获取简化的公共交通线路列表
  /// 例如: ["1号线", "45路", "10号线"]
  List<String> get transitLineNames {
    if (routeType != RouteType.transit || transitSegments == null) {
      return [];
    }

    final names = <String>[];
    for (final seg in transitSegments!) {
      if (seg.hasTransit && seg.lineName != null && !names.contains(seg.lineName)) {
        names.add(seg.lineName!);
      }
    }
    return names;
  }

  /// 获取换乘次数
  int get transferCount {
    if (routeType != RouteType.transit || transitSegments == null) {
      return 0;
    }
    return transitSegments!.where((s) => s.hasTransit).length - 1;
  }
}

/// 路线规划异常
class RoutingException implements Exception {
  final String message;
  const RoutingException(this.message);
  @override
  String toString() => 'RoutingException: $message';
}