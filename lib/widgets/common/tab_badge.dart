import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// ============================================
/// Tab 角标组件
///
/// 显示在 TabBar 的 Tab 上，用于提示未读/待处理数量
/// ============================================

class TabBadge extends StatelessWidget {
  /// 角标数量（0 或负数时不显示）
  final int count;

  /// 角标颜色（默认红色）
  final Color color;

  const TabBadge({
    super.key,
    required this.count,
    this.color = AppColors.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: AppColors.whiteText,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
