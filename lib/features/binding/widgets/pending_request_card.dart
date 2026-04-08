import 'package:flutter/material.dart';
import '../../../providers/binding_provider.dart';
import '../../../utils/phone_utils.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../theme/app_text_styles.dart';

/// 待确认绑定请求卡片
class PendingRequestCard extends StatelessWidget {
  final PendingRequest request;
  final Function(int) onAccept;
  final Function(int) onReject;

  const PendingRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = request.senderName ?? request.senderNickname ?? '未知用户';
    final maskedPhone = PhoneUtils.maskPhone(request.senderPhone ?? '');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 发送者信息
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        maskedPhone,
                        style: AppTextStyles.statusTag.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // 请求时间
                Text(
                  _formatTime(request.createdAt),
                  style: AppTextStyles.captionSmall.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 提示信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.bindingRequestDetailHint,
                      style: AppTextStyles.statusTag.copyWith(
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 操作按钮
            Row(
              children: [
                // 拒绝按钮
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text(AppStrings.rejectBindingRequest),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorColor,
                      side: const BorderSide(color: AppColors.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 接受按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAcceptDialog(context),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text(AppStrings.acceptBindingRequest),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${time.month}月${time.day}日';
    }
  }

  Future<void> _showAcceptDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.acceptBindingRequest),
          content: const Text(AppStrings.acceptBindingRequestConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.acceptBindingRequest),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onAccept(request.id);
    }
  }

  Future<void> _showRejectDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.rejectBindingRequest),
          content: const Text(AppStrings.rejectBindingRequestConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.rejectBindingRequest),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onReject(request.id);
    }
  }
}
