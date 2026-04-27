import 'package:flutter/material.dart';
import 'package:qintu/models/location/lat_lng.dart';

export 'package:qintu/models/location/lat_lng.dart';

/// 出行方式枚举
enum RouteType {
  driving,   // 驾车
  walking,   // 步行
  riding,    // 骑行
  transit,   // 公共交通
}

/// 公共交通线路类型
enum TransitLineType {
  bus,      // 公交
  subway,   // 地铁
  suburban, // 郊区/市域铁路
}

/// 公共交通线路信息
class TransitLine {
  final String name;        // 线路名称，如 "1号线"、"特11路"
  final TransitLineType type; // 类型：公共交通/郊区
  final int stationCount;   // 站数

  const TransitLine({
    required this.name,
    required this.type,
    required this.stationCount,
  });

  String get typeText {
    switch (type) {
      case TransitLineType.bus:
        return '公交';
      case TransitLineType.subway:
        return '地铁';
      case TransitLineType.suburban:
        return '市域铁路';
    }
  }

  IconData get icon {
    switch (type) {
      case TransitLineType.bus:
        return Icons.directions_bus;
      case TransitLineType.subway:
        return Icons.subway;
      case TransitLineType.suburban:
        return Icons.train;
    }
  }
}

/// 路线段（用于公共交通路线）
class TransitSegment {
  final List<TransitLine> lines;      // 该段包含的线路（公共交通）
  final int walkingDistance;           // 该段步行距离（米）
  final String? instruction;           // 引导提示，如 "步行500米到地铁站"

  const TransitSegment({
    required this.lines,
    required this.walkingDistance,
    this.instruction,
  });

  bool get hasTransit => lines.isNotEmpty;
  bool get hasWalking => walkingDistance > 0;
}

/// ============================================
/// 步行导航 Step 模型
/// ============================================

/// 步行方向动作枚举（对应高德 action 字段）
enum WalkAction {
  unknown,        // 未知
  start,          // 起点
  end,            // 终点
  straight,       // 直行
  turnLeft,       // 左转
  turnRight,      // 右转
  slightLeft,     // 左转
  slightRight,    // 右转
  turnBack,       // 掉头
  arcLeft,        // 左转
  arcRight,       // 右转
  firstRoad,      // 出发
  crosswalk,      // 通过人行横道
  underground,     // 通过地下通道
  overpass,       // 通过过街天桥
  airport,        // 机场
  busStation,     // 火车站
  subwayStation,  // 地铁站
  slowDown,       // 减速
  other,          // 其他
}

/// 步行导航步骤
class WalkStep {
  final String instruction;     // 导航指示，如 "沿XX路向南步行500米"
  final String action;          // 动作代码，如 "1"=右转, "2"=左转
  final String road;            // 道路名称
  final double distance;        // 该步骤距离（米）
  final double duration;        // 该步骤预计时间（秒）
  final List<LatLng> points;    // 该步骤的坐标点
  final WalkAction walkAction;  // 解析后的动作枚举

  const WalkStep({
    required this.instruction,
    required this.action,
    required this.road,
    required this.distance,
    required this.duration,
    required this.points,
    required this.walkAction,
  });

  /// 获取方向图标
  IconData get icon {
    switch (walkAction) {
      case WalkAction.start:
      case WalkAction.firstRoad:
        return Icons.play_arrow;
      case WalkAction.end:
        return Icons.flag;
      case WalkAction.straight:
        return Icons.arrow_upward;
      case WalkAction.turnLeft:
        return Icons.arrow_back;
      case WalkAction.turnRight:
        return Icons.arrow_forward;
      case WalkAction.slightLeft:
      case WalkAction.arcLeft:
        return Icons.subdirectory_arrow_left;
      case WalkAction.slightRight:
      case WalkAction.arcRight:
        return Icons.subdirectory_arrow_right;
      case WalkAction.turnBack:
        return Icons.u_turn_left;
      case WalkAction.crosswalk:
        return Icons.person;
      case WalkAction.underground:
        return Icons.subway;
      case WalkAction.overpass:
        return Icons.stairs;
      case WalkAction.slowDown:
        return Icons.remove_circle_outline;
      default:
        return Icons.directions_walk;
    }
  }

  /// 解析动作代码
  static WalkAction parseAction(String? action) {
    if (action == null) return WalkAction.unknown;
    switch (action) {
      case '0':
        return WalkAction.start;
      case '1':
        return WalkAction.turnRight;
      case '2':
        return WalkAction.turnLeft;
      case '3':
        return WalkAction.straight;
      case '4':
        return WalkAction.slowDown;
      case '5':
        return WalkAction.arcRight;
      case '6':
        return WalkAction.arcLeft;
      case '7':
        return WalkAction.turnBack; // 掉头
      case '8':
        return WalkAction.arcLeft;
      case '9':
        return WalkAction.arcRight;
      case '10':
        return WalkAction.crosswalk;
      case '11':
        return WalkAction.underground;
      case '12':
        return WalkAction.overpass;
      default:
        return WalkAction.unknown;
    }
  }

  /// 获取友好的动作描述
  String get actionText {
    switch (walkAction) {
      case WalkAction.start:
        return '出发';
      case WalkAction.end:
        return '到达目的地';
      case WalkAction.straight:
        return '直行';
      case WalkAction.turnLeft:
        return '左转';
      case WalkAction.turnRight:
        return '右转';
      case WalkAction.slightLeft:
        return '向左前方';
      case WalkAction.slightRight:
        return '向右前方';
      case WalkAction.turnBack:
        return '掉头';
      case WalkAction.arcLeft:
        return '左转';
      case WalkAction.arcRight:
        return '右转';
      case WalkAction.crosswalk:
        return '通过人行横道';
      case WalkAction.underground:
        return '通过地下通道';
      case WalkAction.overpass:
        return '通过过街天桥';
      case WalkAction.slowDown:
        return '减速';
      case WalkAction.firstRoad:
        return '出发';
      default:
        return '步行';
    }
  }

  /// 距离显示文本
  String get distanceText {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}公里';
    }
    return '${distance.toInt()}米';
  }

  /// 时长显示文本
  String get durationText {
    final minutes = (duration / 60).ceil();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours小时${mins > 0 ? '$mins分钟' : ''}';
    }
    return '$minutes分钟';
  }
}

/// ============================================
/// 驾车方向动作枚举（对应高德 action 字段）
/// ============================================
enum DriveAction {
  unknown,        // 未知
  turnRight,       // 右转
  turnLeft,        // 左转
  leftAhead,       // 左转
  rightAhead,      // 右转
  leftBack,        // 左后方
  rightBack,       // 右后方
  leftTurnAround,  // 左转掉头
  rightTurnAround, // 右转掉头
  goAhead,         // 直行
  slightLeft,      //向左前方
  slightRight,     //向右前方
  keepLeft,        //靠左
  keepRight,       //靠右
}

/// 驾车导航步骤
class DriveStep {
  final String instruction;     // 导航指示，如 "沿XX路向东南方向行驶"
  final String action;           // 动作代码，如 "1"=右转, "2"=左转
  final String road;            // 道路名称
  final double distance;        // 该步骤距离（米）
  final double duration;        // 该步骤预计时间（秒）
  final List<LatLng> points;    // 该步骤的坐标点
  final DriveAction driveAction; // 解析后的动作枚举
  final String? tmcStatus;      // 交通状态：畅通/缓行/拥堵/严重拥堵

  const DriveStep({
    required this.instruction,
    required this.action,
    required this.road,
    required this.distance,
    required this.duration,
    required this.points,
    required this.driveAction,
    this.tmcStatus,
  });

  /// 解析动作代码
  static DriveAction parseAction(String? action) {
    if (action == null) return DriveAction.unknown;
    switch (action) {
      case '1':
        return DriveAction.turnRight;
      case '2':
        return DriveAction.turnLeft;
      case '3':
        return DriveAction.leftAhead;
      case '4':
        return DriveAction.rightAhead;
      case '5':
        return DriveAction.leftBack;
      case '6':
        return DriveAction.rightBack;
      case '7':
        return DriveAction.leftTurnAround;
      case '8':
        return DriveAction.rightTurnAround;
      case '9':
        return DriveAction.goAhead;
      case '10':
        return DriveAction.slightLeft;
      case '11':
        return DriveAction.slightRight;
      case '12':
        return DriveAction.keepLeft;
      case '13':
        return DriveAction.keepRight;
      default:
        return DriveAction.unknown;
    }
  }

  /// 获取方向图标
  IconData get icon {
    switch (driveAction) {
      case DriveAction.turnRight:
        return Icons.arrow_forward;
      case DriveAction.turnLeft:
        return Icons.arrow_back;
      case DriveAction.leftAhead:
        return Icons.subdirectory_arrow_left;
      case DriveAction.rightAhead:
        return Icons.subdirectory_arrow_right;
      case DriveAction.leftBack:
        return Icons.u_turn_left;
      case DriveAction.rightBack:
        return Icons.u_turn_right;
      case DriveAction.leftTurnAround:
        return Icons.u_turn_left;
      case DriveAction.rightTurnAround:
        return Icons.u_turn_right;
      case DriveAction.goAhead:
        return Icons.arrow_upward;
      case DriveAction.slightLeft:
        return Icons.turn_left;
      case DriveAction.slightRight:
        return Icons.turn_right;
      case DriveAction.keepLeft:
        return Icons.exit_to_app;
      case DriveAction.keepRight:
        return Icons.exit_to_app;
      default:
        return Icons.directions_car;
    }
  }

  /// 获取友好的动作描述
  String get actionText {
    switch (driveAction) {
      case DriveAction.turnRight:
        return '右转';
      case DriveAction.turnLeft:
        return '左转';
      case DriveAction.leftAhead:
        return '向左前方';
      case DriveAction.rightAhead:
        return '向右前方';
      case DriveAction.leftBack:
        return '向左后方';
      case DriveAction.rightBack:
        return '向右后方';
      case DriveAction.leftTurnAround:
        return '左转掉头';
      case DriveAction.rightTurnAround:
        return '右转掉头';
      case DriveAction.goAhead:
        return '直行';
      case DriveAction.slightLeft:
        return '向左前方';
      case DriveAction.slightRight:
        return '向右前方';
      case DriveAction.keepLeft:
        return '靠左';
      case DriveAction.keepRight:
        return '靠右';
      default:
        return '行驶';
    }
  }

  /// 距离显示文本
  String get distanceText {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}公里';
    }
    return '${distance.toInt()}米';
  }

  /// 时长显示文本
  String get durationText {
    final minutes = (duration / 60).ceil();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours小时${mins > 0 ? '$mins分钟' : ''}';
    }
    return '$minutes分钟';
  }

  /// 是否拥堵
  bool get isCongested =>
      tmcStatus == '拥堵' || tmcStatus == '严重拥堵';

  /// 是否畅通
  bool get isSmooth => tmcStatus == '畅通';
}

/// 驾车策略枚举
enum DrivingStrategy {
  fastest,   // 速度最快 (0)
  cheapest,   // 费用优先 (1)
  shortest,   // 距离最短 (2)
}

extension DrivingStrategyExtension on DrivingStrategy {
  int get value {
    switch (this) {
      case DrivingStrategy.fastest:
        return 0;
      case DrivingStrategy.cheapest:
        return 1;
      case DrivingStrategy.shortest:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case DrivingStrategy.fastest:
        return '速度最快';
      case DrivingStrategy.cheapest:
        return '费用优先';
      case DrivingStrategy.shortest:
        return '距离最短';
    }
  }
}
class RouteOption {
  final double distance;    // 米
  final double duration;    // 秒
  final String strategy;
  final double tolls;       // 过路费（元）或公交费用
  final List<LatLng> points; // 路线坐标点
  final RouteType routeType; // 出行方式
  final List<TransitSegment>? transitSegments; // 公共交通段详情（仅 transit 类型）
  final List<WalkStep>? walkSteps; // 步行导航步骤详情（仅 walking 类型）
  final List<WalkStep>? rideSteps; // 骑行导航步骤详情（仅 riding 类型，结构与 WalkStep 相同）
  final List<DriveStep>? driveSteps; // 驾车导航步骤详情（仅 driving 类型）

  const RouteOption({
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
        if (strategy.contains('速度') || strategy == '0') return '速度最快';
        if (strategy.contains('距离') || strategy == '2') return '距离最短';
        if (strategy.contains('费用') || strategy == '1') return '费用优先';
        return strategy;
      case RouteType.walking:
        return '步行路线';
      case RouteType.riding:
        return '骑行路线';
      case RouteType.transit:
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
    for (final segment in transitSegments!) {
      if (segment.hasWalking) {
        final walkDist = segment.walkingDistance >= 1000
            ? '${(segment.walkingDistance / 1000).toStringAsFixed(1)}公里'
            : '${segment.walkingDistance}米';
        parts.add('步行$walkDist');
      }
      for (final line in segment.lines) {
        if (line.stationCount > 0) {
          parts.add('${line.typeText}${line.name}(${line.stationCount}站)');
        } else {
          parts.add('${line.typeText}${line.name}');
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
    for (final segment in transitSegments!) {
      for (final line in segment.lines) {
        if (!names.contains(line.name)) {
          names.add(line.name);
        }
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
