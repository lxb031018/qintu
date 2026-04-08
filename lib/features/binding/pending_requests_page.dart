import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/binding_provider.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_colors.dart';
import 'widgets/pending_request_card.dart';

/// ============================================
/// 待确认绑定请求页面
///
/// 显示所有等待接收者确认的绑定请求
/// 接收者可以选择接受或拒绝每个请求
/// ============================================

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  @override
  void initState() {
    super.initState();
    // 页面加载时获取待确认请求
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingRequests();
    });
  }

  Future<void> _loadPendingRequests() async {
    final provider = context.read<BindingProvider>();
    await provider.loadPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bindingRequests),
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingRequests,
            tooltip: AppStrings.refresh,
          ),
        ],
      ),
      body: Consumer<BindingProvider>(
        builder: (context, provider, child) {
          // 加载中
          if (provider.pendingRequestsState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 错误状态
          if (provider.pendingRequestsState.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.pendingRequestsState.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPendingRequests,
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          // 空状态
          if (provider.pendingRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noPendingRequests,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          // 请求列表
          return RefreshIndicator(
            onRefresh: _loadPendingRequests,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.pendingRequests.length,
              itemBuilder: (context, index) {
                final request = provider.pendingRequests[index];
                return PendingRequestCard(
                  request: request,
                  onAccept: (requestId) => _confirmRequest(requestId),
                  onReject: (requestId) => _rejectRequest(requestId),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmRequest(int requestId) async {
    final provider = context.read<BindingProvider>();
    final success = await provider.confirmRequest(requestId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.acceptBindingRequestSuccess),
          backgroundColor: AppColors.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? AppStrings.acceptBindingRequestFailed),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  Future<void> _rejectRequest(int requestId) async {
    final provider = context.read<BindingProvider>();
    final success = await provider.rejectRequest(requestId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.rejectBindingRequestSuccess),
          backgroundColor: AppColors.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? AppStrings.rejectBindingRequestFailed),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }
}
