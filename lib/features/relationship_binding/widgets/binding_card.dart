import 'package:flutter/material.dart';
import '../../../models/binding/binding.dart';
import '../../../utils/phone_utils.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_spacings.dart';
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
        ? AppColors.orange100
        : AppColors.green100;
    final avatarIconColor = isSender ? AppColors.warningColor : AppColors.successColor;
    // 手机号脱敏显示
    final maskedPhone = PhoneUtils.maskPhone(binding.partnerPhone ?? '');
    // 优先使用对方昵称，其次使用备注
    final partnerDisplayName = (binding.partnerNickname != null && binding.partnerNickname!.isNotEmpty)
        ? binding.partnerNickname!
        : (binding.remark ?? AppStrings.unknownUser);

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
          partnerDisplayName,
          style: AppTextStyles.locationTitle.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacings.xs),
            Text(
              maskedPhone,
              style: AppTextStyles.statusTag.copyWith(
                color: isDark ? AppColors.grey400 : AppColors.disabledColor,
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
            SizedBox(width: AppSpacings.xs),
            Text(
              statusText,
              style: AppTextStyles.captionSmall.copyWith(
                color: statusColor,
              ),
            ),
            SizedBox(width: AppSpacings.sm),
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
        return AppColors.warningColor;
      case BindingStatus.expired:
        return AppColors.disabledColor;
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
