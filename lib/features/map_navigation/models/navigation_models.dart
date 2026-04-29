enum NavigationStatus {
  idle,
  navigating,
  paused,
  arrived,
  offRoute,
  gpsWeak,
  error,
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
  });

  factory NavigationState.fromMap(Map<dynamic, dynamic> map) {
    return NavigationState(
      status: _parseStatus(map['status']),
      currentSpeed: (map['currentSpeed'] ?? 0).toDouble(),
      remainingDistance: (map['remainingDistance'] ?? 0).toInt(),
      remainingDuration: (map['remainingDuration'] ?? 0).toInt(),
      nextInstruction: map['nextInstruction'] ?? '',
      currentLat: map['currentLat']?.toDouble(),
      currentLng: map['currentLng']?.toDouble(),
      roadName: map['roadName'],
      naviText: map['naviText'],
      naviTextType: (map['naviTextType'] ?? 0).toInt(),
    );
  }

  static NavigationStatus _parseStatus(dynamic status) {
    switch (status) {
      case 'navigating':
        return NavigationStatus.navigating;
      case 'paused':
        return NavigationStatus.paused;
      case 'arrived':
        return NavigationStatus.arrived;
      case 'off_route':
        return NavigationStatus.offRoute;
      case 'gps_weak':
        return NavigationStatus.gpsWeak;
      case 'error':
        return NavigationStatus.error;
      default:
        return NavigationStatus.idle;
    }
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