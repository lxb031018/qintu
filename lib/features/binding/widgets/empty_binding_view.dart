import 'package:flutter/material.dart';
import '../../../constants/app_strings.dart';
import '../../../theme/app_text_styles.dart';

/// 空绑定提示
class EmptyBindingView extends StatelessWidget {
  const EmptyBindingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    final titleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final subtitleColor = isDark ? Colors.grey.shade500 : Colors.grey.shade500;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link_off,
            size: 80,
            color: iconColor,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noBinding,
            style: AppTextStyles.error.copyWith(
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.addNewBinding,
            style: AppTextStyles.locationTitle.copyWith(
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
