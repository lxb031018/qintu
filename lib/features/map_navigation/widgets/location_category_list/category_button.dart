import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../widgets/common/qintu_pill_chip.dart';

/// ============================================
/// 地图分类筛选按钮组件
/// 用于显示带图标的分类标签，支持选中/未选中状态切换
/// ============================================

class LocationCategoryButton extends StatelessWidget {
  /// 按钮显示的文本标签
  final String label;

  /// 按钮显示的图标
  final IconData icon;

  /// 是否为选中状态
  final bool isSelected;

  /// 点击回调函数
  final VoidCallback onTap;

  const LocationCategoryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return QintuPillChip(
      label: label,
      icon: icon,
      isSelected: isSelected,
      onTap: onTap,
      height: 28,
      selectedBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
      selectedTextColor: AppColors.primaryColor,
      unselectedTextColor: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
      selectedBorderColor: AppColors.primaryColor,
      unselectedBorderColor: Colors.transparent,
    );
  }
}
