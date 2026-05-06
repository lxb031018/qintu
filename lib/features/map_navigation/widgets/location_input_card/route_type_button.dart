import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../widgets/common/qintu_pill_chip.dart';

/// 出行方式按钮
///
/// 使用 QintuPillChip 实现的选中态按钮
class RouteTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const RouteTypeButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return QintuPillChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      height: 36,
      selectedBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
      selectedTextColor: AppColors.primaryColor,
      unselectedTextColor: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
      selectedBorderColor: AppColors.primaryColor,
    );
  }
}