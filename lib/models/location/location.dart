import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

/// 实时位置数据模型
@JsonSerializable()
class Location {
  /// 接收者 openid
  @JsonKey(name: 'receiver_openid')
  final String receiverOpenid;
  
  /// 当前导航任务 ID
  @JsonKey(name: 'task_id')
  final String? taskId;
  
  /// 纬度
  final double latitude;
  
  /// 经度
  final double longitude;
  
  /// 定位精度（米）
  final double? accuracy;
  
  /// 速度（km/h）
  final double? speed;
  
  /// 方向角（0-360度）
  final double? bearing;
  
  /// 海拔高度（米）
  final double? altitude;
  
  /// 是否正在导航
  @JsonKey(name: 'is_navigating')
  final bool isNavigating;
  
  /// 是否正在共享位置
  @JsonKey(name: 'is_sharing')
  final bool isSharing;
  
  /// 最后更新时间
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  /// 任务状态（关联查询时包含）
  @JsonKey(name: 'task_status')
  final String? taskStatus;
  
  /// 终点名称（关联查询时包含）
  @JsonKey(name: 'end_name')
  final String? endName;
  
  /// 终点纬度（关联查询时包含）
  @JsonKey(name: 'end_latitude')
  final double? endLatitude;
  
  /// 终点经度（关联查询时包含）
  @JsonKey(name: 'end_longitude')
  final double? endLongitude;
  
  /// 距离目的地的距离（米）（计算得出）
  @JsonKey(name: 'distance_to_destination')
  final int? distanceToDestination;

  const Location({
    required this.receiverOpenid,
    this.taskId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.bearing,
    this.altitude,
    this.isNavigating = false,
    this.isSharing = false,
    required this.updatedAt,
    this.taskStatus,
    this.endName,
    this.endLatitude,
    this.endLongitude,
    this.distanceToDestination,
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

  /// 获取格式化的速度文本
  String? get speedText {
    if (speed == null) return null;
    return '${speed!.toStringAsFixed(1)} km/h';
  }

  /// 获取格式化的距离目的地文本
  String? get distanceToDestinationText {
    if (distanceToDestination == null) return null;
    if (distanceToDestination! >= 1000) {
      return '${(distanceToDestination! / 1000).toStringAsFixed(1)} km';
    }
    return '$distanceToDestination m';
  }

  /// 位置是否有效
  bool get isValid => latitude != 0 && longitude != 0;

  @override
  String toString() {
    return 'Location(lat: $latitude, lng: $longitude, speed: $speed)';
  }
}

/// 位置更新请求
@JsonSerializable()
class LocationUpdateRequest {
  /// 当前导航任务 ID
  @JsonKey(name: 'task_id')
  final String? taskId;
  
  /// 纬度
  final double latitude;
  
  /// 经度
  final double longitude;
  
  /// 定位精度（米）
  final double? accuracy;
  
  /// 速度（km/h）
  final double? speed;
  
  /// 方向角（0-360度）
  final double? bearing;
  
  /// 海拔高度（米）
  final double? altitude;
  
  /// 是否正在导航
  @JsonKey(name: 'is_navigating')
  final bool isNavigating;

  const LocationUpdateRequest({
    this.taskId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.bearing,
    this.altitude,
    this.isNavigating = true,
  });

  factory LocationUpdateRequest.fromJson(Map<String, dynamic> json) => 
      _$LocationUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LocationUpdateRequestToJson(this);

  LocationUpdateRequest copyWith({
    String? taskId,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? speed,
    double? bearing,
    double? altitude,
    bool? isNavigating,
  }) {
    return LocationUpdateRequest(
      taskId: taskId ?? this.taskId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      bearing: bearing ?? this.bearing,
      altitude: altitude ?? this.altitude,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}
