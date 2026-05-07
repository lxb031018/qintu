import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
import 'package:qintu/features/map_navigation/models/amap_bus_models.dart';

export 'package:qintu/features/map_navigation/models/amap_routing_models.dart' show StationEntrance, WalkStep;

enum TransitSegmentType {
  walk,
  bus,
  subway,
  taxi,
}

class BusTransitSegment {
  final TransitSegmentType type;
  final List<LatLng> points;
  final double distance;
  final double? duration;
  final String? lineName;
  // 公交/地铁线路详情
  final String? busLineId;
  final String? lineType;
  final int? stationCount;
  final String? departureStation;
  final String? arrivalStation;
  final double? basicPrice;
  final double? totalPrice;
  final String? firstBusTime;
  final String? lastBusTime;
  final String? originatingStation;
  final String? terminalStation;
  final String? busCompany;
  final List<BusLineStation>? passStations;
  // 地铁进出站
  final StationEntrance? entrance;
  final StationEntrance? exit;
  // 步行导航步骤
  final List<WalkStep>? walkSteps;
  // 打车段
  final double? taxiDuration;
  final double? taxiPrice;
  final LatLng? taxiOrigin;
  final LatLng? taxiDestination;

  const BusTransitSegment({
    required this.type,
    required this.points,
    required this.distance,
    this.duration,
    this.lineName,
    this.busLineId,
    this.lineType,
    this.stationCount,
    this.departureStation,
    this.arrivalStation,
    this.basicPrice,
    this.totalPrice,
    this.firstBusTime,
    this.lastBusTime,
    this.originatingStation,
    this.terminalStation,
    this.busCompany,
    this.passStations,
    this.entrance,
    this.exit,
    this.walkSteps,
    this.taxiDuration,
    this.taxiPrice,
    this.taxiOrigin,
    this.taxiDestination,
  });

  factory BusTransitSegment.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String? ?? 'walk';
    final type = _parseType(typeStr);
    final pointsRaw = map['points'] as List<dynamic>? ?? [];
    final points = pointsRaw.map((p) {
      final coords = p as List<dynamic>;
      return LatLng(coords[1] as double, coords[0] as double);
    }).toList();

    // 解析 passStations
    final passStationsRaw = map['passStations'] as List<dynamic>?;
    final passStations = passStationsRaw?.map((p) {
      final m = p as Map<String, dynamic>;
      return BusLineStation(
        id: m['id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        lat: (m['lat'] as num?)?.toDouble() ?? 0,
        lng: (m['lng'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    // 解析 entrance/exit
    StationEntrance? entrance;
    final entranceRaw = map['entrance'] as Map<String, dynamic>?;
    if (entranceRaw != null) {
      entrance = StationEntrance(
        name: entranceRaw['name']?.toString() ?? '',
        lat: (entranceRaw['lat'] as num?)?.toDouble() ?? 0,
        lng: (entranceRaw['lng'] as num?)?.toDouble() ?? 0,
      );
    }
    StationEntrance? exit;
    final exitRaw = map['exit'] as Map<String, dynamic>?;
    if (exitRaw != null) {
      exit = StationEntrance(
        name: exitRaw['name']?.toString() ?? '',
        lat: (exitRaw['lat'] as num?)?.toDouble() ?? 0,
        lng: (exitRaw['lng'] as num?)?.toDouble() ?? 0,
      );
    }

    // 解析 walkSteps
    final walkStepsRaw = map['walkSteps'] as List<dynamic>?;
    final walkSteps = walkStepsRaw?.map((s) {
      final m = s as Map<String, dynamic>;
      final coords = (m['points'] as List?)?.cast<dynamic>() ?? [];
      final stepPoints = coords.map((p) {
        final c = p as List<dynamic>;
        return LatLng(c[1] as double, c[0] as double);
      }).toList();
      return WalkStep(
        instruction: m['instruction']?.toString() ?? '',
        action: m['action']?.toString() ?? '',
        road: m['road']?.toString() ?? '',
        distance: (m['distance'] as num?)?.toDouble() ?? 0,
        duration: (m['duration'] as num?)?.toDouble() ?? 0,
        points: stepPoints,
        walkAction: WalkStep.parseAction(m['action']?.toString()),
      );
    }).toList();

    // 解析 taxi
    LatLng? taxiOrigin;
    final originRaw = map['origin'] as List<dynamic>?;
    if (originRaw != null && originRaw.length >= 2) {
      taxiOrigin = LatLng(originRaw[1] as double, originRaw[0] as double);
    }
    LatLng? taxiDestination;
    final destRaw = map['destination'] as List<dynamic>?;
    if (destRaw != null && destRaw.length >= 2) {
      taxiDestination = LatLng(destRaw[1] as double, destRaw[0] as double);
    }

    return BusTransitSegment(
      type: type,
      points: points,
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      duration: (map['duration'] as num?)?.toDouble(),
      lineName: map['lineName'] as String?,
      busLineId: map['busLineId'] as String?,
      lineType: map['lineType'] as String?,
      stationCount: (map['stationCount'] as num?)?.toInt(),
      departureStation: (map['departureStation'] as Map<String, dynamic>?)?['name']?.toString(),
      arrivalStation: (map['arrivalStation'] as Map<String, dynamic>?)?['name']?.toString(),
      basicPrice: (map['basicPrice'] as num?)?.toDouble(),
      totalPrice: (map['totalPrice'] as num?)?.toDouble(),
      firstBusTime: map['firstBusTime'] as String?,
      lastBusTime: map['lastBusTime'] as String?,
      originatingStation: map['originatingStation'] as String?,
      terminalStation: map['terminalStation'] as String?,
      busCompany: map['busCompany'] as String?,
      passStations: passStations,
      entrance: entrance,
      exit: exit,
      walkSteps: walkSteps,
      taxiDuration: (map['duration'] as num?)?.toDouble(),
      taxiPrice: (map['price'] as num?)?.toDouble(),
      taxiOrigin: taxiOrigin,
      taxiDestination: taxiDestination,
    );
  }

  static TransitSegmentType _parseType(String type) {
    switch (type) {
      case 'walk':
        return TransitSegmentType.walk;
      case 'bus':
        return TransitSegmentType.bus;
      case 'subway':
        return TransitSegmentType.subway;
      case 'taxi':
        return TransitSegmentType.taxi;
      default:
        return TransitSegmentType.walk;
    }
  }
}

class BusPath {
  final int routeId;
  final double distance;
  final int duration;
  final double cost;
  final bool nightBus;
  final double walkDistance;
  final double busDistance;
  final List<LatLng> points;
  final List<BusTransitSegment> segments;

  const BusPath({
    required this.routeId,
    required this.distance,
    required this.duration,
    required this.cost,
    required this.nightBus,
    required this.walkDistance,
    required this.busDistance,
    required this.points,
    required this.segments,
  });

  factory BusPath.fromMap(Map<String, dynamic> map) {
    final pointsRaw = map['points'] as List<dynamic>? ?? [];
    final points = pointsRaw.map((p) {
      final coords = p as List<dynamic>;
      return LatLng(coords[1] as double, coords[0] as double);
    }).toList();

    final segmentsRaw = map['segments'] as List<dynamic>? ?? [];
    final segments = segmentsRaw.map((s) => BusTransitSegment.fromMap(s as Map<String, dynamic>)).toList();

    return BusPath(
      routeId: (map['routeId'] as num?)?.toInt() ?? 0,
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      cost: (map['cost'] as num?)?.toDouble() ?? 0,
      nightBus: map['nightBus'] as bool? ?? false,
      walkDistance: (map['walkDistance'] as num?)?.toDouble() ?? 0,
      busDistance: (map['busDistance'] as num?)?.toDouble() ?? 0,
      points: points,
      segments: segments,
    );
  }

  String get durationText {
    if (duration < 60) return '$duration秒';
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours小时$minutes分钟';
    }
    return '$minutes分钟';
  }

  String get distanceText {
    if (distance < 1000) return '${distance.toInt()}米';
    return '${(distance / 1000).toStringAsFixed(1)}公里';
  }
}

class BusModeValues {
  BusModeValues._();

  static const int defaultMode = 0;
  static const int saveMoney = 1;
  static const int leaseChange = 2;
  static const int leaseWalk = 3;
  static const int comfortable = 4;
  static const int noSubway = 5;
  static const int subway = 6;
  static const int subwayFirst = 7;
  static const int wasteLess = 8;
}

