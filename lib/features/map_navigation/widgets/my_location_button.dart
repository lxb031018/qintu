import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_spacings.dart';

/// ============================================
/// "我的位置"按钮
///
/// 独立的便捷按钮，点击后直接将 GPS 位置填入当前焦点的输入框。
/// 不使用 LocationCategoryButton 通用框架，不显示列表项。
/// ============================================

class MyLocationButton extends StatelessWidget {
  final VoidCallback? onTap;

  const MyLocationButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.sm,
          vertical: AppSpacings.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.my_location,
              size: 16,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
            ),
            const SizedBox(width: 4),
            Text(
              '我的位置',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}