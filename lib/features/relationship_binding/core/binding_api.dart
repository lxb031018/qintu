import 'package:qintu/core/http/api_client.dart';
import 'package:qintu/models/binding/binding.dart';
import 'package:qintu/constants/api_endpoints.dart';
import 'package:qintu/utils/logger.dart';

/// ============================================
/// 绑定关系 API 层
///
/// 纯 HTTP 调用，返回数据模型，无 Flutter 依赖
/// ============================================

class BindingApi {
  final ApiClient _apiClient;

  BindingApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// 获取我的绑定列表
  Future<BindingList> getMyBindings() async {
    Logs.binding.info('API请求: GET ${ApiEndpoints.getMyBindings}');

    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.getMyBindings);

    if (response.isSuccessful && response.data != null) {
      final responseData = response.data!;
      final bindingData = responseData['data'] as Map<String, dynamic>? ?? responseData;
      Logs.binding.info('绑定列表获取成功');
      return BindingList.fromJson(bindingData);
    }

    throw Exception(response.message ?? '获取绑定列表失败');
  }

  /// 获取待确认的请求
  Future<List<PendingRequest>> getPendingRequests() async {
    Logs.binding.info('API请求: GET ${ApiEndpoints.getPendingRequests}');

    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.getPendingRequests);

    if (response.isSuccessful && response.data != null) {
      final responseData = response.data!;
      final requestsData = responseData['data'] as List<dynamic>? ?? [];
      Logs.binding.info('待确认请求获取成功: ${requestsData.length}');
      return requestsData
          .map((json) => PendingRequest.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception(response.message ?? '获取待确认请求失败');
  }

  /// 获取我发出的请求
  Future<List<SentRequest>> getSentRequests() async {
    Logs.binding.info('API请求: GET ${ApiEndpoints.getSentRequests}');

    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.getSentRequests);

    if (response.isSuccessful && response.data != null) {
      final responseData = response.data!;
      final requestsData = responseData['data'] as List<dynamic>? ?? [];
      Logs.binding.info('发出的请求获取成功: ${requestsData.length}');
      return requestsData
          .map((json) => SentRequest.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception(response.message ?? '获取发出的请求失败');
  }

  /// 发送手机号绑定请求
  Future<void> requestPhoneBinding({
    required String receiverPhone,
    String? senderName,
    String? receiverName,
  }) async {
    Logs.binding.info('API请求: POST ${ApiEndpoints.requestPhoneBinding}');
    Logs.binding.info('请求体: receiver_phone=$receiverPhone');

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.requestPhoneBinding,
      data: {
        'receiver_phone': receiverPhone,
        'sender_name': senderName,
        'receiver_name': receiverName,
      },
    );

    if (!response.isSuccessful) {
      throw Exception(response.message ?? '发送绑定请求失败');
    }

    Logs.binding.info('绑定请求发送成功');
  }

  /// 确认绑定请求
  Future<void> confirmRequest(int requestId) async {
    Logs.binding.info('API请求: POST ${ApiEndpoints.confirmRequest}');

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.confirmRequest,
      data: {'request_id': requestId},
    );

    if (!response.isSuccessful) {
      throw Exception(response.message ?? '确认绑定请求失败');
    }

    Logs.binding.info('确认绑定请求成功');
  }

  /// 拒绝绑定请求
  Future<void> rejectRequest(int requestId) async {
    Logs.binding.info('API请求: POST ${ApiEndpoints.rejectRequest}');

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.rejectRequest,
      data: {'request_id': requestId},
    );

    if (!response.isSuccessful) {
      throw Exception(response.message ?? '拒绝绑定请求失败');
    }

    Logs.binding.info('拒绝绑定请求成功');
  }

  /// 解除绑定
  Future<void> revokeBinding(int bindingId) async {
    Logs.binding.info('API请求: DELETE ${ApiEndpoints.revokeBinding}/$bindingId');

    final response = await _apiClient.delete<Map<String, dynamic>>(
      '${ApiEndpoints.revokeBinding}/$bindingId',
    );

    if (!response.isSuccessful) {
      throw Exception(response.message ?? '解除绑定失败');
    }

    Logs.binding.info('解除绑定成功');
  }

  /// 取消发出的请求
  Future<void> cancelSentRequest(int requestId) async {
    Logs.binding.info('API请求: DELETE ${ApiEndpoints.cancelSentRequest(requestId)}');

    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.cancelSentRequest(requestId),
    );

    if (!response.isSuccessful) {
      throw Exception(response.message ?? '取消请求失败');
    }

    Logs.binding.info('取消请求成功');
  }
}
