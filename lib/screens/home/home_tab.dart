import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';

/// 主页 Tab（发送者/接收者根据角色显示不同内容）
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // 从用户 Provider 获取真实角色
        final user = userProvider.user;
        final isSender = user?.userType == UserRole.sender || 
                         user?.userType == UserRole.both;

        return Scaffold(
          appBar: AppBar(
            title: const Text('亲途'),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  // TODO: 查看历史任务
                },
              ),
            ],
          ),
          body: isSender ? const _SenderHome() : const _ReceiverHome(),
        );
      },
    );
  }
}

/// 发送者主页
class _SenderHome extends StatelessWidget {
  const _SenderHome();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 绑定接收者数量
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '我的绑定接收者',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '2/5 个绑定',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 跳转到绑定页
                    },
                    child: const Text('管理绑定'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 绑定列表
        const Expanded(
          child: _BindingsList(),
        ),
      ],
    );
  }
}

/// 绑定接收者列表
class _BindingsList extends StatelessWidget {
  const _BindingsList();

  @override
  Widget build(BuildContext context) {
    // TODO: 从 Provider 获取绑定列表
    final bindings = [
      {
        'name': '父亲',
        'phone': '+86 138****8000',
        'status': 'navigating',
      },
      {
        'name': '母亲',
        'phone': '+86 139****9000',
        'status': 'waiting',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bindings.length,
      itemBuilder: (context, index) {
        final binding = bindings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.person, color: Colors.green),
            ),
            title: Text(binding['name'] as String),
            subtitle: Text(binding['phone'] as String),
            trailing: _buildStatusActions(binding),
          ),
        );
      },
    );
  }

  Widget _buildStatusActions(Map<String, dynamic> binding) {
    final status = binding['status'] as String;

    if (status == 'navigating') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // TODO: 查看位置
            },
            icon: const Icon(Icons.location_on),
            label: const Text('查看位置'),
          ),
        ],
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () {
          // TODO: 发送路线
        },
        icon: const Icon(Icons.send),
        label: const Text('发路线'),
      );
    }
  }
}

/// 接收者主页
class _ReceiverHome extends StatelessWidget {
  const _ReceiverHome();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hourglass_empty,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              '等待发送者发送路线...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '绑定发送者：张三（儿子）',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(height: 8),
                  Text(
                    '当发送者发送路线后，您会在这里收到通知。\n点击"接受"即可开始导航。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
