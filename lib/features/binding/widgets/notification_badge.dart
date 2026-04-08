import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';

/// 通知徽章按钮
/// 
/// 显示在 AppBar 上，带有未读数量徽章的通知图标
class NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: onTap,
          tooltip: AppStrings.bindingRequests,
          iconSize: 24,
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: _buildBadge(context),
          ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.errorColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
          width: 1.5,
        ),
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
