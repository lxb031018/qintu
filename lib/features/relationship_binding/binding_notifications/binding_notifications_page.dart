import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_strings.dart';
import '../provider/binding_notifier.dart';
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
                  onRefresh: () => _loadNotifications(),
                  onCancel: _cancelRequest,
                ),
                ReceivedRequestsTab(
                  onRefresh: () => _loadNotifications(),
                  onConfirm: (id) => _confirmRequest(id),
                  onReject: (id) => _rejectRequest(id),
                ),
                RejectedRequestsTab(
                  onRefresh: () => _loadNotifications(),
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
  Future<void> _confirmRequest(String senderUserId) =>
      _runBindingOperation(
        operation: () =>
            ref.read(bindingProvider.notifier).confirmRequest(senderUserId),
        successText: AppStrings.acceptBindingRequestSuccess,
        failedText: AppStrings.acceptBindingRequestFailed,
      );

  /// 拒绝绑定请求
  Future<void> _rejectRequest(String senderUserId) =>
      _runBindingOperation(
        operation: () =>
            ref.read(bindingProvider.notifier).rejectRequest(senderUserId),
        successText: AppStrings.rejectBindingRequestSuccess,
        failedText: AppStrings.rejectBindingRequestFailed,
      );

  /// 取消发出的请求
  Future<void> _cancelRequest(String partnerUserId) async {
    AppConfirmDialog.show(
      context,
      title: AppStrings.cancelRequest,
      message: AppStrings.confirmCancelRequest,
      confirmText: AppStrings.confirmCancel,
      confirmColor: Theme.of(context).colorScheme.error,
      confirmTextColor: Colors.white,
      onConfirm: () => _runBindingOperation(
        operation: () =>
            ref.read(bindingProvider.notifier).cancelSentRequest(partnerUserId),
        successText: AppStrings.requestCancelled,
        failedText: AppStrings.cancelRequestFailed,
      ),
    );
  }

  /// 统一执行绑定操作并处理结果
  ///
  /// 成功：snackbar 提示 + 刷新列表；失败：snackbar 错误提示。
  Future<void> _runBindingOperation({
    required Future<bool> Function() operation,
    required String successText,
    required String failedText,
  }) async {
    final success = await operation();
    if (!mounted) return;
    if (success) {
      AppSnackbar.showPrimary(context, successText);
      await _loadNotifications();
    } else {
      // notifier 内部不统一设置 errorMessage（见各 confirm/reject/cancel 方法），
      // 失败时统一回退到 failedText 占位文案。
      AppSnackbar.showErrorTheme(context, failedText);
    }
  }
}
