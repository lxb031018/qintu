import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_spacings.dart';

/// ============================================
/// 历史选择操作栏组件
///
/// 在历史选择模式下显示，提供"全选"、"清除"操作
/// ============================================

class HistorySelectionBar extends StatelessWidget {
  final VoidCallback onSelectAll;
  final VoidCallback onDeleteSelected;
  final VoidCallback onExitSelectionMode;

  const HistorySelectionBar({
    super.key,
    required this.onSelectAll,
    required this.onDeleteSelected,
    required this.onExitSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.md,
        vertical: AppSpacings.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onSelectAll,
            child: const Text(
              '全选',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacings.lg),
          GestureDetector(
            onTap: onDeleteSelected,
            child: const Text(
              '清除',
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onExitSelectionMode,
            child: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}