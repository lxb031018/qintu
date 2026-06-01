import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qintu/features/relationship_binding/widgets/binding_card.dart';
import 'package:qintu/models/binding/binding.dart';

void main() {
  Widget _wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('展示我的称呼（myNameForPartner）', (tester) async {
    await tester.pumpWidget(_wrap(BindingCard(
      binding: const Binding(
        id: 1,
        status: 'active',
        myNameForPartner: '妈妈',
        partnerPhone: '13800138000',
      ),
      onRevoke: () {},
    )));

    expect(find.text('妈妈'), findsOneWidget);
  });

  testWidgets('当没有 myNameForPartner 时回退到 partnerNickname', (tester) async {
    await tester.pumpWidget(_wrap(BindingCard(
      binding: const Binding(
        id: 1,
        status: 'active',
        partnerNickname: '李四',
        partnerPhone: '13800138000',
      ),
      onRevoke: () {},
    )));

    expect(find.text('李四'), findsOneWidget);
  });

  testWidgets('active 状态显示"已绑定"和删除按钮', (tester) async {
    var revoked = false;
    await tester.pumpWidget(_wrap(BindingCard(
      binding: const Binding(
        id: 1,
        status: 'active',
        myNameForPartner: '妈妈',
      ),
      onRevoke: () => revoked = true,
    )));

    expect(find.text('已绑定'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    expect(revoked, isTrue);
  });

  testWidgets('pending 状态显示"待确认"且无删除按钮', (tester) async {
    await tester.pumpWidget(_wrap(BindingCard(
      binding: const Binding(
        id: 1,
        status: 'pending',
        myNameForPartner: '妈妈',
      ),
      onRevoke: () {},
    )));

    expect(find.text('待确认'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('expired 状态显示"已过期"', (tester) async {
    await tester.pumpWidget(_wrap(BindingCard(
      binding: const Binding(
        id: 1,
        status: 'expired',
        myNameForPartner: '妈妈',
      ),
      onRevoke: () {},
    )));

    expect(find.text('已过期'), findsOneWidget);
  });
}
