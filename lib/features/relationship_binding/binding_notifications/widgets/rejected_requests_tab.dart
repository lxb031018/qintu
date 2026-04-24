import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../providers/binding_provider.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../constants/app_spacings.dart';
import '../../../../../theme/app_text_styles.dart';
import 'sent_request_card.dart';
import 'empty_state_widget.dart';

/// ============================================
/// 被拒绝的请求 Tab
///
/// 显示我发出但被对方拒绝的绑定请求
/// ============================================

class RejectedRequestsTab extends ConsumerWidget {
  final Future<void> Function() onRefresh;

  const RejectedRequestsTab({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bindingState = ref.watch(bindingProvider);
    // 过滤出被拒绝的请求
    final rejectedRequests = bindingState.sentRequests.where((r) => r.isRejected).toList();

    // 加载中
    if (bindingState.sentRequestsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 请求列表（空状态也在 RefreshIndicator 内部）
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: rejectedRequests.isEmpty
          ? _buildEmptyList(context)
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacings.lg),
              itemCount: rejectedRequests.length + 1,
              itemBuilder: (context, index) {
                if (index == rejectedRequests.length) {
                  return _buildExpireHint(context);
                }
                final request = rejectedRequests[index];
                return SentRequestCard(
                  request: request,
                  onCancel: (requestId) {}, // 被拒绝的请求无法取消
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
            icon: Icons.check_circle_outline,
            message: AppStrings.noRejectedRequests,
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
