import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_strings.dart';
import '../../../providers/binding_provider.dart';
import '../../../widgets/common/tab_badge.dart';
import '../../../widgets/common/app_confirm_dialog.dart';
import '../../../utils/app_snackbar.dart';
import 'widgets/received_requests_tab.dart';
import 'widgets/sent_requests_tab.dart';
import 'widgets/rejected_requests_tab.dart';

/// ============================================
/// 绑定通知页面
///
/// 使用四层架构
/// ============================================

class BindingNotificationsPage extends StatefulWidget {
  const BindingNotificationsPage({super.key});

  @override
  State<BindingNotificationsPage> createState() => _BindingNotificationsPageState();
}

class _BindingNotificationsPageState extends State<BindingNotificationsPage>
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
    final notifier = context.read<BindingNotifier>();
    await notifier.loadPendingRequests();
    await notifier.loadSentRequests();
  }

  @override
  Widget build(BuildContext context) {
    final bindingState = context.watch<BindingNotifier>().state;
    final sentRequests = bindingState.sentRequests;
    final pendingCount = sentRequests.where((r) => r.isPending).length;
    final receivedCount = bindingState.pendingRequestsState.data?.length ?? 0;
    final rejectedCount = sentRequests.where((r) => r.isRejected).length;

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
                  _buildTab(Icons.logout_rounded, AppStrings.sentRequests, pendingCount),
                  _buildTab(Icons.login_rounded, AppStrings.receivedRequests, receivedCount),
                  _buildTab(Icons.cancel_outlined, AppStrings.rejectedRequests, rejectedCount),
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

  /// 构建带角标的 Tab
  Widget _buildTab(IconData icon, String label, int count) {
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
  }

  /// 确认绑定请求
  Future<void> _confirmRequest(int requestId) async {
    final notifier = context.read<BindingNotifier>();
    final success = await notifier.confirmRequest(requestId);
    if (!mounted) return;
    _handleOperationResult(
      context,
      success,
      context.read<BindingNotifier>().state.bindingsState.errorMessage,
      AppStrings.acceptBindingRequestSuccess,
      AppStrings.acceptBindingRequestFailed,
    );
  }

  /// 拒绝绑定请求
  Future<void> _rejectRequest(int requestId) async {
    final notifier = context.read<BindingNotifier>();
    final success = await notifier.rejectRequest(requestId);
    if (!mounted) return;
    _handleOperationResult(
      context,
      success,
      context.read<BindingNotifier>().state.bindingsState.errorMessage,
      AppStrings.rejectBindingRequestSuccess,
      AppStrings.rejectBindingRequestFailed,
    );
  }

  /// 取消发出的请求
  Future<void> _cancelRequest(int requestId) async {
    final ctx = context;
    final notifier = ctx.read<BindingNotifier>();

    AppConfirmDialog.show(
      ctx,
      title: AppStrings.cancelRequest,
      message: AppStrings.confirmCancelRequest,
      confirmText: AppStrings.confirmCancel,
      confirmColor: Theme.of(ctx).colorScheme.error,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        final success = await notifier.cancelSentRequest(requestId);
        if (!ctx.mounted) return;
        _handleOperationResult(
          ctx,
          success,
          ctx.read<BindingNotifier>().state.lastErrorMessage,
          AppStrings.requestCancelled,
          AppStrings.cancelRequestFailed,
        );
      },
    );
  }

  /// 统一处理操作结果
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
