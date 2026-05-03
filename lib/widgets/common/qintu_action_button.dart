import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';

class QintuActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? minWidth;

  const QintuActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.height = 36,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primaryColor;
    final txt = textColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        constraints: BoxConstraints(minWidth: minWidth ?? 100),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacings.md),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.all(AppRadii.small),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: txt),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: txt,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
