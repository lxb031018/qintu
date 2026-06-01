import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/models/async_state.dart';
import 'package:qintu/features/relationship_binding/provider/binding_notifier.dart';
import 'package:qintu/features/relationship_binding/models/binding_request_input.dart';
import 'package:qintu/features/relationship_binding/service/binding_service.dart';
import 'package:qintu/features/relationship_binding/core/binding_api.dart';
import 'package:qintu/models/binding/binding.dart';

/// 测试用 mock api
class _MockBindingApi implements BindingApi {
  @override
  Future<BindingList> getMyBindings() async => throw UnimplementedError();
  @override
  Future<List<PendingRequest>> getPendingRequests() async =>
      throw UnimplementedError();
  @override
  Future<List<SentRequest>> getSentRequests() async =>
      throw UnimplementedError();
  @override
  Future<void> requestPhoneBinding({
    required String receiverPhone,
    String? senderName,
    String? receiverName,
  }) async =>
      throw UnimplementedError();
  @override
  Future<void> confirmRequest(String partnerUserId) async =>
      throw UnimplementedError();
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
}

void main() {
  late ProviderContainer container;

  setUp(() {
    // P3-2/P3-4: 注入 mock api 避免构造真实 ApiClient（不需要 dotenv）
    container = ProviderContainer(overrides: [
      bindingServiceProvider.overrideWithValue(BindingService(api: _MockBindingApi())),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  group('BindingNotifier 初始状态', () {
    test('state.bindingsState 应该是 AsyncInitial', () {
      expect(container.read(bindingProvider).bindingsState, isA<AsyncInitial>());
    });

    test('bindings getter 应该是空列表', () {
      expect(container.read(bindingProvider.notifier).bindings, isEmpty);
    });

    test('bindingSummary 初始应该是 null', () {
      expect(container.read(bindingProvider.notifier).bindingSummary, isNull);
    });

    test('isLoading 初始应该是 false', () {
      expect(container.read(bindingProvider.notifier).isLoading, isFalse);
    });

    test('error 初始应该是 null', () {
      expect(container.read(bindingProvider.notifier).error, isNull);
    });

    test('totalBindings 初始应该是 0', () {
      expect(container.read(bindingProvider.notifier).totalBindings, 0);
    });

    test('isBindingLimitReached 初始应该是 false', () {
      expect(container.read(bindingProvider.notifier).isBindingLimitReached, isFalse);
    });

    test('hasActiveBindings 初始应该是 false', () {
      expect(container.read(bindingProvider.notifier).hasActiveBindings, isFalse);
    });

    test('bindings 初始应该是空列表', () {
      // P0-4: 之前 allBindings 与 bindings 重复，统一使用 bindings
      expect(container.read(bindingProvider.notifier).bindings, isEmpty);
    });

    test('clearError 在没有错误时不应该改变 state', () {
      container.read(bindingProvider.notifier).clearError();
      expect(container.read(bindingProvider.notifier).error, isNull);
    });
  });

  group('BindingNotifier.validateRequestInput', () {
    test('全部字段为空时应返回 hasError=true 的 BindingValidationError', () {
      const input = BindingRequestInput(
        partnerName: '',
        name: '',
        phone: '',
      );
      final error =
          container.read(bindingProvider.notifier).validateRequestInput(input);
      expect(error, isNotNull);
      expect(error!.hasError, isTrue);
      expect(error.partnerNameError, isNotNull);
      expect(error.nameError, isNotNull);
      expect(error.phoneError, isNotNull);
    });

    test('全部字段合法时应返回 null', () {
      const input = BindingRequestInput(
        partnerName: '妈妈',
        name: '儿子',
        phone: '13800138000',
      );
      final error =
          container.read(bindingProvider.notifier).validateRequestInput(input);
      expect(error, isNull);
    });

    test('手机号格式错误时只有 phoneError', () {
      const input = BindingRequestInput(
        partnerName: '妈妈',
        name: '儿子',
        phone: '12345',
      );
      final error =
          container.read(bindingProvider.notifier).validateRequestInput(input);
      expect(error, isNotNull);
      expect(error!.phoneError, isNotNull);
      expect(error.partnerNameError, isNull);
      expect(error.nameError, isNull);
    });
  });
}
