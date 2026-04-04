// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigationTask _$NavigationTaskFromJson(Map<String, dynamic> json) =>
    NavigationTask(
      taskId: json['task_id'] as String,
      senderOpenid: json['sender_openid'] as String,
      receiverOpenid: json['receiver_openid'] as String,
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
      startName: json['start_name'] as String?,
      startLatitude: (json['start_latitude'] as num?)?.toDouble(),
      startLongitude: (json['start_longitude'] as num?)?.toDouble(),
      startAddress: json['start_address'] as String?,
      endName: json['end_name'] as String,
      endLatitude: (json['end_latitude'] as num).toDouble(),
      endLongitude: (json['end_longitude'] as num).toDouble(),
      endAddress: json['end_address'] as String?,
      routeData: json['route_data'] as Map<String, dynamic>?,
      routeSummary: json['route_summary'] as Map<String, dynamic>?,
      transportMode:
          $enumDecodeNullable(_$TransportModeEnumMap, json['transport_mode']) ??
          TransportMode.drive,
      distanceMeters: (json['distance_meters'] as num?)?.toInt(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] == null
          ? null
          : DateTime.parse(json['accepted_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      finishedAt: json['finished_at'] == null
          ? null
          : DateTime.parse(json['finished_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      cancelReason: json['cancel_reason'] as String?,
      cancelledBy: $enumDecodeNullable(
        _$CancelledByEnumMap,
        json['cancelled_by'],
      ),
      senderNickname: json['sender_nickname'] as String?,
      senderPhone: json['sender_phone'] as String?,
      receiverNickname: json['receiver_nickname'] as String?,
      receiverPhone: json['receiver_phone'] as String?,
      minutesWaiting: (json['minutes_waiting'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NavigationTaskToJson(NavigationTask instance) =>
    <String, dynamic>{
      'task_id': instance.taskId,
      'sender_openid': instance.senderOpenid,
      'receiver_openid': instance.receiverOpenid,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'start_name': instance.startName,
      'start_latitude': instance.startLatitude,
      'start_longitude': instance.startLongitude,
      'start_address': instance.startAddress,
      'end_name': instance.endName,
      'end_latitude': instance.endLatitude,
      'end_longitude': instance.endLongitude,
      'end_address': instance.endAddress,
      'route_data': instance.routeData,
      'route_summary': instance.routeSummary,
      'transport_mode': _$TransportModeEnumMap[instance.transportMode]!,
      'distance_meters': instance.distanceMeters,
      'duration_seconds': instance.durationSeconds,
      'created_at': instance.createdAt.toIso8601String(),
      'accepted_at': instance.acceptedAt?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'finished_at': instance.finishedAt?.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'cancel_reason': instance.cancelReason,
      'cancelled_by': _$CancelledByEnumMap[instance.cancelledBy],
      'sender_nickname': instance.senderNickname,
      'sender_phone': instance.senderPhone,
      'receiver_nickname': instance.receiverNickname,
      'receiver_phone': instance.receiverPhone,
      'minutes_waiting': instance.minutesWaiting,
    };

const _$TaskStatusEnumMap = {
  TaskStatus.waiting: 'waiting',
  TaskStatus.accepted: 'accepted',
  TaskStatus.navigating: 'navigating',
  TaskStatus.finished: 'finished',
  TaskStatus.cancelled: 'cancelled',
  TaskStatus.expired: 'expired',
};

const _$TransportModeEnumMap = {
  TransportMode.drive: 'drive',
  TransportMode.walk: 'walk',
  TransportMode.bike: 'bike',
  TransportMode.bus: 'bus',
};

const _$CancelledByEnumMap = {
  CancelledBy.sender: 'sender',
  CancelledBy.receiver: 'receiver',
  CancelledBy.system: 'system',
};

TaskList _$TaskListFromJson(Map<String, dynamic> json) => TaskList(
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  tasks: (json['tasks'] as List<dynamic>)
      .map((e) => NavigationTask.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TaskListToJson(TaskList instance) => <String, dynamic>{
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'tasks': instance.tasks,
};
