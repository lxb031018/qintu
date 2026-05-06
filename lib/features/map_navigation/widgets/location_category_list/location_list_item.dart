import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_spacings.dart';

/// ============================================
/// 位置列表项组件
/// 
/// 用于显示单个位置信息的列表项，包含：
/// - 左侧图标
/// - 标题（位置名称）
/// - 副标题（位置地址，可选）
/// - 右侧箭头指示器
/// 
/// 支持点击交互，点击时触发回调函数
/// ============================================

class LocationListItem extends StatelessWidget {
  /// 左侧显示的图标
  final IconData icon;
  
  /// 图标的颜色
  final Color iconColor;
  
  /// 标题文本（位置名称）
  final String title;
  
  /// 副标题文本（位置地址）
  final String subtitle;
  
  /// 点击回调函数
  final VoidCallback onTap;

  const LocationListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 判断当前是否为暗黑模式
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      // 点击回调
      onTap: onTap,
      // 圆角边框
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        // 内边距：水平方向较大，垂直方向较小
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.sm,
          vertical: AppSpacings.xs,
        ),
        child: Row(
          children: [
            // 左侧图标
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: AppSpacings.sm),
            // 中间内容区（标题 + 副标题）
            Expanded(
              child: Column(
                // 左对齐
                crossAxisAlignment: CrossAxisAlignment.start,
                // 最小高度
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题文本
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
                    ),
                  ),
                  // 副标题文本（仅在非空时显示）
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                ],
              ),
            ),
            // 右侧箭头指示器
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
