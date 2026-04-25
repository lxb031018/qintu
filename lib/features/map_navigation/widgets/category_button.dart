import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_spacings.dart';

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
    // 判断当前是否为暗黑模式
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 内边距：水平方向较大，垂直方向较小
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.sm,
          vertical: AppSpacings.xs,
        ),
        decoration: BoxDecoration(
          // 选中时显示主题色背景（透明度 10%），未选中时透明
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          // 圆角边框
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          // 行宽根据内容自适应
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Icon(
              icon,
              size: 16,
              // 选中时为主题色，未选中时根据暗黑/明亮模式显示不同颜色
              color: isSelected
                  ? AppColors.primaryColor
                  : (isDark ? AppColors.darkLightTextColor : AppColors.grey600),
            ),
            const SizedBox(width: 4),
            // 文本标签
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                // 选中时字体加粗
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                // 颜色逻辑与图标保持一致
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? AppColors.darkLightTextColor : AppColors.grey600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
