import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_response.dart';
import '../utils/logger.dart';

/// API Service - All backend API calls
///
/// Refactored (2026-04-05):
/// - Unified request wrapper methods, reducing 70% duplicate error handling code
/// - Unified logging format
/// - Simplified API call approach
class ApiService {
  /// Cloud function base URL
  final String baseUrl;

  /// User openid
  final String openid;

  /// HTTP client
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    required this.openid,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Get common request headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-User-OpenID': openid,
      };

  // ==================== Unified Request Wrapper Methods ====================

  /// Unified POST request wrapper
  ///
  /// Auto handles:
  /// - JSON encoding/decoding
  /// - Error handling (ApiException)
  /// - Logging
  ///
  /// [endpoint] API endpoint (e.g. '/api/users/sync')
  /// [body] Request body (will be JSON encoded automatically)
  /// [errorCode] Error code prefix (e.g. 'SYNC' will generate 'SYNC_FAILED')
  /// [errorMessage] Default error message
  Future<ApiResponse<Map<String, dynamic>>> _postRequest({
    required String endpoint,
    Map<String, dynamic>? body,
    required String errorCode,
    String? errorMessage,
  }) async {
    final url = '$baseUrl$endpoint';
    Logs.api.info('API Request: POST $url');

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      }

      throw ApiException(
        code: data['code'] ?? '${errorCode}_FAILED',
        message: data['message'] ?? errorMessage ?? 'Request failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        Logs.api.error('API Request Failed: ${e.code} - ${e.message}');
        rethrow;
      }
      Logs.api.error('API Request Exception: $e');
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Network connection failed: $e',
        originalError: e,
      );
    }
  }

  /// Unified GET request wrapper
  Future<ApiResponse<Map<String, dynamic>>> _getRequest({
    required String endpoint,
    required String errorCode,
    String? errorMessage,
  }) async {
    final url = '$baseUrl$endpoint';
    Logs.api.info('API Request: GET $url');

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      }

      throw ApiException(
        code: data['code'] ?? '${errorCode}_FAILED',
        message: data['message'] ?? errorMessage ?? 'Request failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        Logs.api.error('API Request Failed: ${e.code} - ${e.message}');
        rethrow;
      }
      Logs.api.error('API Request Exception: $e');
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Network connection failed: $e',
        originalError: e,
      );
    }
  }

  /// Unified PUT request wrapper
  Future<ApiResponse<Map<String, dynamic>>> _putRequest({
    required String endpoint,
    Map<String, dynamic>? body,
    required String errorCode,
    String? errorMessage,
  }) async {
    final url = '$baseUrl$endpoint';
    Logs.api.info('API Request: PUT $url');

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      }

      throw ApiException(
        code: data['code'] ?? '${errorCode}_FAILED',
        message: data['message'] ?? errorMessage ?? 'Request failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        Logs.api.error('API Request Failed: ${e.code} - ${e.message}');
        rethrow;
      }
      Logs.api.error('API Request Exception: $e');
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Network connection failed: $e',
        originalError: e,
      );
    }
  }

  /// Unified DELETE request wrapper
  Future<ApiResponse<Map<String, dynamic>>> _deleteRequest({
    required String endpoint,
    Map<String, dynamic>? body,
    required String errorCode,
    String? errorMessage,
  }) async {
    final url = '$baseUrl$endpoint';
    Logs.api.info('API Request: DELETE $url');

    try {
      final request = http.Request('DELETE', Uri.parse(url));
      request.headers.addAll(_headers);
      if (body != null) {
        request.body = jsonEncode(body);
      }

      final response = await http.Response.fromStream(
        await _client.send(request),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>.fromJson(data);
      }

      throw ApiException(
        code: data['code'] ?? '${errorCode}_FAILED',
        message: data['message'] ?? errorMessage ?? 'Request failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        Logs.api.error('API Request Failed: ${e.code} - ${e.message}');
        rethrow;
      }
      Logs.api.error('API Request Exception: $e');
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Network connection failed: $e',
        originalError: e,
      );
    }
  }

  // ==================== User Management ====================

  /// Sync user (called on login, ensures record exists in MySQL)
  Future<ApiResponse<Map<String, dynamic>>> syncUser({
    required String openid,
    String? phone,
    String? nickname,
  }) async {
    return _postRequest(
      endpoint: '/api/users/sync',
      body: {
        'openid': openid,
        'phone': phone,
        'nickname': nickname,
      },
      errorCode: 'SYNC',
      errorMessage: 'Sync failed',
    );
  }

  /// Register user
  Future<ApiResponse<Map<String, dynamic>>> registerUser({
    required String openid,
    String? phone,
    String? nickname,
    String userType = 'both',
  }) async {
    return _postRequest(
      endpoint: '/api/users/register',
      body: {
        'openid': openid,
        'phone': phone,
        'nickname': nickname,
        'user_type': userType,
      },
      errorCode: 'REGISTER',
      errorMessage: 'Registration failed',
    );
  }

  /// Get current user info
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    return _getRequest(
      endpoint: '/api/users/me',
      errorCode: 'GET_USER',
      errorMessage: 'Failed to get user info',
    );
  }

  /// Update user info
  Future<ApiResponse<Map<String, dynamic>>> updateUser({
    String? nickname,
    String? userType,
  }) async {
    return _putRequest(
      endpoint: '/api/users/me',
      body: {
        'nickname': nickname,
        'user_type': userType,
      },
      errorCode: 'UPDATE_USER',
      errorMessage: 'Failed to update user info',
    );
  }

  // ==================== Binding Management ====================

  /// Generate bind code
  Future<ApiResponse<Map<String, dynamic>>> generateBindCode({
    String? receiverPhone,
    String? remark,
  }) async {
    return _postRequest(
      endpoint: '/api/bindings/generate',
      body: {
        'receiver_phone': receiverPhone,
        'remark': remark,
      },
      errorCode: 'GENERATE_CODE',
      errorMessage: 'Failed to generate bind code',
    );
  }

  /// Confirm binding (receiver enters bind code)
  Future<ApiResponse<Map<String, dynamic>>> confirmBinding({
    required String bindCode,
  }) async {
    return _postRequest(
      endpoint: '/api/bindings/confirm',
      body: {
        'bind_code': bindCode.toUpperCase(),
      },
      errorCode: 'CONFIRM_BINDING',
      errorMessage: 'Failed to confirm binding',
    );
  }

  /// Get my bindings list
  Future<ApiResponse<Map<String, dynamic>>> getMyBindings() async {
    return _getRequest(
      endpoint: '/api/bindings/my',
      errorCode: 'GET_BINDINGS',
      errorMessage: 'Failed to get bindings',
    );
  }

  /// Revoke binding
  Future<ApiResponse<Map<String, dynamic>>> revokeBinding(int bindingId) async {
    return _deleteRequest(
      endpoint: '/api/bindings/$bindingId',
      errorCode: 'REVOKE_BINDING',
      errorMessage: 'Failed to revoke binding',
    );
  }

  // ==================== Navigation Task Management ====================

  /// Create navigation task
  Future<ApiResponse<Map<String, dynamic>>> createNavigationTask({
    required String receiverOpenid,
    Map<String, dynamic>? startPoint,
    required Map<String, dynamic> endPoint,
    required Map<String, dynamic> route,
    String transportMode = 'drive',
  }) async {
    return _postRequest(
      endpoint: '/api/tasks',
      body: {
        'receiver_openid': receiverOpenid,
        if (startPoint != null) ...startPoint,
        ...endPoint,
        ...route,
        'transport_mode': transportMode,
      },
      errorCode: 'CREATE_TASK',
      errorMessage: 'Failed to create navigation task',
    );
  }

  /// Get my tasks list
  Future<ApiResponse<Map<String, dynamic>>> getMyTasks({
    String status = 'active',
    int page = 1,
    int pageSize = 20,
  }) async {
    return _getRequest(
      endpoint: '/api/tasks/my?status=$status&page=$page&page_size=$pageSize',
      errorCode: 'GET_TASKS',
      errorMessage: 'Failed to get tasks',
    );
  }

  /// Accept task
  Future<ApiResponse<Map<String, dynamic>>> acceptTask(String taskId) async {
    return _postRequest(
      endpoint: '/api/tasks/$taskId/accept',
      errorCode: 'ACCEPT_TASK',
      errorMessage: 'Failed to accept task',
    );
  }

  /// Start task
  Future<ApiResponse<Map<String, dynamic>>> startTask(String taskId) async {
    return _postRequest(
      endpoint: '/api/tasks/$taskId/start',
      errorCode: 'START_TASK',
      errorMessage: 'Failed to start task',
    );
  }

  /// Complete task
  Future<ApiResponse<Map<String, dynamic>>> completeTask(String taskId) async {
    return _postRequest(
      endpoint: '/api/tasks/$taskId/complete',
      errorCode: 'COMPLETE_TASK',
      errorMessage: 'Failed to complete task',
    );
  }

  /// Cancel task
  Future<ApiResponse<Map<String, dynamic>>> cancelTask(String taskId) async {
    return _postRequest(
      endpoint: '/api/tasks/$taskId/cancel',
      errorCode: 'CANCEL_TASK',
      errorMessage: 'Failed to cancel task',
    );
  }

  // ==================== Location Sharing ====================

  /// Upload real-time location
  Future<ApiResponse<Map<String, dynamic>>> uploadLocation({
    required String taskId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
  }) async {
    return _postRequest(
      endpoint: '/api/locations',
      body: {
        'task_id': taskId,
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'heading': heading,
      },
      errorCode: 'UPLOAD_LOCATION',
      errorMessage: 'Failed to upload location',
    );
  }

  /// Get task real-time location
  Future<ApiResponse<Map<String, dynamic>>> getTaskLocation(String taskId) async {
    return _getRequest(
      endpoint: '/api/locations/$taskId',
      errorCode: 'GET_LOCATION',
      errorMessage: 'Failed to get location',
    );
  }

  /// Enable location sharing
  Future<ApiResponse<Map<String, dynamic>>> enableLocationSharing(String taskId) async {
    return _postRequest(
      endpoint: '/api/locations/$taskId/enable',
      errorCode: 'ENABLE_LOCATION',
      errorMessage: 'Failed to enable location sharing',
    );
  }

  /// Disable location sharing
  Future<ApiResponse<Map<String, dynamic>>> disableLocationSharing(String taskId) async {
    return _postRequest(
      endpoint: '/api/locations/$taskId/disable',
      errorCode: 'DISABLE_LOCATION',
      errorMessage: 'Failed to disable location sharing',
    );
  }

  /// Release HTTP client resources
  void dispose() {
    _client.close();
  }
}
