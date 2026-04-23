import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_spacings.dart';

/// ============================================
/// 关闭按钮
/// ============================================

class LocationCloseButton extends StatelessWidget {
  final VoidCallback? onTap;

  const LocationCloseButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacings.xs),
        decoration: const BoxDecoration(
          color: AppColors.grey200,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close,
          size: 16,
          color: AppColors.grey600,
        ),
      ),
    );
  }
}
