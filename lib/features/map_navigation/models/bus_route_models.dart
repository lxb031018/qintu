import 'package:qintu/models/location/lat_lng.dart';

enum TransitSegmentType {
  walk,
  bus,
  subway,
  railway,
  taxi,
}

class BusTransitSegment {
  final TransitSegmentType type;
  final List<LatLng> points;
  final double distance;
  final String? lineName;

  const BusTransitSegment({
    required this.type,
    required this.points,
    required this.distance,
    this.lineName,
  });

  factory BusTransitSegment.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String? ?? 'walk';
    final type = _parseType(typeStr);
    final pointsRaw = map['points'] as List<dynamic>? ?? [];
    final points = pointsRaw.map((p) {
      final coords = p as List<dynamic>;
      return LatLng(coords[1] as double, coords[0] as double);
    }).toList();

    return BusTransitSegment(
      type: type,
      points: points,
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      lineName: map['lineName'] as String?,
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
      case 'railway':
        return TransitSegmentType.railway;
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
    if (duration < 60) return '${duration}秒';
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}小时$minutes分钟';
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

