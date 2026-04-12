import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/binding_provider.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/common/tab_badge.dart';
import '../../../../utils/app_snackbar.dart';
import 'widgets/received_requests_tab.dart';
import 'widgets/sent_requests_tab.dart';
import 'widgets/rejected_requests_tab.dart';

/// ============================================
/// 通知中心页面
///
/// 显示三类通知：
/// 1. 收到的绑定请求（需要确认/拒绝）
/// 2. 我发出的请求（pending/active/expired）
/// 3. 我发出的请求被对方拒绝的通知
/// ============================================

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 刷新通知数据
  Future<void> _loadNotifications() async {
    final provider = context.read<BindingProvider>();
    await provider.loadPendingRequests();
    await provider.loadSentRequests();
  }

  /// 构建带角标的 Tab
  Widget _buildTab(IconData icon, String label, String type) {
    return Consumer<BindingProvider>(
      builder: (context, provider, child) {
        final count = _getBadgeCount(provider, type);
        return Tab(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              TabBadge(count: count),
            ],
          ),
          text: label,
        );
      },
    );
  }

  /// 获取对应 Tab 的角标数量
  int _getBadgeCount(BindingProvider provider, String type) {
    switch (type) {
      case 'sent':
        return provider.sentRequests.where((r) => r.isPending).length;
      case 'received':
        return provider.pendingRequestsCount;
      case 'rejected':
        return provider.sentRequests.where((r) => r.isRejected).length;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // "下拉刷新"提示
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Text(
                  AppStrings.pullToRefresh,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              // Tab Bar
              TabBar(
                controller: _tabController,
                tabs: [
                  _buildTab(Icons.logout_rounded, AppStrings.sentRequests, 'sent'),
                  _buildTab(Icons.login_rounded, AppStrings.receivedRequests, 'received'),
                  _buildTab(Icons.cancel_outlined, AppStrings.rejectedRequests, 'rejected'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SentRequestsTab(
            onRefresh: _loadNotifications,
            onCancel: _cancelRequest,
          ),
          ReceivedRequestsTab(
            onRefresh: _loadNotifications,
            onConfirm: _confirmRequest,
            onReject: _rejectRequest,
          ),
          RejectedRequestsTab(
            onRefresh: _loadNotifications,
          ),
        ],
      ),
    );
  }

  /// 确认绑定请求
  Future<void> _confirmRequest(int requestId) async {
    final provider = context.read<BindingProvider>();
    final success = await provider.confirmRequest(requestId);
    if (!mounted) return;
    _handleOperationResult(context, success, provider.error, AppStrings.acceptBindingRequestSuccess, AppStrings.acceptBindingRequestFailed);
  }

  /// 拒绝绑定请求
  Future<void> _rejectRequest(int requestId) async {
    final provider = context.read<BindingProvider>();
    final success = await provider.rejectRequest(requestId);
    if (!mounted) return;
    _handleOperationResult(context, success, provider.error, AppStrings.rejectBindingRequestSuccess, AppStrings.rejectBindingRequestFailed);
  }

  /// 取消发出的请求
  Future<void> _cancelRequest(int requestId) async {
    final provider = context.read<BindingProvider>();
    final ctx = context;

    showDialog(
      context: ctx,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.cancelRequest),
          content: const Text(AppStrings.confirmCancelRequest),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppStrings.notCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final success = await provider.cancelSentRequest(requestId);
                if (!ctx.mounted) return;
                _handleOperationResult(
                  ctx,
                  success,
                  provider.lastErrorMessage,
                  AppStrings.requestCancelled,
                  AppStrings.cancelRequestFailed,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.confirmCancel),
            ),
          ],
        );
      },
    );
  }

  /// 统一处理操作结果（成功显示提示 + 刷新，失败显示错误）
  Future<void> _handleOperationResult(
    BuildContext ctx,
    bool success,
    String? errorMsg,
    String successText,
    String errorText,
  ) async {
    if (!ctx.mounted) return;
    if (success) {
      AppSnackbar.showPrimary(ctx, successText);
      await _loadNotifications();
    } else {
      AppSnackbar.showErrorTheme(ctx, errorMsg ?? errorText);
    }
  }
}
