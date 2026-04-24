import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../providers/binding_provider.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../constants/app_spacings.dart';
import '../../../../../theme/app_text_styles.dart';
import 'pending_request_card.dart';
import 'empty_state_widget.dart';

/// ============================================
/// 收到的绑定请求 Tab
///
/// 显示待确认/拒绝的绑定请求列表
/// ============================================

class ReceivedRequestsTab extends ConsumerWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function(int requestId) onConfirm;
  final Future<void> Function(int requestId) onReject;

  const ReceivedRequestsTab({
    super.key,
    required this.onRefresh,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bindingState = ref.watch(bindingProvider);
    final requests = bindingState.pendingRequests;

    // 加载中
    if (bindingState.pendingRequestsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 请求列表（空状态也在 RefreshIndicator 内部）
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: requests.isEmpty
          ? _buildEmptyList(context)
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacings.lg),
              itemCount: requests.length + 1,
              itemBuilder: (context, index) {
                if (index == requests.length) {
                  return _buildExpireHint(context);
                }
                final request = requests[index];
                return PendingRequestCard(
                  request: request,
                  onAccept: (requestId) => onConfirm(requestId),
                  onReject: (requestId) => onReject(requestId),
                );
              },
            ),
    );
  }

  /// 构建空列表（支持下拉刷新）
  Widget _buildEmptyList(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: const Center(
          child: EmptyStateWidget(
            icon: Icons.notifications_none,
            message: AppStrings.noReceivedRequests,
            subMessage: '30 天后自动清理',
          ),
        ),
      ),
    );
  }

  /// 底部过期提示
  Widget _buildExpireHint(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacings.md),
      child: Text(
        '30 天后自动清理',
        style: AppTextStyles.bottomTab.copyWith(
          color: Theme.of(context).hintColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
