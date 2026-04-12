import 'package:flutter/material.dart';
import '../../../../providers/binding_provider.dart';
import '../../../../utils/date_utils.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../utils/phone_utils.dart';

/// ============================================
/// 我发出的绑定请求卡片
///
/// 显示请求状态、对方信息、过期提醒
/// 支持取消 pending 状态的请求
/// ============================================

class SentRequestCard extends StatelessWidget {
  final SentRequest request;
  final Function(int requestId) onCancel;

  const SentRequestCard({
    super.key,
    required this.request,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    // 🌟 后端已脱敏，直接使用，不再二次脱敏
    final maskedPhone = request.receiverPhone ?? '未知';
    final receiverName = request.receiverNickname ?? '未知用户';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 对方信息 + 状态标签
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(context).withValues(alpha: 0.1),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiverName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        maskedPhone,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // 状态信息
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 16,
                  color: _getStatusColor(context),
                ),
                const SizedBox(width: 8),
                Text(
                  request.statusText,
                  style: TextStyle(
                    fontSize: 13,
                    color: _getStatusColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 发送时间
            Text(
              AppStrings.sentAtText(request.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey500,
              ),
            ),
            // 过期时间（仅 pending 状态显示，被拒绝的也显示）
            if (request.isPending || request.isRejected)
              Text(
                _formatExpireText(),
                style: TextStyle(
                  fontSize: 12,
                  color: request.isExpiringSoon ? AppColors.warningColor : AppColors.grey500,
                  fontWeight: request.isExpiringSoon ? FontWeight.w500 : null,
                ),
              ),
            // 取消按钮（仅 pending 状态显示）
            if (request.isPending) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showCancelConfirm(context),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text(AppStrings.cancelRequestButton),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.grey700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 状态徽章
  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(context).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        request.statusText,
        style: TextStyle(
          fontSize: 11,
          color: _getStatusColor(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(BuildContext context) {
    if (request.isPending) {
      return request.isExpiringSoon ? AppColors.warningColor : AppColors.infoColor;
    } else if (request.isRejected) {
      return AppColors.errorColor;
    } else if (request.isExpired) {
      return AppColors.disabledColor;
    } else if (request.isActive) {
      return AppColors.successColor;
    }
    return AppColors.disabledColor;
  }

  /// 获取状态图标
  IconData _getStatusIcon() {
    if (request.isPending) {
      return request.isExpiringSoon ? Icons.warning_amber_rounded : Icons.access_time;
    } else if (request.isRejected) {
      return Icons.close_outlined;
    } else if (request.isExpired) {
      return Icons.timer_outlined;
    } else if (request.isActive) {
      return Icons.check_circle_outlined;
    }
    return Icons.help_outline;
  }

  /// 过期时间文本
  String _formatExpireText() => AppDateUtils.formatRemaining(request.expiredAt);

  void _showCancelConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.cancelRequest),
          content: const Text(AppStrings.confirmCancelRequest),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppStrings.notCancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onCancel(request.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: AppColors.whiteText,
              ),
              child: const Text(AppStrings.confirmCancel),
            ),
          ],
        );
      },
    );
  }
}
