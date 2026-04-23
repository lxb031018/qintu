import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qintu/models/async_state.dart';
import 'package:qintu/providers/binding_provider.dart';

void main() {
  group('BindingNotifier', () {
    late BindingNotifier bindingProvider;

    setUpAll(() async {
      // 加载 .env 文件（ApiClient 初始化需要）
      await dotenv.load(fileName: ".env");
    });

    setUp(() {
      bindingProvider = BindingNotifier();
    });

    tearDown(() {
      bindingProvider.dispose();
    });

    test('初始状态应该是 AsyncInitial', () {
      expect(bindingProvider.state.bindingsState, isA<AsyncInitial>());
      expect(bindingProvider.bindings, isEmpty);
      expect(bindingProvider.bindingSummary, isNull);
    });

    test('isLoading 初始值应该是 false', () {
      expect(bindingProvider.isLoading, isFalse);
    });

    test('error 初始值应该是 null', () {
      expect(bindingProvider.error, isNull);
    });

    test('totalBindings 初始值应该是 0', () {
      expect(bindingProvider.totalBindings, 0);
    });

    test('isBindingLimitReached 初始值应该是 false', () {
      expect(bindingProvider.isBindingLimitReached, isFalse);
    });

    test('hasActiveBindings 初始值应该是 false', () {
      expect(bindingProvider.hasActiveBindings, isFalse);
    });

    test('allBindings 初始值应该是空列表', () {
      expect(bindingProvider.allBindings, isEmpty);
    });

    test('clearError 在没有错误时不应该改变状态', () {
      bindingProvider.clearError();
      expect(bindingProvider.error, isNull);
    });
  });
}
