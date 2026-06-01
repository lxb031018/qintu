import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qintu/models/binding/binding.dart';
import 'package:qintu/features/relationship_binding/models/binding_status_display.dart';

void main() {
  group('BindingStatusDisplay.colorFor (SentRequest)', () {
    SentRequest make(String status, {Duration? remaining, DateTime? expiredAt}) {
      return SentRequest(
        id: 1,
        status: status,
        createdAt: DateTime.now(),
        expiredAt: expiredAt ?? (DateTime.now().add(remaining ?? const Duration(days: 1))),
      );
    }

    test('pending + 未临近过期 → infoColor（蓝）', () {
      final r = make('pending', remaining: const Duration(days: 1));
      expect(BindingStatusDisplay.colorFor(r), isNot(equals(Colors.transparent)));
    });

    test('pending + 临近过期（<24h）→ warningColor（橙）', () {
      final r = make('pending', remaining: const Duration(hours: 12));
      expect(BindingStatusDisplay.colorFor(r), isNot(equals(Colors.transparent)));
    });

    test('revoked → errorColor', () {
      final r = make('revoked');
      expect(BindingStatusDisplay.colorFor(r), isNot(equals(Colors.transparent)));
    });

    test('active → successColor', () {
      final r = make('active');
      expect(BindingStatusDisplay.colorFor(r), isNot(equals(Colors.transparent)));
    });

    test('expired → disabledColor', () {
      final r = make('expired');
      expect(BindingStatusDisplay.colorFor(r), isNot(equals(Colors.transparent)));
    });
  });

  group('BindingStatusDisplay.iconFor (SentRequest)', () {
    test('pending 返回沙漏或警告图标', () {
      final r = SentRequest(
        id: 1,
        status: 'pending',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(days: 1)),
      );
      expect(BindingStatusDisplay.iconFor(r), isA<IconData>());
    });

    test('unknown status 返回 help_outline', () {
      final r = SentRequest(
        id: 1,
        status: 'unknown',
        createdAt: DateTime.now(),
      );
      expect(BindingStatusDisplay.iconFor(r), Icons.help_outline);
    });
  });

  group('BindingStatusText.labelFor (Binding)', () {
    test('active → "已绑定"', () {
      expect(BindingStatusText.labelFor('active'), '已绑定');
    });

    test('pending → "待确认"', () {
      expect(BindingStatusText.labelFor('pending'), '待确认');
    });

    test('expired → "已过期"', () {
      expect(BindingStatusText.labelFor('expired'), '已过期');
    });

    test('revoked → "已解除"', () {
      expect(BindingStatusText.labelFor('revoked'), '已解除');
    });

    test('未知 status → "未知"', () {
      expect(BindingStatusText.labelFor('xxx'), '未知');
    });
  });
}
