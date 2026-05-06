import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_spacings.dart';

/// ============================================
/// 关闭按钮组件
/// 用于地图导航页面中的位置信息面板关闭操作
/// ============================================

/// 位置关闭按钮
/// 一个圆形的关闭按钮，带有灰色背景和灰色关闭图标
class LocationCloseButton extends StatelessWidget {
  /// 点击回调函数
  /// 当用户点击按钮时触发，通常用于关闭位置信息面板
  final VoidCallback? onTap;

  /// 创建关闭按钮
  /// 
  /// [key] Widget 的唯一标识
  /// [onTap] 点击时的回调函数
  const LocationCloseButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 内边距，使用统一的间距规范
        padding: const EdgeInsets.all(AppSpacings.xs),
        // 背景样式：圆形灰色背景
        decoration: const BoxDecoration(
          color: AppColors.grey200,
          shape: BoxShape.circle,
        ),
        // 关闭图标
        child: const Icon(
          Icons.close,
          size: 16,
          color: AppColors.grey600,
        ),
      ),
    );
  }
}
