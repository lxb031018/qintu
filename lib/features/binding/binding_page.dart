import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/binding_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/binding.dart';
import '../../utils/logger.dart';

/// ============================================
/// 绑定管理页面（绑定 Tab）
///
/// 职责：专门管理绑定关系（添加绑定、解绑）
/// 不处理路径规划等功能
/// ============================================

class BindingPage extends StatefulWidget {
  const BindingPage({super.key});

  @override
  State<BindingPage> createState() => _BindingPageState();
}

class _BindingPageState extends State<BindingPage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // 延迟初始化，确保 Provider 已经创建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBindingProvider();
    });
  }

  /// 初始化 BindingProvider
  Future<void> _initBindingProvider() async {
    if (_isInitialized) return;

    final userProvider = context.read<UserProvider>();
    final bindingProvider = context.read<BindingProvider>();

    // 检查是否已登录
    if (userProvider.apiService == null) {
      Logs.binding.warning('用户未登录，使用测试模式');
      // 测试模式：不初始化，显示空状态
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      return;
    }

    // 初始化并加载数据
    bindingProvider.init(userProvider.apiService!);
    await bindingProvider.loadBindings();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 刷新按钮栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  final bindingProvider = context.read<BindingProvider>();
                  await bindingProvider.refresh();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('刷新成功'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                tooltip: '刷新',
              ),
            ],
          ),
        ),
        // 绑定管理内容
        Expanded(
          child: Consumer<BindingProvider>(
            builder: (context, provider, child) {
              // 显示错误信息
              if (provider.error != null) {
                return _ErrorView(
                  error: provider.error!,
                  onRetry: () => provider.loadBindings(),
                  onClearError: () => provider.clearError(),
                );
              }

              return Column(
            children: [
              // 绑定数量统计
              _BindingStatsCard(provider: provider),

              // 绑定列表
              Expanded(
                child: provider.isLoading && provider.bindings.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : provider.bindings.isEmpty
                        ? const _EmptyBindingView()
                        : _BindingListView(
                            bindings: provider.bindings,
                            onRevoke: (bindingId) => _confirmRevoke(context, bindingId),
                          ),
              ),

              // 添加绑定按钮
              _AddBindingButton(provider: provider),
            ],
          );
        },
          ),
        ),
      ],
    );
  }

  /// 确认解除绑定
  Future<void> _confirmRevoke(BuildContext context, int bindingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('解除绑定'),
          content: const Text('确定要解除这个绑定关系吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('解除绑定'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      
      final bindingProvider = context.read<BindingProvider>();
      final success = await bindingProvider.revokeBinding(bindingId);

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bindingProvider.successMessage ?? '解除绑定成功'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bindingProvider.error ?? '解除绑定失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// 绑定统计卡片
class _BindingStatsCard extends StatelessWidget {
  final BindingProvider provider;

  const _BindingStatsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '当前绑定',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.person_outlined,
                  label: '作为发送者',
                  value: '${provider.asSenderCount}/5',
                  isLimitReached: provider.isSenderLimitReached,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatItem(
                  icon: Icons.group_outlined,
                  label: '作为接收者',
                  value: '${provider.asReceiverCount}/3',
                  isLimitReached: provider.isReceiverLimitReached,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 统计项
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLimitReached;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isLimitReached = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: isLimitReached ? Colors.red : Colors.blue),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isLimitReached ? Colors.red : null,
          ),
        ),
        if (isLimitReached)
          const Text(
            '已达上限',
            style: TextStyle(
              fontSize: 10,
              color: Colors.red,
            ),
          ),
      ],
    );
  }
}

/// 绑定列表视图
class _BindingListView extends StatelessWidget {
  final List<Binding> bindings;
  final Function(int) onRevoke;

  const _BindingListView({
    required this.bindings,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bindings.length,
      itemBuilder: (context, index) {
        final binding = bindings[index];
        return _BindingCard(
          binding: binding,
          onRevoke: () => onRevoke(binding.id),
        );
      },
    );
  }
}

/// 绑定卡片
class _BindingCard extends StatelessWidget {
  final Binding binding;
  final VoidCallback onRevoke;

  const _BindingCard({
    required this.binding,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final isSender = binding.myRole == MyRole.sender;
    final statusColor = _getStatusColor(binding.status);
    final statusText = _getStatusText(binding.status);
    // 手机号脱敏显示
    final maskedPhone = _maskPhone(binding.partnerNickname ?? '未知用户');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSender
              ? Colors.orange.shade100
              : Colors.green.shade100,
          child: Icon(
            isSender ? Icons.person : Icons.group,
            color: isSender ? Colors.orange : Colors.green,
          ),
        ),
        title: Text(
          maskedPhone,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              isSender ? '接收者' : '发送者',
              style: TextStyle(
                fontSize: 12,
                color: isSender ? Colors.orange : Colors.green,
              ),
            ),
            if (binding.remark != null && binding.remark!.isNotEmpty)
              Text(
                '备注：${binding.remark}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: statusColor,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 8),
            if (binding.status == BindingStatus.active)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onRevoke,
                tooltip: '解除绑定',
              ),
          ],
        ),
      ),
    );
  }

  /// 手机号脱敏处理
  String _maskPhone(String phone) {
    if (phone.length == 11) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    return phone;
  }

  Color _getStatusColor(BindingStatus status) {
    switch (status) {
      case BindingStatus.active:
        return Colors.green;
      case BindingStatus.pending:
        return Colors.orange;
      case BindingStatus.expired:
        return Colors.grey;
      case BindingStatus.revoked:
        return Colors.red;
    }
  }

  String _getStatusText(BindingStatus status) {
    switch (status) {
      case BindingStatus.active:
        return '生效中';
      case BindingStatus.pending:
        return '待确认';
      case BindingStatus.expired:
        return '已过期';
      case BindingStatus.revoked:
        return '已解除';
    }
  }
}

/// 添加绑定按钮
class _AddBindingButton extends StatelessWidget {
  final BindingProvider provider;

  const _AddBindingButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    // 如果发送者和接收者都达到上限，不显示按钮
    if (provider.isSenderLimitReached && provider.isReceiverLimitReached) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          '绑定人数已达上限',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showBindingDialog(context),
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            '绑定新用户',
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  /// 显示绑定方式选择对话框
  void _showBindingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('绑定新用户'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.phone_android, size: 40),
                title: const Text('手机号绑定'),
                subtitle: const Text('输入对方手机号发送绑定请求'),
                onTap: () {
                  Navigator.pop(context);
                  _showPhoneBindingDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 显示手机号绑定对话框
  Future<void> _showPhoneBindingDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    bool isLoading = false;
    bool obscurePhone = true;
    Timer? showTimer;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('发送绑定请求'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: '您的姓名（必填）',
                      hintText: '请输入您的真实姓名',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 20,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    enabled: !isLoading,
                    obscureText: obscurePhone,
                    obscuringCharacter: '●',
                    decoration: InputDecoration(
                      labelText: '对方手机号（必填）',
                      hintText: '请输入 11 位手机号',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePhone ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          if (obscurePhone) {
                            setDialogState(() => obscurePhone = false);
                            showTimer?.cancel();
                            showTimer = Timer(const Duration(seconds: 2), () {
                              setDialogState(() => obscurePhone = true);
                            });
                          } else {
                            showTimer?.cancel();
                            setDialogState(() => obscurePhone = true);
                          }
                        },
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '对方将看到您的姓名和手机号，请确认信息真实有效',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('正在发送请求...'),
                        ],
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () {
                    showTimer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请填写您的姓名')),
                            );
                            return;
                          }
                          if (phoneController.text.isEmpty ||
                              phoneController.text.length != 11) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入正确的手机号')),
                            );
                            return;
                          }

                          setDialogState(() {
                            isLoading = true;
                          });

                          // TODO: 实现手机号绑定逻辑
                          // final provider = context.read<BindingProvider>();
                          // final success = await provider.requestBindingByPhone(
                          //   nameController.text,
                          //   phoneController.text,
                          // );

                          // 模拟延迟
                          await Future.delayed(const Duration(seconds: 1));

                          setDialogState(() {
                            isLoading = false;
                          });

                          // TODO: 根据实际结果更新 UI
                          if (!context.mounted) return;
                          showTimer?.cancel();
                          Navigator.pop(context);
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('绑定请求已发送，等待对方确认'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                  child: const Text('发送请求'),
                ),
              ],
            );
          },
        );
      },
    );
    
    showTimer?.cancel();
  }
}

/// 空绑定提示
class _EmptyBindingView extends StatelessWidget {
  const _EmptyBindingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无绑定关系',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方"绑定新用户"开始绑定',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 错误视图
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onClearError;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.onClearError,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
