import 'package:flutter/material.dart';
import '../../../constants/colors/app_colors.dart';
import '../../../constants/app_spacings.dart';
import '../../../constants/app_radii.dart';
import '../../../theme/app_text_styles.dart';

/// ============================================
/// 错误提示卡片
///
/// 显示用户友好的错误信息
/// ============================================

class ErrorCard extends StatelessWidget {
  /// 错误信息
  final String message;

  /// 错误颜色
  final Color errorColor;

  const ErrorCard({
    super.key,
    required this.message,
    this.errorColor = StatusColors.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacings.xl),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.all(AppRadii.large),
        border: Border.all(
          color: errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: errorColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.error.copyWith(
                color: errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
