import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';

class QintuPillChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final double height;
  final double? minWidth;
  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;

  const QintuPillChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.height = 32,
    this.minWidth,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isSelected
        ? (selectedBackgroundColor ?? AppColors.primaryColor)
        : (unselectedBackgroundColor ?? (isDark ? AppColors.darkCardBackground : AppColors.grey100));

    final txtColor = isSelected
        ? (selectedTextColor ?? Colors.white)
        : (unselectedTextColor ?? (isDark ? AppColors.darkTextColor : AppColors.textColor));

    final borderClr = isSelected
        ? (selectedBorderColor ?? Colors.transparent)
        : (unselectedBorderColor ?? (isDark ? AppColors.darkDividerColor : AppColors.grey300));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        constraints: BoxConstraints(minWidth: minWidth ?? 0),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.all(AppRadii.xlarge),
          border: Border.all(color: borderClr, width: 1),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: txtColor),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: txtColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
