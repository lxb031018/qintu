import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/binding_provider.dart';
import '../../../../../constants/app_strings.dart';
import 'sent_request_card.dart';
import 'empty_state_widget.dart';

/// ============================================
/// 发出的绑定请求 Tab
///
/// 显示我发出的绑定请求列表（不包括被拒绝的）
/// ============================================

class SentRequestsTab extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function(int requestId) onCancel;

  const SentRequestsTab({
    super.key,
    required this.onRefresh,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BindingProvider>(
      builder: (context, provider, child) {
        // 过滤出非被拒绝的请求
        final requests = provider.sentRequests.where((r) => !r.isRejected).toList();

        // 加载中
        if (provider.sentRequestsState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 请求列表（空状态也在 RefreshIndicator 内部）
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: requests.isEmpty
              ? _buildEmptyList(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length + 1,
                  itemBuilder: (context, index) {
                    if (index == requests.length) {
                      return _buildExpireHint(context);
                    }
                    final request = requests[index];
                    return SentRequestCard(
                      request: request,
                      onCancel: (requestId) => onCancel(requestId),
                    );
                  },
                ),
        );
      },
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
            icon: Icons.send_outlined,
            message: AppStrings.noSentRequests,
            subMessage: '30 天后自动清理',
          ),
        ),
      ),
    );
  }

  /// 底部过期提示
  Widget _buildExpireHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        '30 天后自动清理',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).hintColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
