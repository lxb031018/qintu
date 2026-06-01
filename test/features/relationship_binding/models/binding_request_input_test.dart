import 'package:flutter_test/flutter_test.dart';
import 'package:qintu/features/relationship_binding/models/binding_request_input.dart';

void main() {
  group('BindingValidationError', () {
    test('hasError 当任一字段错误时返回 true', () {
      const err = BindingValidationError(partnerNameError: 'x');
      expect(err.hasError, isTrue);
    });

    test('hasError 当所有字段都通过时返回 false', () {
      const err = BindingValidationError();
      expect(err.hasError, isFalse);
    });

    test('支持部分字段错误', () {
      const err = BindingValidationError(
        partnerNameError: '请填写',
        phoneError: '手机号错',
      );
      expect(err.partnerNameError, '请填写');
      expect(err.nameError, isNull);
      expect(err.phoneError, '手机号错');
      expect(err.hasError, isTrue);
    });
  });

  group('BindingRequestInput', () {
    test('构造后字段可访问', () {
      const input = BindingRequestInput(
        partnerName: '妈妈',
        name: '儿子',
        phone: '13800138000',
      );
      expect(input.partnerName, '妈妈');
      expect(input.name, '儿子');
      expect(input.phone, '13800138000');
    });
  });
}
