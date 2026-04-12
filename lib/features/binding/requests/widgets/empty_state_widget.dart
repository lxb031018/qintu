import 'package:flutter/material.dart';
import '../../../../../constants/app_colors.dart';

/// ============================================
/// 通用空状态组件
///
/// 用于列表页面无数据时显示，支持自定义图标、文案和副文案
/// ============================================

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;
  final double iconSize;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.subMessage,
    this.iconSize = 80,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
          ),
          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              subMessage!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
