import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/binding_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/binding.dart';
import '../../utils/logger.dart';
import '../../utils/phone_utils.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

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
                      content: Text(AppStrings.refreshSuccess),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                tooltip: AppStrings.refresh,
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
          title: const Text(AppStrings.revokeBinding),
          content: const Text(AppStrings.revokeBindingConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.revokeBinding),
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
          const SnackBar(
            content: Text(AppStrings.revokeBindingSuccess),
            backgroundColor: AppColors.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bindingProvider.error ?? AppStrings.revokeBindingFailed),
            backgroundColor: AppColors.errorColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? AppColors.darkCardBackground : Colors.blue.shade50;
    final borderColor = isDark ? AppColors.darkDividerColor : Colors.blue.shade200;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.currentBinding,
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
                  label: AppStrings.asSender,
                  value: '${provider.asSenderCount}/5',
                  isLimitReached: provider.isSenderLimitReached,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatItem(
                  icon: Icons.group_outlined,
                  label: AppStrings.asReceiver,
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
        Icon(icon, color: isLimitReached ? AppColors.errorColor : Colors.blue),
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
            color: isLimitReached ? AppColors.errorColor : null,
          ),
        ),
        if (isLimitReached)
          const Text(
            AppStrings.limitReached,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.errorColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSender = binding.myRole == MyRole.sender;
    final statusColor = _getStatusColor(binding.status);
    final statusText = _getStatusText(binding.status);
    final avatarBackground = isSender
        ? Colors.orange.shade100
        : Colors.green.shade100;
    final avatarIconColor = isSender ? Colors.orange : Colors.green;
    final roleTextColor = isSender ? Colors.orange : Colors.green;
    // 手机号脱敏显示
    final maskedPhone = PhoneUtils.maskPhone(binding.partnerNickname ?? AppStrings.unknownUser);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarBackground,
          child: Icon(
            isSender ? Icons.person : Icons.group,
            color: avatarIconColor,
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
              isSender ? AppStrings.receiver : AppStrings.sender,
              style: TextStyle(
                fontSize: 12,
                color: roleTextColor,
              ),
            ),
            if (binding.remark != null && binding.remark!.isNotEmpty)
              Text(
                '${AppStrings.remark}：${binding.remark}',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey),
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
                icon: const Icon(Icons.delete_outline, color: AppColors.errorColor),
                onPressed: onRevoke,
                tooltip: AppStrings.revokeBinding,
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BindingStatus status) {
    switch (status) {
      case BindingStatus.active:
        return AppColors.successColor;
      case BindingStatus.pending:
        return Colors.orange;
      case BindingStatus.expired:
        return Colors.grey;
      case BindingStatus.revoked:
        return AppColors.errorColor;
    }
  }

  String _getStatusText(BindingStatus status) {
    switch (status) {
      case BindingStatus.active:
        return AppStrings.active;
      case BindingStatus.pending:
        return AppStrings.pending;
      case BindingStatus.expired:
        return AppStrings.expired;
      case BindingStatus.revoked:
        return AppStrings.revoked;
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
          AppStrings.bindingLimitReached,
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
            AppStrings.addNewBinding,
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
          title: const Text(AppStrings.addNewBinding),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.phone_android, size: 40),
                title: const Text(AppStrings.partnerPhone),
                subtitle: const Text(AppStrings.sendBindingRequest),
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
              title: const Text(AppStrings.sendBindingRequest),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: AppStrings.yourName,
                      hintText: AppStrings.yourName,
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
                      labelText: AppStrings.partnerPhone,
                      hintText: AppStrings.partnerPhone,
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
                          Text(AppStrings.loadingText),
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
                  child: const Text(AppStrings.cancel),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(AppStrings.pleaseFillName)),
                            );
                            return;
                          }
                          if (phoneController.text.isEmpty ||
                              phoneController.text.length != 11) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(AppStrings.invalidPhone)),
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

                          // 网络请求延迟
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
                              content: Text(AppStrings.bindingRequestSent),
                              backgroundColor: AppColors.successColor,
                            ),
                          );
                        },
                  child: const Text(AppStrings.sendRequest),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    final titleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final subtitleColor = isDark ? Colors.grey.shade500 : Colors.grey.shade500;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link_off,
            size: 80,
            color: iconColor,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noBinding,
            style: TextStyle(
              fontSize: 18,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.addNewBinding,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.loadFailed,
              style: TextStyle(
                fontSize: 18,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: AppColors.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
