import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_spacings.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';

/// 错误视图
class ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onClearError;

  const ErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onClearError,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.grey400 : AppColors.grey700;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacings.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.errorColor,
            ),
            SizedBox(height: AppSpacings.lg),
            Text(
              AppStrings.loadFailed,
              style: AppTextStyles.error.copyWith(
                color: titleColor,
              ),
            ),
            SizedBox(height: AppSpacings.sm),
            Text(
              error,
              style: const TextStyle(color: AppColors.errorColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacings.xl),
            AppButton.primary(
              text: AppStrings.retry,
              icon: Icons.refresh,
              onPressed: onRetry,
              minWidth: 160,
              size: AppButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
