import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/binding_provider.dart';
import '../../constants/app_strings.dart';
import 'widgets/binding_stats_card.dart';
import 'widgets/binding_list_view.dart';
import 'widgets/add_binding_button.dart';
import 'widgets/empty_binding_view.dart';
import 'widgets/error_view.dart';
import 'binding_controller.dart';

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
  /// 懒加载 Controller（每次创建新实例，因为 context 可能变化）
  BindingController get _controller => BindingController(
        context: context,
        provider: context.read<BindingProvider>(),
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// 加载数据
  Future<void> _loadData() async {
    final provider = context.read<BindingProvider>();
    await provider.loadBindings();
    await provider.loadPendingRequests();
    await provider.loadSentRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopActionBar(),
            _buildContentArea(),
            _buildBottomButton(),
          ],
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
    return Consumer<BindingProvider>(
      builder: (context, provider, child) {
        // 计算总通知数：收到的请求 + 被拒绝的请求
        final pendingCount = provider.pendingRequestsCount;
        final rejectedCount = provider.sentRequests.where((r) => r.isRejected).length;
        final totalCount = pendingCount + rejectedCount;
        final hasNotifications = totalCount > 0;

        return Stack(
          children: [
            IconButton(
              icon: Icon(hasNotifications ? Icons.notifications_active : Icons.notifications_none_outlined),
              onPressed: () => _controller.showNotificationCenter(),
              tooltip: AppStrings.notificationCenterTooltip,
            ),
            if (hasNotifications) _buildBadge(totalCount, Colors.red),
          ],
        );
      },
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

  /// 构建主内容区（支持下拉刷新）
  Widget _buildContentArea() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () => _loadData(),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _buildContent(availableHeight: constraints.maxHeight),
            ),
          );
        },
      ),
    );
  }

  /// 构建内容区域（根据状态显示不同视图）
  Widget _buildContent({required double availableHeight}) {
    return Consumer<BindingProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return ErrorView(
            error: provider.error!,
            onRetry: () => provider.loadBindings(),
            onClearError: () => provider.clearError(),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BindingStatsCard(provider: provider),
            _buildBindingList(provider, availableHeight),
          ],
        );
      },
    );
  }

  /// 构建绑定列表或空状态
  Widget _buildBindingList(BindingProvider provider, double availableHeight) {
    final displayBindings = provider.allBindings;

    // 【空状态】直接显示空状态，不显示加载动画（由 RefreshIndicator 处理）
    if (displayBindings.isEmpty) {
      return SizedBox(
        height: availableHeight,
        child: const Center(child: EmptyBindingView()),
      );
    }

    return BindingListView(
      bindings: displayBindings,
      onRevoke: (bindingId) => _controller.confirmRevoke(bindingId),
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButton() {
    return Consumer<BindingProvider>(
      builder: (context, provider, child) {
        return AddBindingButton(
          provider: provider,
          onPressed: () => _controller.showPhoneBindingDialog(),
        );
      },
    );
  }
}
