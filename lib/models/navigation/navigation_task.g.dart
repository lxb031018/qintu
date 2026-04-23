// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NavigationTask _$NavigationTaskFromJson(Map<String, dynamic> json) =>
    _NavigationTask(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      senderName: json['senderName'] as String,
      receiverName: json['receiverName'] as String,
      originName: json['originName'] as String,
      originLat: (json['originLat'] as num).toDouble(),
      originLng: (json['originLng'] as num).toDouble(),
      destinationName: json['destinationName'] as String,
      destinationLat: (json['destinationLat'] as num).toDouble(),
      destinationLng: (json['destinationLng'] as num).toDouble(),
      routePoints: (json['routePoints'] as List<dynamic>)
          .map((e) => LatLng.fromJson(e as Map<String, dynamic>))
          .toList(),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      strategy: json['strategy'] as String,
      status: json['status'] as String? ?? NavigationTaskStatuses.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$NavigationTaskToJson(_NavigationTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'senderName': instance.senderName,
      'receiverName': instance.receiverName,
      'originName': instance.originName,
      'originLat': instance.originLat,
      'originLng': instance.originLng,
      'destinationName': instance.destinationName,
      'destinationLat': instance.destinationLat,
      'destinationLng': instance.destinationLng,
      'routePoints': instance.routePoints,
      'distance': instance.distance,
      'duration': instance.duration,
      'strategy': instance.strategy,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'note': instance.note,
    };

_NavigationTaskList _$NavigationTaskListFromJson(Map<String, dynamic> json) =>
    _NavigationTaskList(
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => NavigationTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$NavigationTaskListToJson(_NavigationTaskList instance) =>
    <String, dynamic>{'tasks': instance.tasks, 'total': instance.total};
