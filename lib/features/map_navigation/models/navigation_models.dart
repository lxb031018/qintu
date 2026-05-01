enum NavigationStatus {
  idle,
  navigating,
  arrived,
  offRoute,
  gpsWeak,
  error,
  recalculating,
  recalculated,
  stopped,
  parallelRoad,
}

class NavigationState {
  final NavigationStatus status;
  final double currentSpeed;
  final int remainingDistance;
  final int remainingDuration;
  final String nextInstruction;
  final double? currentLat;
  final double? currentLng;
  final String? roadName;
  final String? naviText;
  final int naviTextType;
  final Map<dynamic, dynamic>? rawData;

  NavigationState({
    required this.status,
    this.currentSpeed = 0,
    this.remainingDistance = 0,
    this.remainingDuration = 0,
    this.nextInstruction = '',
    this.currentLat,
    this.currentLng,
    this.roadName,
    this.naviText,
    this.naviTextType = 0,
    this.rawData,
  });

  /// 从 EventChannel 多类型事件中解析
  factory NavigationState.fromMap(Map<dynamic, dynamic> map) {
    final type = map['type']?.toString() ?? '';
    NavigationStatus status = NavigationStatus.idle;
    double speed = 0;
    int remainingDistance = 0;
    int remainingDuration = 0;
    String instruction = '';
    double? lat;
    double? lng;
    String? roadName;
    String? naviText;

    switch (type) {
      case 'locationUpdate':
        lat = (map['lat'] as num?)?.toDouble();
        lng = (map['lng'] as num?)?.toDouble();
        speed = (map['speed'] as num?)?.toDouble() ?? 0;
        break;
      case 'naviInfo':
        remainingDistance = (map['remainingDistance'] as num?)?.toInt() ?? 0;
        remainingDuration = (map['remainingTime'] as num?)?.toInt() ?? 0;
        instruction = map['nextRoadName']?.toString() ?? '';
        roadName = map['currentRoadName']?.toString() ?? '';
        break;
      case 'naviStatus':
        final s = map['status']?.toString() ?? '';
        switch (s) {
          case 'navigating': status = NavigationStatus.navigating; break;
          case 'arrived': status = NavigationStatus.arrived; break;
          case 'stopped': status = NavigationStatus.stopped; break;
          case 'recalculating': status = NavigationStatus.recalculating; break;
          case 'recalculated': status = NavigationStatus.recalculated; break;
          case 'ready': status = NavigationStatus.idle; break;
          case 'error': status = NavigationStatus.error; break;
          case 'parallelRoad': status = NavigationStatus.parallelRoad; break;
          default: status = NavigationStatus.idle;
        }
        break;
      case 'naviText':
        naviText = map['text']?.toString() ?? '';
        break;
      case 'gpsStatus':
        if (map['isWeak'] == true) status = NavigationStatus.gpsWeak;
        break;
    }

    return NavigationState(
      status: status,
      currentSpeed: speed,
      remainingDistance: remainingDistance,
      remainingDuration: remainingDuration,
      nextInstruction: instruction,
      currentLat: lat,
      currentLng: lng,
      roadName: roadName,
      naviText: naviText,
      rawData: map,
    );
  }

  @override
  String toString() {
    return 'NavigationState('
        'status: $status, '
        'speed: $currentSpeed km/h, '
        'distance: $remainingDistance m, '
        'duration: $remainingDuration s, '
        'instruction: $nextInstruction, '
        'naviText: $naviText)';
  }
}