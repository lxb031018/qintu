import 'package:qintu/core/http/api_client.dart';
import 'package:qintu/core/http/api_response.dart';
import 'package:qintu/constants/api_endpoints.dart';
import 'package:qintu/utils/logger.dart';

/// ============================================
/// 导航任务服务 - 负责导航任务的创建、分享、接收和管理
///
/// 业务流程：
/// 1. 发送者规划路线后，创建导航任务并分享给接收者
/// 2. 接收者收到通知，可以查看、接受或拒绝
/// 3. 接受后，接收者可以开始实时导航（后续通过原生桥接实现）
/// ============================================

class NavigationTaskService {
  static final NavigationTaskService _instance = NavigationTaskService._internal();
  factory NavigationTaskService() => _instance;
  NavigationTaskService._internal();

  static NavigationTaskService get instance => _instance;

  final ApiClient _apiClient = ApiClient();

  // ==================== 创建任务 ====================

  /// 创建导航任务并分享给绑定对象
  /// 
  /// 注意：参数命名与后端保持一致（snake_case）
  Future<ApiResponse<Map<String, dynamic>>> createTask({
    required String receiverOpenid,        // 后端: receiver_openid
    required String senderName,
    required String receiverName,
    required String originName,            // 后端: start_name
    required double originLat,             // 后端: start_latitude
    required double originLng,             // 后端: start_longitude
    required String destinationName,       // 后端: end_name
    required double destinationLat,        // 后端: end_latitude
    required double destinationLng,        // 后端: end_longitude
    required List<Map<String, dynamic>> routeData,  // 后端: route_data (JSON)
    required double distance,              // 后端: distance_meters
    required int duration,                 // 后端: duration_seconds
    required Map<String, dynamic> routeSummary,     // 后端: route_summary (JSON)
    String? note,
  }) async {
    try {
      Logs.app.info('📤 创建导航任务: $originName → $destinationName');
      Logs.app.info('   接收者: $receiverName ($receiverOpenid)');
      Logs.app.info('   距离: ${distance ~/ 1000}km, 预计: ${duration ~/ 60}分钟');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.createTask,
        data: {
          'receiver_openid': receiverOpenid,
          'start_name': originName,
          'start_latitude': originLat,
          'start_longitude': originLng,
          'end_name': destinationName,
          'end_latitude': destinationLat,
          'end_longitude': destinationLng,
          'route_data': routeData,
          'route_summary': routeSummary,
          'transport_mode': 'driving',
          'distance_meters': distance,
          'duration_seconds': duration,
          'sender_name': senderName,
          'receiver_name': receiverName,
          ...note != null ? {'note': note} : {},
        },
      );

      if (response.success) {
        Logs.app.info('✅ 导航任务创建成功');
      } else {
        Logs.app.warning('❌ 导航任务创建失败: ${response.message}');
      }
      
      return response;
    } catch (e) {
      Logs.app.error('❌ 创建导航任务异常: $e');
      rethrow;
    }
  }

  // ==================== 查询任务 ====================

  /// 获取我发送的任务列表
  Future<ApiResponse<Map<String, dynamic>>> getSentTasks({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getMyTasks,
        queryParameters: {
          'role': 'sender',
          'page': page,
          'pageSize': pageSize,
        },
      );

      return response;
    } catch (e) {
      Logs.app.error('获取发送任务列表失败: $e');
      rethrow;
    }
  }

  /// 获取我接收的任务列表
  Future<ApiResponse<Map<String, dynamic>>> getReceivedTasks({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getMyTasks,
        queryParameters: {
          'role': 'receiver',
          'page': page,
          'pageSize': pageSize,
        },
      );

      return response;
    } catch (e) {
      Logs.app.error('获取接收任务列表失败: $e');
      rethrow;
    }
  }

  /// 获取任务详情
  Future<ApiResponse<Map<String, dynamic>>> getTaskDetail(String taskId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.getTask}/$taskId',
      );

      return response;
    } catch (e) {
      Logs.app.error('获取任务详情失败: $e');
      rethrow;
    }
  }

  // ==================== 任务操作 ====================

  /// 接受任务
  Future<ApiResponse<Map<String, dynamic>>> acceptTask(String taskId) async {
    try {
      Logs.app.info('✅ 接受任务: $taskId');
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiEndpoints.acceptTask}/$taskId/accept',
      );

      if (response.success) {
        Logs.app.info('✅ 任务接受成功');
      }
      
      return response;
    } catch (e) {
      Logs.app.error('接受任务失败: $e');
      rethrow;
    }
  }

  /// 拒绝任务
  Future<ApiResponse<void>> rejectTask(String taskId, {String? reason}) async {
    try {
      Logs.app.info('❌ 拒绝任务: $taskId');
      final response = await _apiClient.post<void>(
        '${ApiEndpoints.rejectTask}/$taskId/reject',
        data: reason != null ? {'reason': reason} : null,
      );

      if (response.success) {
        Logs.app.info('✅ 任务已拒绝');
      }
      
      return response;
    } catch (e) {
      Logs.app.error('拒绝任务失败: $e');
      rethrow;
    }
  }

  /// 取消任务（发送者）
  Future<ApiResponse<void>> cancelTask(String taskId) async {
    try {
      Logs.app.info('🚫 取消任务: $taskId');
      final response = await _apiClient.post<void>(
        '${ApiEndpoints.cancelTask}/$taskId/cancel',
      );

      if (response.success) {
        Logs.app.info('✅ 任务已取消');
      }
      
      return response;
    } catch (e) {
      Logs.app.error('取消任务失败: $e');
      rethrow;
    }
  }

  /// 完成任务
  Future<ApiResponse<Map<String, dynamic>>> completeTask(String taskId) async {
    try {
      Logs.app.info('🏁 完成任务: $taskId');
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiEndpoints.completeTask}/$taskId/complete',
      );

      if (response.success) {
        Logs.app.info('✅ 任务已完成');
      }
      
      return response;
    } catch (e) {
      Logs.app.error('完成任务失败: $e');
      rethrow;
    }
  }

  // ==================== 辅助方法 ====================

  /// 检查是否有新的导航任务（用于轮询）
  Future<bool> hasNewTasks() async {
    try {
      final response = await getReceivedTasks(page: 1, pageSize: 1);
      return response.success && response.data != null && response.data!.isNotEmpty;
    } catch (e) {
      Logs.app.warning('检查新任务失败: $e');
      return false;
    }
  }
}
