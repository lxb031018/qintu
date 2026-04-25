import 'package:flutter_test/flutter_test.dart';
import 'package:qintu/models/binding/binding.dart';

void main() {
  group('SentRequest', () {
    test('fromJson 正确解析数据', () {
      final json = {
        'id': 1,
        'status': 'pending',
        'sender_name': '张三',
        'receiver_nickname': '李四',
        'receiver_phone': '13800138000',
        'created_at': '2026-04-09T10:00:00.000Z',
        'expired_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      };

      final request = SentRequest.fromJson(json);

      expect(request.id, 1);
      expect(request.status, 'pending');
      expect(request.receiverNickname, '李四');
      expect(request.receiverPhone, '13800138000');
      expect(request.isPending, isTrue);
    });

    test('isExpiringSoon 在少于 24 小时时返回 true', () {
      final request = SentRequest(
        id: 1,
        status: 'pending',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(hours: 12)),
      );

      expect(request.isExpiringSoon, isTrue);
    });

    test('isExpiringSoon 在超过 24 小时时返回 false', () {
      final request = SentRequest(
        id: 1,
        status: 'pending',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(days: 3)),
      );

      expect(request.isExpiringSoon, isFalse);
    });

    test('isExpired 在已过期时返回 true', () {
      final request = SentRequest(
        id: 1,
        status: 'expired',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(request.isExpired, isTrue);
    });

    test('isExpired 在未过期时返回 false', () {
      final request = SentRequest(
        id: 1,
        status: 'pending',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(request.isExpired, isFalse);
    });

    test('expiredAtText 在已过期时返回 "已过期"', () {
      final request = SentRequest(
        id: 1,
        status: 'expired',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(request.expiredAtText, '已过期');
    });

    test('expiredAtText 在不足 1 小时时返回 "不足 1 小时"', () {
      final request = SentRequest(
        id: 1,
        status: 'pending',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(minutes: 30)),
      );

      expect(request.expiredAtText, '不足 1 小时');
    });

    test('expiredAtText 在少于 24 小时时返回 "X小时后过期"', () {
      final request = SentRequest(
        id: 1,
        status: 'pending',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(hours: 12)),
      );

      expect(request.expiredAtText, '12小时后过期');
    });

    test('expiredAtText 在超过 24 小时时返回 "X天后过期"', () {
      final request = SentRequest(
        id: 1,
        status: 'pending',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(days: 3)),
      );

      expect(request.expiredAtText, '3天后过期');
    });

    test('isRejected 在被拒绝时返回 true', () {
      final request = SentRequest(
        id: 1,
        status: 'revoked',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(days: 7)),
      );

      expect(request.isRejected, isTrue);
    });

    test('isActive 在已绑定时返回 true', () {
      final request = SentRequest(
        id: 1,
        status: 'active',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(days: 7)),
      );

      expect(request.isActive, isTrue);
    });

    test('statusText 返回正确的状态文本', () {
      final pending = SentRequest(
        id: 1,
        status: 'pending',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(days: 7)),
      );
      expect(pending.statusText, '等待对方确认');

      final rejected = SentRequest(
        id: 2,
        status: 'revoked',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(days: 7)),
      );
      expect(rejected.statusText, '对方已拒绝');

      final expired = SentRequest(
        id: 3,
        status: 'expired',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(expired.statusText, '已过期');

      final active = SentRequest(
        id: 4,
        status: 'active',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(days: 7)),
      );
      expect(active.statusText, '已绑定');
    });
  });

  group('PendingRequest', () {
    test('fromJson 正确解析数据', () {
      final json = {
        'id': 1,
        'sender_name': '张三',
        'sender_nickname': '小张',
        'sender_phone': '13800138000',
        'created_at': '2026-04-09T10:00:00.000Z',
      };

      final request = PendingRequest.fromJson(json);

      expect(request.id, 1);
      expect(request.senderName, '张三');
      expect(request.senderPhone, '13800138000');
    });
  });
}
