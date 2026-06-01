import 'package:flutter_test/flutter_test.dart';
import 'package:qintu/models/binding/binding.dart';

void main() {
  group('Binding', () {
    test('fromJson 正确解析', () {
      final json = {
        'id': 1,
        'status': 'active',
        'my_role': 'sender',
        'partner_userId': 'p-123',
        'partner_nickname': '李四',
        'partner_phone': '13800138000',
        'my_name_for_partner': '妈妈',
        'created_at': '2026-04-09T10:00:00.000Z',
        'bound_at': '2026-04-09T10:05:00.000Z',
      };

      final binding = Binding.fromJson(json);

      expect(binding.id, 1);
      expect(binding.status, 'active');
      expect(binding.myRole, MyRole.sender);
      expect(binding.partnerUserID, 'p-123');
      expect(binding.partnerNickname, '李四');
      expect(binding.partnerPhone, '13800138000');
      expect(binding.myNameForPartner, '妈妈');
    });

    test('isActive 当 status=active 时返回 true', () {
      const binding = Binding(status: 'active');
      expect(binding.isActive, isTrue);
    });

    test('isPending 当 status=pending 时返回 true', () {
      const binding = Binding(status: 'pending');
      expect(binding.isPending, isTrue);
    });

    test('isExpired 当 expiredAt 已过时返回 true', () {
      final binding = Binding(
        status: 'pending',
        expiredAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(binding.isExpired, isTrue);
    });

    test('isExpired 当 expiredAt 未过时返回 false', () {
      final binding = Binding(
        status: 'active',
        expiredAt: DateTime.now().add(const Duration(days: 1)),
      );
      expect(binding.isExpired, isFalse);
    });
  });

  group('BindingList', () {
    test('fromJson 正确解析', () {
      final json = {
        'total': 2,
        'as_sender': 1,
        'as_receiver': 1,
        'bindings': [
          {'id': 1, 'status': 'active'},
          {'id': 2, 'status': 'pending'},
        ],
      };

      final list = BindingList.fromJson(json);

      expect(list.total, 2);
      expect(list.asSender, 1);
      expect(list.asReceiver, 1);
      expect(list.bindings.length, 2);
      expect(list.bindings[0].isActive, isTrue);
      expect(list.bindings[1].isPending, isTrue);
    });
  });

  group('PendingRequest', () {
    test('timeRemaining 返回到 expiredAt 的差值', () {
      final now = DateTime.now();
      final request = PendingRequest(
        id: 1,
        createdAt: now,
        expiredAt: now.add(const Duration(hours: 5)),
      );

      // 5 小时左右（允许 1 秒误差）
      expect(request.timeRemaining.inHours, inInclusiveRange(4, 5));
    });

    test('isExpiringSoon 在 1-24 小时之间返回 true', () {
      final now = DateTime.now();
      final request = PendingRequest(
        id: 1,
        createdAt: now,
        expiredAt: now.add(const Duration(hours: 12)),
      );

      expect(request.isExpiringSoon, isTrue);
    });

    test('isExpiringSoon 在超过 24 小时时返回 false', () {
      final now = DateTime.now();
      final request = PendingRequest(
        id: 1,
        createdAt: now,
        expiredAt: now.add(const Duration(days: 3)),
      );

      expect(request.isExpiringSoon, isFalse);
    });

    test('isExpired 当过期时间已过返回 true', () {
      final now = DateTime.now();
      final request = PendingRequest(
        id: 1,
        createdAt: now.subtract(const Duration(days: 1)),
        expiredAt: now.subtract(const Duration(hours: 1)),
      );

      expect(request.isExpired, isTrue);
    });
  });

  group('BindingLocation', () {
    test('isValid 当时间戳在 5 分钟内返回 true', () {
      final loc = BindingLocation(
        latitude: 30.0,
        longitude: 120.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      expect(loc.isValid, isTrue);
    });

    test('isValid 当时间戳超过 5 分钟返回 false', () {
      final loc = BindingLocation(
        latitude: 30.0,
        longitude: 120.0,
        timestamp: DateTime.now()
            .subtract(const Duration(minutes: 10))
            .millisecondsSinceEpoch,
      );

      expect(loc.isValid, isFalse);
    });

    test('isValid 当 timestamp 为 null 时返回 false', () {
      const loc = BindingLocation(latitude: 30.0, longitude: 120.0);
      expect(loc.isValid, isFalse);
    });
  });
}
