import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../models/binding/binding.dart';
import '../../provider/binding_notifier.dart';
import 'binding_request_list_view.dart';
import 'pending_request_card.dart';

/// ============================================
/// 收到的绑定请求 Tab
///
/// 显示待确认/拒绝的绑定请求列表
/// ============================================

class ReceivedRequestsTab extends ConsumerWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function(String senderUserId) onConfirm;
  final Future<void> Function(String senderUserId) onReject;

  const ReceivedRequestsTab({
    super.key,
    required this.onRefresh,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bindingState = ref.watch(bindingProvider);
    return BindingRequestListView<PendingRequest>(
      requests: bindingState.pendingRequests,
      isLoading: bindingState.pendingRequestsState.isLoading,
      onRefresh: onRefresh,
      emptyIcon: Icons.notifications_none,
      emptyMessage: AppStrings.noReceivedRequests,
      itemBuilder: (context, request) => PendingRequestCard(
        request: request,
        onAccept: onConfirm,
        onReject: onReject,
      ),
    );
  }
}
