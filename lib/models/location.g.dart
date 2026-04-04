// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  receiverOpenid: json['receiver_openid'] as String,
  taskId: json['task_id'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  speed: (json['speed'] as num?)?.toDouble(),
  bearing: (json['bearing'] as num?)?.toDouble(),
  altitude: (json['altitude'] as num?)?.toDouble(),
  isNavigating: json['is_navigating'] as bool? ?? false,
  isSharing: json['is_sharing'] as bool? ?? false,
  updatedAt: DateTime.parse(json['updated_at'] as String),
  taskStatus: json['task_status'] as String?,
  endName: json['end_name'] as String?,
  endLatitude: (json['end_latitude'] as num?)?.toDouble(),
  endLongitude: (json['end_longitude'] as num?)?.toDouble(),
  distanceToDestination: (json['distance_to_destination'] as num?)?.toInt(),
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'receiver_openid': instance.receiverOpenid,
  'task_id': instance.taskId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracy': instance.accuracy,
  'speed': instance.speed,
  'bearing': instance.bearing,
  'altitude': instance.altitude,
  'is_navigating': instance.isNavigating,
  'is_sharing': instance.isSharing,
  'updated_at': instance.updatedAt.toIso8601String(),
  'task_status': instance.taskStatus,
  'end_name': instance.endName,
  'end_latitude': instance.endLatitude,
  'end_longitude': instance.endLongitude,
  'distance_to_destination': instance.distanceToDestination,
};

LocationUpdateRequest _$LocationUpdateRequestFromJson(
  Map<String, dynamic> json,
) => LocationUpdateRequest(
  taskId: json['task_id'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  speed: (json['speed'] as num?)?.toDouble(),
  bearing: (json['bearing'] as num?)?.toDouble(),
  altitude: (json['altitude'] as num?)?.toDouble(),
  isNavigating: json['is_navigating'] as bool? ?? true,
);

Map<String, dynamic> _$LocationUpdateRequestToJson(
  LocationUpdateRequest instance,
) => <String, dynamic>{
  'task_id': instance.taskId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracy': instance.accuracy,
  'speed': instance.speed,
  'bearing': instance.bearing,
  'altitude': instance.altitude,
  'is_navigating': instance.isNavigating,
};
