import 'package:freezed_annotation/freezed_annotation.dart';
import '../location/lat_lng.dart';

part 'navigation_task.freezed.dart';
part 'navigation_task.g.dart';

/// 导航任务状态
class NavigationTaskStatuses {
  static const String pending = 'pending';           // 待接受
  static const String accepted = 'accepted';         // 已接受
  static const String inProgress = 'in_progress';    // 导航中
  static const String completed = 'completed';       // 已完成
  static const String cancelled = 'cancelled';       // 已取消
  static const String rejected = 'rejected';         // 已拒绝
}

/// 导航任务数据模型
///
/// 用于发送者分享路线给接收者，接收者可以查看并开始导航
@freezed
abstract class NavigationTask with _$NavigationTask {
  const factory NavigationTask({
    required String id,                    // 任务 ID
    required String senderId,              // 发送者 ID
    required String receiverId,            // 接收者 ID
    required String senderName,            // 发送者昵称
    required String receiverName,          // 接收者昵称

    // 起点信息
    required String originName,            // 起点名称
    required double originLat,
    required double originLng,

    // 终点信息
    required String destinationName,       // 终点名称
    required double destinationLat,
    required double destinationLng,

    // 路线信息
    required List<LatLng> routePoints,     // 路线坐标点列表
    required double distance,              // 总距离（米）
    required int duration,                 // 预计时长（秒）
    required String strategy,              // 路线策略

    // 状态和时间
    @Default(NavigationTaskStatuses.pending) String status,
    required DateTime createdAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,

    // 备注
    String? note,                          // 发送者备注
  }) = _NavigationTask;

  factory NavigationTask.fromJson(Map<String, dynamic> json) =>
      _$NavigationTaskFromJson(json);
}

/// 导航任务列表（用于 API 响应）
@freezed
abstract class NavigationTaskList with _$NavigationTaskList {
  const factory NavigationTaskList({
    required List<NavigationTask> tasks,
    required int total,
  }) = _NavigationTaskList;

  factory NavigationTaskList.fromJson(Map<String, dynamic> json) =>
      _$NavigationTaskListFromJson(json);
}
