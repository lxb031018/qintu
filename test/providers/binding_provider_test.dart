import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qintu/models/async_state.dart';
import 'package:qintu/providers/binding_provider.dart';

void main() {
  group('BindingProvider', () {
    late BindingProvider bindingProvider;

    setUpAll(() async {
      // 加载 .env 文件（ApiClient 初始化需要）
      await dotenv.load(fileName: ".env");
    });

    setUp(() {
      bindingProvider = BindingProvider();
    });

    tearDown(() {
      bindingProvider.dispose();
    });

    test('初始状态应该是 AsyncInitial', () {
      expect(bindingProvider.bindingsState, isA<AsyncInitial>());
      expect(bindingProvider.bindings, isEmpty);
      expect(bindingProvider.bindingSummary, isNull);
    });

    test('isLoading 初始值应该是 false', () {
      expect(bindingProvider.isLoading, isFalse);
    });

    test('error 初始值应该是 null', () {
      expect(bindingProvider.error, isNull);
    });

    test('asSenderCount 和 asReceiverCount 初始值应该是 0', () {
      expect(bindingProvider.asSenderCount, 0);
      expect(bindingProvider.asReceiverCount, 0);
    });

    test('isSenderLimitReached 和 isReceiverLimitReached 初始值应该是 false', () {
      expect(bindingProvider.isSenderLimitReached, isFalse);
      expect(bindingProvider.isReceiverLimitReached, isFalse);
    });

    test('hasActiveBindings 初始值应该是 false', () {
      expect(bindingProvider.hasActiveBindings, isFalse);
    });

    test('senderBindings 和 receiverBindings 初始值应该是空列表', () {
      expect(bindingProvider.senderBindings, isEmpty);
      expect(bindingProvider.receiverBindings, isEmpty);
    });

    test('clearError 在没有错误时不应该改变状态', () {
      bindingProvider.clearError();
      expect(bindingProvider.error, isNull);
    });
  });
}
