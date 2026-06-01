import 'package:flutter/material.dart';
import '../../../models/binding/binding.dart';
import '../../../utils/platform/phone_utils.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_spacings.dart';
import '../../../theme/app_text_styles.dart';
import '../models/binding_status_display.dart';

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
    final statusColor = BindingStatusDisplay.colorForBindingStatus(binding.status);
    final statusText = BindingStatusText.labelFor(binding.status);
    // 手机号脱敏显示
    final maskedPhone = PhoneUtils.maskPhone(binding.partnerPhone ?? '');
    // 优先使用我对对方的称呼，其次使用对方昵称
    final partnerDisplayName = (binding.myNameForPartner != null && binding.myNameForPartner!.isNotEmpty)
        ? binding.myNameForPartner!
        : (binding.partnerNickname ?? AppStrings.unknownUser);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.blue50,
          child: Icon(
            Icons.person,
            color: AppColors.blue700,
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
            if (binding.status == 'active')
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
}
