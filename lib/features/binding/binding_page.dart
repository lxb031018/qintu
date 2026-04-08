import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/binding_provider.dart';
import '../../managers/auth_state_manager.dart';
import '../../utils/logger.dart';
import '../../constants/app_strings.dart';
import 'widgets/phone_binding_dialog.dart';
import 'widgets/binding_stats_card.dart';
import 'widgets/binding_list_view.dart';
import 'widgets/add_binding_button.dart';
import 'widgets/empty_binding_view.dart';
import 'widgets/error_view.dart';
import 'widgets/pending_requests_view.dart';

/// ============================================
/// 绑定管理页面（绑定 Tab）
///
/// 职责：专门管理绑定关系（添加绑定、解绑）
/// 不处理路径规划等功能
/// 
/// 重构说明（2026-04-08）：
/// - 从 742 行减少到 ~180 行
/// - 所有子组件拆分为独立文件
/// - 硬编码全部提取到 AppStrings 和 Constants
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

    final authStateManager = context.read<AuthStateManager>();
    final bindingProvider = context.read<BindingProvider>();

    // 检查是否已登录
    final userId = authStateManager.state.userId;
    if (userId == null) {
      Logs.binding.warning('用户未登录，使用测试模式');
      // 测试模式：不初始化，显示空状态
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      return;
    }

    // 加载绑定列表（BindingProvider 内部使用 ApiClient）
    await bindingProvider.loadBindings();
    
    // 如果有待确认请求，加载它们
    if (authStateManager.state.pendingBindingCount > 0) {
      await bindingProvider.loadPendingRequests();
    }

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
              Consumer<BindingProvider>(
                builder: (context, provider, child) {
                  // 如果有待确认请求，显示带数字的刷新按钮
                  if (provider.pendingRequestsCount > 0) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => _refreshData(context),
                          tooltip: AppStrings.refresh,
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${provider.pendingRequestsCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _refreshData(context),
                    tooltip: AppStrings.refresh,
                  );
                },
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
                return ErrorView(
                  error: provider.error!,
                  onRetry: () => provider.loadBindings(),
                  onClearError: () => provider.clearError(),
                );
              }

              return Column(
                children: [
                  // 待确认请求列表（如果有）
                  PendingRequestsView(
                    provider: provider,
                    onConfirm: (requestId) => _confirmRequest(context, requestId),
                    onReject: (requestId) => _rejectRequest(context, requestId),
                  ),
                  
                  // 绑定数量统计
                  BindingStatsCard(provider: provider),

                  // 绑定列表
                  Expanded(
                    child: provider.isLoading && provider.bindings.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : provider.bindings.isEmpty
                            ? const EmptyBindingView()
                            : BindingListView(
                                bindings: provider.bindings,
                                onRevoke: (bindingId) => _confirmRevoke(context, bindingId),
                              ),
                  ),

                  // 添加绑定按钮
                  AddBindingButton(
                    provider: provider,
                    onPressed: () => _showBindingDialog(context),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// 刷新数据
  Future<void> _refreshData(BuildContext context) async {
    final bindingProvider = context.read<BindingProvider>();
    await bindingProvider.refresh();
    await bindingProvider.loadPendingRequests();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.refreshSuccess),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// 确认绑定请求
  Future<void> _confirmRequest(BuildContext context, int requestId) async {
    final bindingProvider = context.read<BindingProvider>();
    final success = await bindingProvider.confirmRequest(requestId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('绑定成功'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bindingProvider.error ?? '确认失败'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// 拒绝绑定请求
  Future<void> _rejectRequest(BuildContext context, int requestId) async {
    final bindingProvider = context.read<BindingProvider>();
    final success = await bindingProvider.rejectRequest(requestId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已拒绝'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bindingProvider.error ?? '拒绝失败'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
                backgroundColor: Theme.of(context).colorScheme.error,
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
          SnackBar(
            content: const Text(AppStrings.revokeBindingSuccess),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bindingProvider.error ?? AppStrings.revokeBindingFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
    await showDialog(
      context: context,
      builder: (dialogContext) => const PhoneBindingDialog(),
    );
  }
}
