import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qintu/features/relationship_binding/binding_notifications/widgets/pending_request_card.dart';
import 'package:qintu/models/binding/binding.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('展示发送者名字和脱敏手机号', (tester) async {
    await tester.pumpWidget(wrap(PendingRequestCard(
      request: PendingRequest(
        id: 1,
        senderUserID: 'sender-1',
        senderName: '张三',
        senderPhone: '13800138000',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(days: 5)),
      ),
      onAccept: (_) {},
      onReject: (_) {},
    )));

    expect(find.text('张三'), findsOneWidget);
    expect(find.text('138****8000'), findsOneWidget);
  });

  testWidgets('点击接受按钮弹出确认对话框', (tester) async {
    var accepted = false;
    await tester.pumpWidget(wrap(PendingRequestCard(
      request: PendingRequest(
        id: 1,
        senderUserID: 'sender-1',
        senderName: '张三',
        senderPhone: '13800138000',
        createdAt: DateTime.now(),
        expiredAt: DateTime.now().add(const Duration(days: 5)),
      ),
      onAccept: (_) => accepted = true,
      onReject: (_) {},
    )));

    // 点击卡片上的"接受"按钮（图标按钮）
    await tester.tap(find.widgetWithText(ElevatedButton, '接受').first);
    await tester.pumpAndSettle();

    // 确认对话框出现
    expect(find.textContaining('确定要接受'), findsOneWidget);

    // 点击对话框里的"接受"按钮（也是 ElevatedButton 里的）
    await tester.tap(find.widgetWithText(ElevatedButton, '接受').last);
    await tester.pumpAndSettle();
    expect(accepted, isTrue);
  });

  testWidgets('临近过期显示警告提示', (tester) async {
    await tester.pumpWidget(wrap(PendingRequestCard(
      request: PendingRequest(
        id: 1,
        senderUserID: 'sender-1',
        senderName: '张三',
        senderPhone: '13800138000',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        expiredAt: DateTime.now().add(const Duration(hours: 12)),
      ),
      onAccept: (_) {},
      onReject: (_) {},
    )));

    // 警告标题 + 时间行
    expect(find.textContaining('剩余'), findsWidgets);
  });
}
