import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_strings.dart';
import '../../../providers/binding_provider.dart';
import '../../../widgets/common/tab_badge.dart';
import '../../../widgets/common/app_confirm_dialog.dart';
import '../../../utils/ui/app_snackbar.dart';
import 'widgets/received_requests_tab.dart';
import 'widgets/sent_requests_tab.dart';
import 'widgets/rejected_requests_tab.dart';

/// ============================================
/// 绑定通知页面
///
/// 使用四层架构
/// ============================================

class BindingNotificationsPage extends ConsumerStatefulWidget {
  const BindingNotificationsPage({super.key});

  @override
  ConsumerState<BindingNotificationsPage> createState() => _BindingNotificationsPageState();
}

class _BindingNotificationsPageState extends ConsumerState<BindingNotificationsPage>
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
    final notifier = ref.read(bindingProvider.notifier);
    await notifier.loadPendingRequests();
    await notifier.loadSentRequests();
  }

  @override
  Widget build(BuildContext context) {
    final bindingState = ref.watch(bindingProvider);
    final sentRequests = bindingState.sentRequests;
    final pendingCount = sentRequests.where((r) => r.isPending).length;
    final receivedCount = bindingState.pendingRequestsState.data?.length ?? 0;
    final rejectedCount = sentRequests.where((r) => r.isRejected).length;

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                _buildCustomTabBar(
                  context,
                  pendingCount: pendingCount,
                  receivedCount: receivedCount,
                  rejectedCount: rejectedCount,
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
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
          ),
        ],
      ),
    );
  }

  /// 构建自定义 Tab Bar（避免 Flutter 内置 Tab 的 1px 溢出问题）
  Widget _buildCustomTabBar(
    BuildContext context, {
    required int pendingCount,
    required int receivedCount,
    required int rejectedCount,
  }) {
    final tabs = [
      (Icons.logout_rounded, AppStrings.sentRequests, pendingCount),
      (Icons.login_rounded, AppStrings.receivedRequests, receivedCount),
      (Icons.cancel_outlined, AppStrings.rejectedRequests, rejectedCount),
    ];

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final (icon, label, count) = tabs[i];
              final isSelected = _tabController.index == i;
              final tabColor = isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).hintColor;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 20, color: tabColor),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: tabColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 3),
                              TabBadge(count: count),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  /// 确认绑定请求
  Future<void> _confirmRequest(int requestId) async {
    final notifier = ref.read(bindingProvider.notifier);
    final success = await notifier.confirmRequest(requestId);
    if (!mounted) return;
    _handleOperationResult(
      context,
      success,
      ref.read(bindingProvider).bindingsState.errorMessage,
      AppStrings.acceptBindingRequestSuccess,
      AppStrings.acceptBindingRequestFailed,
    );
  }

  /// 拒绝绑定请求
  Future<void> _rejectRequest(int requestId) async {
    final notifier = ref.read(bindingProvider.notifier);
    final success = await notifier.rejectRequest(requestId);
    if (!mounted) return;
    _handleOperationResult(
      context,
      success,
      ref.read(bindingProvider).bindingsState.errorMessage,
      AppStrings.rejectBindingRequestSuccess,
      AppStrings.rejectBindingRequestFailed,
    );
  }

  /// 取消发出的请求
  Future<void> _cancelRequest(int requestId) async {
    final notifier = ref.read(bindingProvider.notifier);

    AppConfirmDialog.show(
      context,
      title: AppStrings.cancelRequest,
      message: AppStrings.confirmCancelRequest,
      confirmText: AppStrings.confirmCancel,
      confirmColor: Theme.of(context).colorScheme.error,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        final success = await notifier.cancelSentRequest(requestId);
        if (!mounted) return;
        _handleOperationResult(
          context,
          success,
          ref.read(bindingProvider).lastErrorMessage,
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
