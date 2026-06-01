import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../models/binding/binding.dart';
import '../../provider/binding_notifier.dart';
import 'binding_request_list_view.dart';
import 'sent_request_card.dart';

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
    final rejectedRequests =
        bindingState.sentRequests.where((r) => r.isRejected).toList();
    return BindingRequestListView<SentRequest>(
      requests: rejectedRequests,
      isLoading: bindingState.sentRequestsState.isLoading,
      onRefresh: onRefresh,
      emptyIcon: Icons.check_circle_outline,
      emptyMessage: AppStrings.noRejectedRequests,
      itemBuilder: (context, request) => SentRequestCard(
        request: request,
        // 被拒绝的请求无法取消，传 no-op 避免误触发
        onCancel: (_) {},
      ),
    );
  }
}
