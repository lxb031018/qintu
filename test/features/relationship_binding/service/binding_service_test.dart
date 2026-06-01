import 'package:flutter_test/flutter_test.dart';
import 'package:qintu/features/relationship_binding/core/binding_api.dart';
import 'package:qintu/features/relationship_binding/models/binding_request_input.dart';
import 'package:qintu/features/relationship_binding/service/binding_service.dart';
import 'package:qintu/models/binding/binding.dart';

/// 测试用 mock api
class _MockBindingApi implements BindingApi {
  String? lastReceiverPhone;
  String? lastSenderName;
  String? lastReceiverName;
  String? lastPartnerUserId;
  bool throwOnRequest = false;
  bool throwOnConfirm = false;

  @override
  Future<void> requestPhoneBinding({
    required String receiverPhone,
    String? senderName,
    String? receiverName,
  }) async {
    lastReceiverPhone = receiverPhone;
    lastSenderName = senderName;
    lastReceiverName = receiverName;
    if (throwOnRequest) throw Exception('api error');
  }

  @override
  Future<void> confirmRequest(String partnerUserId) async {
    lastPartnerUserId = partnerUserId;
    if (throwOnConfirm) throw Exception('confirm error');
  }

  @override
  Future<void> rejectRequest(String partnerUserId) async =>
      throw UnimplementedError();

  @override
  Future<void> revokeBinding(String partnerUserId) async =>
      throw UnimplementedError();

  @override
  Future<void> modifyBindingName(String partnerUserId, String newName) async =>
      throw UnimplementedError();

  @override
  Future<void> cancelSentRequest(String partnerUserId) async =>
      throw UnimplementedError();

  @override
  Future<BindingList> getMyBindings() async => throw UnimplementedError();

  @override
  Future<List<PendingRequest>> getPendingRequests() async =>
      throw UnimplementedError();

  @override
  Future<List<SentRequest>> getSentRequests() async =>
      throw UnimplementedError();
}

void main() {
  group('BindingService.validateRequestInput', () {
    // P3-4: 用 mock api 注入避免真实 ApiClient 触发 dotenv 加载
    final service = BindingService(api: _MockBindingApi());

    test('字段全空时返回完整错误', () {
      const input = BindingRequestInput(
        partnerName: '',
        name: '',
        phone: '',
      );
      final err = service.validateRequestInput(input);
      expect(err, isNotNull);
      expect(err!.partnerNameError, isNotNull);
      expect(err.nameError, isNotNull);
      expect(err.phoneError, isNotNull);
    });

    test('字段全合法时返回 null', () {
      const input = BindingRequestInput(
        partnerName: '妈妈',
        name: '儿子',
        phone: '13800138000',
      );
      expect(service.validateRequestInput(input), isNull);
    });

    test('部分字段错时只返回对应错误', () {
      const input = BindingRequestInput(
        partnerName: '妈妈',
        name: '',
        phone: '13800138000',
      );
      final err = service.validateRequestInput(input);
      expect(err, isNotNull);
      expect(err!.partnerNameError, isNull);
      expect(err.nameError, isNotNull);
      expect(err.phoneError, isNull);
    });
  });

  group('BindingService.submitRequest', () {
    test('自动加 +86 前缀并映射字段名', () async {
      final mock = _MockBindingApi();
      final service = BindingService(api: mock);

      await service.submitRequest(const BindingRequestInput(
        partnerName: '妈妈',
        name: '儿子',
        phone: '13800138000',
      ));

      expect(mock.lastReceiverPhone, '+86 13800138000');
      expect(mock.lastReceiverName, '妈妈');
      expect(mock.lastSenderName, '儿子');
    });

    test('api 抛异常时向上传播', () async {
      final mock = _MockBindingApi()..throwOnRequest = true;
      final service = BindingService(api: mock);

      expect(
        () => service.submitRequest(const BindingRequestInput(
          partnerName: '妈妈',
          name: '儿子',
          phone: '13800138000',
        )),
        throwsException,
      );
    });
  });

  group('BindingService.confirm', () {
    test('把 partnerUserId 透传给 api', () async {
      final mock = _MockBindingApi();
      final service = BindingService(api: mock);

      await service.confirm('p-123');

      expect(mock.lastPartnerUserId, 'p-123');
    });
  });
}
