import 'package:flutter/material.dart';
import '../../../models/binding.dart';
import '../../../utils/phone_utils.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../theme/app_text_styles.dart';

/// 绑定卡片
class BindingCard extends StatelessWidget {
  final Binding binding;
  final VoidCallback onRevoke;

  const BindingCard({
    super.key,
    required this.binding,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSender = binding.myRole == MyRole.sender;
    final statusColor = _getStatusColor(binding.status);
    final statusText = _getStatusText(binding.status);
    final avatarBackground = isSender
        ? Colors.orange.shade100
        : Colors.green.shade100;
    final avatarIconColor = isSender ? Colors.orange : Colors.green;
    final roleTextColor = isSender ? Colors.orange : Colors.green;
    // 手机号脱敏显示
    final maskedPhone = PhoneUtils.maskPhone(binding.partnerNickname ?? AppStrings.unknownUser);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarBackground,
          child: Icon(
            isSender ? Icons.person : Icons.group,
            color: avatarIconColor,
          ),
        ),
        title: Text(
          maskedPhone,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              isSender ? AppStrings.receiver : AppStrings.sender,
              style: AppTextStyles.statusTag.copyWith(
                color: roleTextColor,
              ),
            ),
            if (binding.remark != null && binding.remark!.isNotEmpty)
              Text(
                '${AppStrings.remark}：${binding.remark}',
                style: AppTextStyles.statusTag.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: statusColor,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              statusText,
              style: AppTextStyles.captionSmall.copyWith(
                color: statusColor,
              ),
            ),
            const SizedBox(width: 8),
            if (binding.status == BindingStatus.active)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.errorColor),
                onPressed: onRevoke,
                tooltip: AppStrings.revokeBinding,
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BindingStatus status) {
    switch (status) {
      case BindingStatus.active:
        return AppColors.successColor;
      case BindingStatus.pending:
        return Colors.orange;
      case BindingStatus.expired:
        return Colors.grey;
      case BindingStatus.revoked:
        return AppColors.errorColor;
    }
  }

  String _getStatusText(BindingStatus status) {
    switch (status) {
      case BindingStatus.active:
        return AppStrings.active;
      case BindingStatus.pending:
        return AppStrings.pending;
      case BindingStatus.expired:
        return AppStrings.expired;
      case BindingStatus.revoked:
        return AppStrings.revoked;
    }
  }
}
