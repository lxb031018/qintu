import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../../../widgets/common/tab_badge.dart';

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
            right: AppSpacings.sm,
            top: AppSpacings.sm,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).appBarTheme.backgroundColor ?? AppColors.cardBackground,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.all(AppRadii.small),
              ),
              child: TabBadge(count: count),
            ),
          ),
      ],
    );
  }
}
