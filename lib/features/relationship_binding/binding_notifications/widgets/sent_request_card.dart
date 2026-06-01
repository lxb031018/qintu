import 'package:flutter/material.dart';
import 'package:qintu/models/binding/binding.dart';
import '../../../../utils/platform/date_utils.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../constants/app_spacings.dart';
import '../../../../constants/app_radii.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../widgets/common/app_confirm_dialog.dart';
import '../../models/binding_status_display.dart';

/// ============================================
/// 我发出的绑定请求卡片
///
/// 显示请求状态、对方信息、过期提醒
/// 支持取消 pending 状态的请求
/// ============================================

class SentRequestCard extends StatelessWidget {
  final SentRequest request;
  final Function(String) onCancel;

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
    final statusColor = BindingStatusDisplay.colorFor(request);
    final statusIcon = BindingStatusDisplay.iconFor(request);

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
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiverName,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacings.xs),
                      Text(
                        maskedPhone,
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context, statusColor),
              ],
            ),
            SizedBox(height: AppSpacings.md),
            const Divider(height: 1),
            SizedBox(height: AppSpacings.md),
            // 状态信息
            Row(
              children: [
                Icon(
                  statusIcon,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  request.statusText,
                  style: AppTextStyles.statusTag.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacings.sm),
            // 发送时间
            Text(
              AppStrings.sentAtText(request.createdAt),
              style: AppTextStyles.statusTag.copyWith(
                color: AppColors.grey500,
              ),
            ),
            // 过期时间（仅 pending 状态显示，被拒绝的也显示）
            if (request.isPending || request.isRejected)
              Text(
                _formatExpireText(),
                style: AppTextStyles.statusTag.copyWith(
                  color: request.isExpiringSoon ? AppColors.warningColor : AppColors.grey500,
                  fontWeight: request.isExpiringSoon ? FontWeight.w500 : null,
                ),
              ),
            // 取消按钮（仅 pending 状态显示）
            if (request.isPending) ...[
              SizedBox(height: AppSpacings.md),
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
  Widget _buildStatusBadge(BuildContext context, Color statusColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacings.sm, vertical: AppSpacings.xs),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.all(AppRadii.medium),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        request.statusText,
        style: AppTextStyles.bottomTab.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 过期时间文本
  String _formatExpireText() {
    if (request.expiredAt == null) return AppStrings.requestExpired;
    return AppDateUtils.formatRemaining(request.expiredAt!);
  }

  void _showCancelConfirm(BuildContext context) {
    AppConfirmDialog.show(
      context,
      title: AppStrings.cancelRequest,
      message: AppStrings.confirmCancelRequest,
      confirmText: AppStrings.confirmCancel,
      confirmColor: AppColors.errorColor,
      confirmTextColor: AppColors.whiteText,
      onConfirm: () => onCancel(request.receiverUserID ?? ''),
    );
  }
}
