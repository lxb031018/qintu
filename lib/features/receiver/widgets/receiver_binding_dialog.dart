import 'package:flutter/material.dart';
import '../../../utils/logger.dart';
import '../../../utils/phone_utils.dart';
import '../../../theme/app_text_styles.dart';

/// 绑定请求对话框 - 显示绑定请求并允许用户确认/拒绝

class ReceiverBindingDialog extends StatelessWidget {
  /// 绑定请求数据
  final Map<String, dynamic> request;

  const ReceiverBindingDialog({
    super.key,
    required this.request,
  });

  /// 显示绑定请求对话框
  /// 返回 true 表示确认绑定，false 表示拒绝，null 表示取消
  static Future<bool?> show(BuildContext context, Map<String, dynamic> request) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ReceiverBindingDialog(request: request);
      },
    );
  }

  /// 处理绑定请求
  Future<void> _handleBinding(BuildContext context, bool accepted) async {
    final phone = request['phone'] ?? '未知';
    final maskedPhone = PhoneUtils.maskPhone(phone);

    if (accepted) {
      Logs.binding.info('确认绑定: $maskedPhone');
    } else {
      Logs.binding.info('拒绝绑定: $maskedPhone');
    }

    if (context.mounted) {
      Navigator.pop(context, accepted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = request['phone'] ?? '未知';
    final maskedPhone = PhoneUtils.maskPhone(phone);
    final name = request['name'] ?? '未提供姓名';

    return AlertDialog(
      title: const Text('绑定请求'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('您收到一个绑定请求'),
          const SizedBox(height: 16),
          Text(
            '手机号：$maskedPhone',
            style: AppTextStyles.dialogContent.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('姓名：$name'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _handleBinding(context, false),
          child: const Text('拒绝'),
        ),
        ElevatedButton(
          onPressed: () => _handleBinding(context, true),
          child: const Text('确认绑定'),
        ),
      ],
    );
  }
}

/// 绑定请求列表项组件
class ReceiverBindingRequestItem extends StatelessWidget {
  /// 绑定请求数据
  final Map<String, dynamic> request;

  /// 点击处理回调
  final Function(Map<String, dynamic> request) onTap;

  const ReceiverBindingRequestItem({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final phone = request['phone'] ?? '未知';
    final maskedPhone = PhoneUtils.maskPhone(phone);
    final name = request['name'] ?? '未提供姓名';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(maskedPhone),
        subtitle: Text(name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => onTap(request),
              child: const Text('拒绝'),
            ),
            ElevatedButton(
              onPressed: () => onTap(request),
              child: const Text('确认'),
            ),
          ],
        ),
      ),
    );
  }
}
