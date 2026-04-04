import 'package:json_annotation/json_annotation.dart';

part 'navigation_task.g.dart';

/// 导航任务状态
enum TaskStatus {
  @JsonValue('waiting')
  waiting,       // 等待接收者接受
  @JsonValue('accepted')
  accepted,      // 已接受，等待开始导航
  @JsonValue('navigating')
  navigating,    // 导航进行中
  @JsonValue('finished')
  finished,      // 已完成
  @JsonValue('cancelled')
  cancelled,     // 已取消
  @JsonValue('expired')
  expired,       // 已过期
}

/// 出行方式
enum TransportMode {
  @JsonValue('drive')
  drive,     // 驾车
  @JsonValue('walk')
  walk,      // 步行
  @JsonValue('bike')
  bike,      // 骑行
  @JsonValue('bus')
  bus,       // 公交
}

/// 取消方
enum CancelledBy {
  @JsonValue('sender')
  sender,
  @JsonValue('receiver')
  receiver,
  @JsonValue('system')
  system,
}

/// 导航任务数据模型
@JsonSerializable()
class NavigationTask {
  /// 任务 ID（UUID）
  @JsonKey(name: 'task_id')
  final String taskId;
  
  /// 发送者 openid
  @JsonKey(name: 'sender_openid')
  final String senderOpenid;
  
  /// 接收者 openid
  @JsonKey(name: 'receiver_openid')
  final String receiverOpenid;
  
  /// 任务状态
  final TaskStatus status;
  
  // 起点信息
  @JsonKey(name: 'start_name')
  final String? startName;
  
  @JsonKey(name: 'start_latitude')
  final double? startLatitude;
  
  @JsonKey(name: 'start_longitude')
  final double? startLongitude;
  
  @JsonKey(name: 'start_address')
  final String? startAddress;
  
  // 终点信息
  @JsonKey(name: 'end_name')
  final String endName;
  
  @JsonKey(name: 'end_latitude')
  final double endLatitude;
  
  @JsonKey(name: 'end_longitude')
  final double endLongitude;
  
  @JsonKey(name: 'end_address')
  final String? endAddress;
  
  /// 高德地图路线数据（JSON 对象）
  @JsonKey(name: 'route_data')
  final Map<String, dynamic>? routeData;
  
  /// 路线摘要
  @JsonKey(name: 'route_summary')
  final Map<String, dynamic>? routeSummary;
  
  /// 出行方式
  @JsonKey(name: 'transport_mode')
  final TransportMode transportMode;
  
  /// 总距离（米）
  @JsonKey(name: 'distance_meters')
  final int? distanceMeters;
  
  /// 预计耗时（秒）
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  
  /// 时间戳
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'accepted_at')
  final DateTime? acceptedAt;
  
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  
  @JsonKey(name: 'finished_at')
  final DateTime? finishedAt;
  
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  
  @JsonKey(name: 'cancel_reason')
  final String? cancelReason;
  
  @JsonKey(name: 'cancelled_by')
  final CancelledBy? cancelledBy;
  
  // 关联信息（列表查询时包含）
  @JsonKey(name: 'sender_nickname')
  final String? senderNickname;
  
  @JsonKey(name: 'sender_phone')
  final String? senderPhone;
  
  @JsonKey(name: 'receiver_nickname')
  final String? receiverNickname;
  
  @JsonKey(name: 'receiver_phone')
  final String? receiverPhone;
  
  /// 等待时间（分钟）
  @JsonKey(name: 'minutes_waiting')
  final int? minutesWaiting;

  const NavigationTask({
    required this.taskId,
    required this.senderOpenid,
    required this.receiverOpenid,
    required this.status,
    this.startName,
    this.startLatitude,
    this.startLongitude,
    this.startAddress,
    required this.endName,
    required this.endLatitude,
    required this.endLongitude,
    this.endAddress,
    this.routeData,
    this.routeSummary,
    this.transportMode = TransportMode.drive,
    this.distanceMeters,
    this.durationSeconds,
    required this.createdAt,
    this.acceptedAt,
    this.startedAt,
    this.finishedAt,
    this.cancelledAt,
    this.cancelReason,
    this.cancelledBy,
    this.senderNickname,
    this.senderPhone,
    this.receiverNickname,
    this.receiverPhone,
    this.minutesWaiting,
  });

  factory NavigationTask.fromJson(Map<String, dynamic> json) => _$NavigationTaskFromJson(json);

  Map<String, dynamic> toJson() => _$NavigationTaskToJson(this);

  /// 是否可以接受（仅 waiting 状态可接受）
  bool get canAccept => status == TaskStatus.waiting;

  /// 是否可以开始导航（仅 accepted 状态可开始）
  bool get canStart => status == TaskStatus.accepted;

  /// 是否可以完成（accepted 或 navigating 状态可完成）
  bool get canFinish => status == TaskStatus.accepted || status == TaskStatus.navigating;

  /// 是否可以取消（waiting/accepted/navigating 可取消）
  bool get canCancel => 
      status == TaskStatus.waiting || 
      status == TaskStatus.accepted || 
      status == TaskStatus.navigating;

  /// 是否可以更新路线（accepted/navigating 可更新）
  bool get canUpdateRoute => status == TaskStatus.accepted || status == TaskStatus.navigating;

  /// 获取格式化的距离字符串
  String? get distanceText {
    if (distanceMeters == null) return null;
    if (distanceMeters! >= 1000) {
      return '${(distanceMeters! / 1000).toStringAsFixed(1)} km';
    }
    return '$distanceMeters m';
  }

  /// 获取格式化的时间字符串
  String? get durationText {
    if (durationSeconds == null) return null;
    final minutes = durationSeconds! ~/ 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours小时$mins分钟';
    }
    return '$minutes分钟';
  }

  @override
  String toString() {
    return 'NavigationTask(taskId: $taskId, status: $status, end: $endName)';
  }
}

/// 导航任务列表响应
@JsonSerializable()
class TaskList {
  /// 总任务数
  final int total;
  
  /// 当前页码
  final int page;
  
  /// 每页数量
  final int limit;
  
  /// 任务列表
  final List<NavigationTask> tasks;

  const TaskList({
    required this.total,
    required this.page,
    required this.limit,
    required this.tasks,
  });

  factory TaskList.fromJson(Map<String, dynamic> json) => _$TaskListFromJson(json);

  Map<String, dynamic> toJson() => _$TaskListToJson(this);
}
