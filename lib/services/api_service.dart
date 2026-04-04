import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_response.dart';

/// API Service - 所有后端接口调用
class ApiService {
  /// 云函数基础 URL
  final String baseUrl;
  
  /// 用户 openid
  final String openid;
  
  /// HTTP 客户端
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    required this.openid,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// 获取通用请求头
  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'X-User-OpenID': openid,
  };

  // ==================== 用户管理 ====================

  /// 用户同步（登录时调用，确保 MySQL 中存在记录）
  Future<ApiResponse<Map<String, dynamic>>> syncUser({
    required String openid,
    String? phone,
    String? nickname,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/users/sync'),
        headers: _headers,
        body: jsonEncode({
          'openid': openid,
          if (phone != null) 'phone': phone,
          if (nickname != null) 'nickname': nickname,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'SYNC_FAILED',
          message: data['message'] ?? '同步失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 用户注册
  Future<ApiResponse<Map<String, dynamic>>> registerUser({
    required String openid,
    String? phone,
    String? nickname,
    String userType = 'both',
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/users/register'),
        headers: _headers,
        body: jsonEncode({
          'openid': openid,
          if (phone != null) 'phone': phone,
          if (nickname != null) 'nickname': nickname,
          'user_type': userType,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'REGISTER_FAILED',
          message: data['message'] ?? '注册失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 获取当前用户信息
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/users/me'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'GET_USER_FAILED',
          message: data['message'] ?? '获取用户信息失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 更新用户信息
  Future<ApiResponse<Map<String, dynamic>>> updateUser({
    String? nickname,
    String? userType,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/api/users/me'),
        headers: _headers,
        body: jsonEncode({
          if (nickname != null) 'nickname': nickname,
          if (userType != null) 'user_type': userType,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'UPDATE_USER_FAILED',
          message: data['message'] ?? '更新用户信息失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  // ==================== 绑定关系管理 ====================

  /// 生成绑定码
  Future<ApiResponse<Map<String, dynamic>>> generateBindCode({
    String? receiverPhone,
    String? remark,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/bindings/generate'),
        headers: _headers,
        body: jsonEncode({
          if (receiverPhone != null) 'receiver_phone': receiverPhone,
          if (remark != null) 'remark': remark,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'GENERATE_CODE_FAILED',
          message: data['message'] ?? '生成绑定码失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 确认绑定（接收者输入绑定码）
  Future<ApiResponse<Map<String, dynamic>>> confirmBinding({
    required String bindCode,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/bindings/confirm'),
        headers: _headers,
        body: jsonEncode({
          'bind_code': bindCode.toUpperCase(),
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'CONFIRM_BINDING_FAILED',
          message: data['message'] ?? '确认绑定失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 获取我的绑定关系列表
  Future<ApiResponse<Map<String, dynamic>>> getMyBindings() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/bindings/my'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'GET_BINDINGS_FAILED',
          message: data['message'] ?? '获取绑定关系失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 解除绑定
  Future<ApiResponse<Map<String, dynamic>>> revokeBinding(int bindingId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/api/bindings/$bindingId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'REVOKE_BINDING_FAILED',
          message: data['message'] ?? '解除绑定失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 检查绑定码是否有效
  Future<ApiResponse<Map<String, dynamic>>> checkBindCode(String bindCode) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/bindings/check/$bindCode'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'CHECK_CODE_FAILED',
          message: data['message'] ?? '检查绑定码失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 通过手机号请求绑定（发送者端）
  Future<ApiResponse<Map<String, dynamic>>> requestBindingByPhone({
    required String receiverPhone,
    String? remark,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/bindings/request-phone'),
        headers: _headers,
        body: jsonEncode({
          'receiver_phone': receiverPhone,
          if (remark != null) 'remark': remark,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'REQUEST_BINDING_FAILED',
          message: data['message'] ?? '发送绑定请求失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 获取待确认的绑定请求列表（接收者端）
  Future<ApiResponse<Map<String, dynamic>>> getPendingBindingRequests() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/bindings/pending'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'GET_PENDING_REQUESTS_FAILED',
          message: data['message'] ?? '获取绑定请求列表失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 确认绑定请求（接收者端）
  Future<ApiResponse<Map<String, dynamic>>> confirmBindingRequest({
    required String requestId,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/bindings/confirm-request'),
        headers: _headers,
        body: jsonEncode({
          'request_id': requestId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'CONFIRM_REQUEST_FAILED',
          message: data['message'] ?? '确认绑定请求失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 拒绝绑定请求（接收者端）
  Future<ApiResponse<Map<String, dynamic>>> rejectBindingRequest({
    required String requestId,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/bindings/reject-request'),
        headers: _headers,
        body: jsonEncode({
          'request_id': requestId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'REJECT_REQUEST_FAILED',
          message: data['message'] ?? '拒绝绑定请求失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  // ==================== 导航任务管理 ====================

  /// 创建导航任务
  Future<ApiResponse<Map<String, dynamic>>> createNavigationTask({
    required String receiverOpenid,
    String? startName,
    double? startLatitude,
    double? startLongitude,
    String? startAddress,
    required String endName,
    required double endLatitude,
    required double endLongitude,
    String? endAddress,
    required Map<String, dynamic> routeData,
    Map<String, dynamic>? routeSummary,
    String transportMode = 'drive',
    int? distanceMeters,
    int? durationSeconds,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/tasks'),
        headers: _headers,
        body: jsonEncode({
          'receiver_openid': receiverOpenid,
          if (startName != null) 'start_name': startName,
          if (startLatitude != null) 'start_latitude': startLatitude,
          if (startLongitude != null) 'start_longitude': startLongitude,
          if (startAddress != null) 'start_address': startAddress,
          'end_name': endName,
          'end_latitude': endLatitude,
          'end_longitude': endLongitude,
          if (endAddress != null) 'end_address': endAddress,
          'route_data': routeData,
          if (routeSummary != null) 'route_summary': routeSummary,
          'transport_mode': transportMode,
          if (distanceMeters != null) 'distance_meters': distanceMeters,
          if (durationSeconds != null) 'duration_seconds': durationSeconds,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'CREATE_TASK_FAILED',
          message: data['message'] ?? '创建导航任务失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 获取我的任务列表
  Future<ApiResponse<Map<String, dynamic>>> getMyTasks({
    String? role,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (role != null) 'role': role,
        if (status != null) 'status': status,
      };

      final uri = Uri.parse('$baseUrl/api/tasks/my').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _headers);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'GET_TASKS_FAILED',
          message: data['message'] ?? '获取任务列表失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 获取待处理任务（接收者专用）
  Future<ApiResponse<Map<String, dynamic>>> getPendingTasks() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/tasks/pending'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'GET_PENDING_FAILED',
          message: data['message'] ?? '获取待处理任务失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 获取任务详情
  Future<ApiResponse<Map<String, dynamic>>> getTaskDetail(String taskId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/tasks/$taskId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'GET_TASK_FAILED',
          message: data['message'] ?? '获取任务详情失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 接受任务
  Future<ApiResponse<Map<String, dynamic>>> acceptTask(String taskId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/tasks/$taskId/accept'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'ACCEPT_TASK_FAILED',
          message: data['message'] ?? '接受任务失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 开始导航
  Future<ApiResponse<Map<String, dynamic>>> startTask(String taskId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/tasks/$taskId/start'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'START_NAV_FAILED',
          message: data['message'] ?? '开始导航失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 完成任务
  Future<ApiResponse<Map<String, dynamic>>> finishTask(String taskId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/tasks/$taskId/finish'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'FINISH_TASK_FAILED',
          message: data['message'] ?? '完成任务失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 取消任务
  Future<ApiResponse<Map<String, dynamic>>> cancelTask({
    required String taskId,
    String? reason,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/tasks/$taskId/cancel'),
        headers: _headers,
        body: jsonEncode({
          if (reason != null) 'reason': reason,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'CANCEL_TASK_FAILED',
          message: data['message'] ?? '取消任务失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 更新路线（发送者中途修改路线）
  Future<ApiResponse<Map<String, dynamic>>> updateTaskRoute({
    required String taskId,
    required Map<String, dynamic> routeData,
    Map<String, dynamic>? routeSummary,
    int? distanceMeters,
    int? durationSeconds,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/api/tasks/$taskId/route'),
        headers: _headers,
        body: jsonEncode({
          'route_data': routeData,
          if (routeSummary != null) 'route_summary': routeSummary,
          if (distanceMeters != null) 'distance_meters': distanceMeters,
          if (durationSeconds != null) 'duration_seconds': durationSeconds,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'UPDATE_ROUTE_FAILED',
          message: data['message'] ?? '更新路线失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  // ==================== 实时位置管理 ====================

  /// 更新位置（接收者上传位置）
  Future<ApiResponse<Map<String, dynamic>>> updateLocation({
    String? taskId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    double? bearing,
    double? altitude,
    bool isNavigating = true,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/locations/update'),
        headers: _headers,
        body: jsonEncode({
          if (taskId != null) 'task_id': taskId,
          'latitude': latitude,
          'longitude': longitude,
          if (accuracy != null) 'accuracy': accuracy,
          if (speed != null) 'speed': speed,
          if (bearing != null) 'bearing': bearing,
          if (altitude != null) 'altitude': altitude,
          'is_navigating': isNavigating,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'UPDATE_LOCATION_FAILED',
          message: data['message'] ?? '更新位置失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 查询接收者的位置（发送者查看）
  Future<ApiResponse<Map<String, dynamic>>> getLocation(String receiverOpenid) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/locations/$receiverOpenid'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'GET_LOCATION_FAILED',
          message: data['message'] ?? '查询位置失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 切换位置共享状态
  Future<ApiResponse<Map<String, dynamic>>> toggleLocationSharing({
    required bool isSharing,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/locations/sharing/toggle'),
        headers: _headers,
        body: jsonEncode({
          'is_sharing': isSharing,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      } else {
        throw ApiException(
          code: data['code'] ?? 'TOGGLE_SHARING_FAILED',
          message: data['message'] ?? '切换位置共享失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: '网络连接失败: $e',
        originalError: e,
      );
    }
  }

  /// 释放资源
  void dispose() {
    _client.close();
  }
}
