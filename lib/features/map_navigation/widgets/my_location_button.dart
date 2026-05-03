import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/common/qintu_pill_chip.dart';

/// ============================================
/// "我的位置"按钮
///
/// 独立的便捷按钮，点击后直接将 GPS 位置填入当前焦点的输入框。
/// ============================================

class MyLocationButton extends StatelessWidget {
  final VoidCallback? onTap;

  const MyLocationButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return QintuPillChip(
      label: '我的位置',
      icon: Icons.my_location,
      onTap: onTap,
      height: 28,
      unselectedTextColor: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
    );
  }
}