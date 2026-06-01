import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../models/binding/binding.dart';
import '../../provider/binding_notifier.dart';
import 'binding_request_list_view.dart';
import 'sent_request_card.dart';

/// ============================================
/// 发出的绑定请求 Tab
///
/// 显示我发出的绑定请求列表（不包括被拒绝的）
/// ============================================

class SentRequestsTab extends ConsumerWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function(String partnerUserId) onCancel;

  const SentRequestsTab({
    super.key,
    required this.onRefresh,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bindingState = ref.watch(bindingProvider);
    // 过滤出非被拒绝的请求
    final requests = bindingState.sentRequests.where((r) => !r.isRejected).toList();
    return BindingRequestListView<SentRequest>(
      requests: requests,
      isLoading: bindingState.sentRequestsState.isLoading,
      onRefresh: onRefresh,
      emptyIcon: Icons.send_outlined,
      emptyMessage: AppStrings.noSentRequests,
      itemBuilder: (context, request) => SentRequestCard(
        request: request,
        onCancel: onCancel,
      ),
    );
  }
}
