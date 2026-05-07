import 'package:flutter/material.dart';
import 'package:qintu/models/location/lat_lng.dart';
import 'amap_bus_models.dart';

export 'package:qintu/models/location/lat_lng.dart';

/// 公共交通线路类型
enum TransitLineType {
  bus,      // 公交
  subway,   // 地铁
}

/// 公共交通线路信息
class TransitLine {
  final String name;               // 线路名称，如 "1号线"、"特11路"
  final TransitLineType type;      // 类型：公交/地铁
  final int stationCount;          // 站数
  final String? departureStation;  // 上车站名
  final String? arrivalStation;   // 下车站名
  final double? duration;          // 行驶时长（秒）
  // 公交线路详情
  final String? busLineId;         // 线路唯一ID
  final String? lineType;          // 线路类型描述，如 "空调线路"、"快线"
  final double? basicPrice;        // 起步价
  final double? totalPrice;        // 全程票价
  final String? firstBusTime;      // 首班车时间
  final String? lastBusTime;       // 末班车时间
  final String? originatingStation; // 始发站
  final String? terminalStation;   // 终点站
  final String? busCompany;        // 运营公司
  final List<BusLineStation>? passStations;  // 途经站点

  const TransitLine({
    required this.name,
    required this.type,
    required this.stationCount,
    this.departureStation,
    this.arrivalStation,
    this.duration,
    this.busLineId,
    this.lineType,
    this.basicPrice,
    this.totalPrice,
    this.firstBusTime,
    this.lastBusTime,
    this.originatingStation,
    this.terminalStation,
    this.busCompany,
    this.passStations,
  });

  String get typeText {
    switch (type) {
      case TransitLineType.bus:
        return '公交';
      case TransitLineType.subway:
        return '地铁';
    }
  }

  IconData get icon {
    switch (type) {
      case TransitLineType.bus:
        return Icons.directions_bus;
      case TransitLineType.subway:
        return Icons.subway;
    }
  }
}

/// 地铁出入口
class StationEntrance {
  final String name;
  final double lat;
  final double lng;

  const StationEntrance({
    required this.name,
    required this.lat,
    required this.lng,
  });

  LatLng get latLng => LatLng(lat, lng);
}

/// 路线段（用于公共交通路线）
class TransitSegment {
  final List<TransitLine> lines;          // 该段包含的线路（公共交通）
  final int walkingDistance;               // 该段步行距离（米）
  final List<LatLng> points;               // 该段的坐标点（用于分段渲染不同颜色）
  final StationEntrance? entrance;        // 进站入口（地铁）
  final StationEntrance? exit;            // 出站出口（地铁）
  final List<WalkStep>? walkSteps;         // 步行导航步骤详情（transit 内步行段）
  final TaxiSegment? taxi;                // 打车段详情

  const TransitSegment({
    required this.lines,
    required this.walkingDistance,
    this.points = const [],
    this.entrance,
    this.exit,
    this.walkSteps,
    this.taxi,
  });

  bool get hasTransit => lines.isNotEmpty;
  bool get hasWalking => walkingDistance > 0;
  bool get hasTaxi => taxi != null;

  /// 路段类型：0=纯步行, 1=公交, 2=地铁, 4=打车
  int get segmentType {
    if (taxi != null) return 4;
    if (lines.isEmpty) return 0;
    for (final line in lines) {
      if (line.type == TransitLineType.subway) return 2;
    }
    return 1;
  }
}

/// 出租车段
class TaxiSegment {
  final LatLng? origin;
  final LatLng? destination;
  final double? distance;
  final double? duration;
  final double? price;
  final List<LatLng> points;

  const TaxiSegment({
    this.origin,
    this.destination,
    this.distance,
    this.duration,
    this.price,
    this.points = const [],
  });
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
  final double lat;             // 步骤起始纬度
  final double lng;             // 步骤起始经度

  const WalkStep({
    required this.instruction,
    this.action = '',
    this.road = '',
    required this.distance,
    required this.duration,
    required this.points,
    this.walkAction = WalkAction.unknown,
    this.lat = 0,
    this.lng = 0,
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
  final double lat;             // 步骤起始纬度
  final double lng;             // 步骤起始经度
  final List<Map<String, double>>? links; // 路段道路列表
  final double chargeLength;              // 收费路段距离（米）
  final double tollCost;                  // 该段过路费（元）
  final int trafficLightCount;            // 红绿灯数量
  final bool isArriveWayPoint;            // 是否经过途经点
  final String? orientation;              // 方向描述
  final String? naviInstruction;          // 导航指令详情
  final List<TmcSegment>? tmcs;           // TMC 路况分段列表

  const DriveStep({
    required this.instruction,
    required this.action,
    required this.road,
    required this.distance,
    required this.duration,
    required this.points,
    required this.driveAction,
    this.tmcStatus,
    this.lat = 0,
    this.lng = 0,
    this.links,
    this.chargeLength = 0,
    this.tollCost = 0,
    this.trafficLightCount = 0,
    this.isArriveWayPoint = false,
    this.orientation,
    this.naviInstruction,
    this.tmcs,
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

/// TMC 路况分段
class TmcSegment {
  final String status;
  final int distance;
  final int duration;
  final List<LatLng> points;

  const TmcSegment({
    required this.status,
    required this.distance,
    required this.duration,
    this.points = const [],
  });
}