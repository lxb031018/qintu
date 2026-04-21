import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/constants/app_strings.dart';
import 'package:qintu/providers/binding_provider.dart';
import 'package:qintu/widgets/common/app_confirm_dialog.dart';
import 'package:qintu/utils/app_snackbar.dart';
import 'widgets/binding_stats_card.dart';
import 'widgets/binding_list_view.dart';
import 'widgets/add_binding_button.dart';
import 'widgets/error_view.dart';
import 'widgets/phone_binding_dialog.dart';
import 'binding_notifications/binding_notifications_page.dart';

/// ============================================
/// 关系绑定 Tab
///
/// 使用四层架构
/// ============================================

class RelationshipBindingTab extends ConsumerStatefulWidget {
  const RelationshipBindingTab({super.key});

  @override
  ConsumerState<RelationshipBindingTab> createState() => _RelationshipBindingTabState();
}

class _RelationshipBindingTabState extends ConsumerState<RelationshipBindingTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// 加载数据
  Future<void> _loadData() async {
    final notifier = ref.read(bindingProvider.notifier);
    await notifier.loadBindings();
    await notifier.loadPendingRequests();
    await notifier.loadSentRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _loadData(),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildTopActionBar()),
              SliverToBoxAdapter(child: _buildContent()),
              SliverToBoxAdapter(child: _buildBottomButton()),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建顶部操作栏
  Widget _buildTopActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _buildNotificationButton(),
          ),
          Text(
            AppStrings.pullToRefresh,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建通知按钮（带角标）
  Widget _buildNotificationButton() {
    final bindingState = ref.watch(bindingProvider);
    final pendingCount = bindingState.pendingRequestsState.data?.length ?? 0;
    final rejectedCount = bindingState.sentRequests.where((r) => r.isRejected).length;
    final totalCount = pendingCount + rejectedCount;
    final hasNotifications = totalCount > 0;

    return Stack(
      children: [
        IconButton(
          icon: Icon(hasNotifications ? Icons.notifications_active : Icons.notifications_none_outlined),
          onPressed: _showNotificationCenter,
          tooltip: AppStrings.notificationCenterTooltip,
        ),
        if (hasNotifications) _buildBadge(totalCount, Colors.red),
      ],
    );
  }

  /// 构建角标组件
  Widget _buildBadge(int count, Color color) {
    return Positioned(
      right: 6,
      top: 6,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    final bindingState = ref.watch(bindingProvider);
    final error = bindingState.bindingsState.errorMessage;

    if (error != null) {
      return ErrorView(
        error: error,
        onRetry: () => ref.read(bindingProvider.notifier).loadBindings(),
        onClearError: () => ref.read(bindingProvider.notifier).clearError(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BindingStatsCard(),
        _buildBindingList(bindingState),
      ],
    );
  }

  /// 构建绑定列表或空状态
  Widget _buildBindingList(BindingListState bindingState) {
    final displayBindings = bindingState.bindingsState.data ?? [];
    if (displayBindings.isEmpty) return const SizedBox.shrink();

    return BindingListView(
      bindings: displayBindings,
      onRevoke: (bindingId) => _confirmRevoke(bindingId),
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButton() {
    return AddBindingButton(
      onPressed: _showPhoneBindingDialog,
    );
  }

  /// 显示手机号绑定对话框
  void _showPhoneBindingDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => PhoneBindingDialog(parentContext: context),
    );
  }

  /// 显示绑定通知页面
  void _showNotificationCenter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BindingNotificationsPage(),
      ),
    );
  }

  /// 确认解除绑定（带二次确认对话框）
  Future<void> _confirmRevoke(int bindingId) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.revokeBinding,
      message: AppStrings.revokeBindingConfirm,
      confirmText: AppStrings.revokeBinding,
      confirmColor: Theme.of(context).colorScheme.error,
      confirmTextColor: Colors.white,
    );

    if (confirmed != true) return;

    if (!mounted) return;

    final bindingState = ref.read(bindingProvider);
    final notifier = ref.read(bindingProvider.notifier);
    final success = await notifier.revokeBinding(bindingId);

    if (!mounted) return;

    if (success) {
      AppSnackbar.showPrimary(context, AppStrings.revokeBindingSuccess);
    } else {
      AppSnackbar.showErrorTheme(
        context,
        bindingState.bindingsState.errorMessage ?? AppStrings.revokeBindingFailed,
      );
    }
  }
}
