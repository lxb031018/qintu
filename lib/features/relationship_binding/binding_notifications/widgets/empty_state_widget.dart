import 'package:flutter/material.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_spacings.dart';
import '../../../../../theme/app_text_styles.dart';

/// ============================================
/// 通用空状态组件
///
/// 用于列表页面无数据时显示，支持自定义图标、文案和副文案
/// ============================================

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;
  final double iconSize;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.subMessage,
    this.iconSize = 80,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? AppColors.grey400,
          ),
          SizedBox(height: AppSpacings.lg),
          Text(
            message,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.grey600,
            ),
          ),
          if (subMessage != null) ...[
            SizedBox(height: AppSpacings.sm),
            Text(
              subMessage!,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
