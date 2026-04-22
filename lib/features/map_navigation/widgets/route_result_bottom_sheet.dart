import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';

/// ============================================
/// 路线规划结果底部弹窗
///
/// 纯 UI 组件，显示路线规划结果供用户选择
/// ============================================

class RouteResultBottomSheet extends StatelessWidget {
  /// 路线选项数据模型（简化版，真实数据由 Provider 提供）
  final List<RouteResultItem> routes;
  final int selectedIndex;
  final ValueChanged<int>? onRouteSelected;
  final VoidCallback? onClose;

  const RouteResultBottomSheet({
    super.key,
    this.routes = const [],
    this.selectedIndex = 0,
    this.onRouteSelected,
    this.onClose,
  });

  /// 显示底部弹窗的静态方法
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RouteResultBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: AppRadii.large,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动条
          _buildDragHandle(isDark),
          // 标题栏
          _buildHeader(isDark),
          // 路线列表
          Flexible(
            child: routes.isEmpty
                ? _buildEmptyState(isDark)
                : _buildRouteList(isDark),
          ),
        ],
      ),
    );
  }

  /// 拖动条
  Widget _buildDragHandle(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacings.sm),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkDividerColor : AppColors.grey300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 标题栏
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.md,
        vertical: AppSpacings.md,
      ),
      child: Row(
        children: [
          Text(
            '路线规划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextColor : AppColors.textColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacings.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.route,
            size: 48,
            color: isDark ? AppColors.darkLightTextColor : AppColors.grey400,
          ),
          const SizedBox(height: AppSpacings.sm),
          Text(
            '暂无路线规划结果',
            style: TextStyle(
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 路线列表
  Widget _buildRouteList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacings.md),
      shrinkWrap: true,
      itemCount: routes.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacings.sm),
      itemBuilder: (context, index) => _RouteCard(
        route: routes[index],
        isSelected: index == selectedIndex,
        onTap: () => onRouteSelected?.call(index),
      ),
    );
  }
}

/// ============================================
/// 路线选项卡片
/// ============================================

class _RouteCard extends StatelessWidget {
  final RouteResultItem route;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RouteCard({
    required this.route,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacings.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkBackgroundColor : AppColors.grey50),
          borderRadius: BorderRadius.all(AppRadii.medium),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 路线信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 距离和耗时
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.straighten,
                        label: route.formattedDistance,
                        isDark: isDark,
                      ),
                      const SizedBox(width: AppSpacings.md),
                      _InfoChip(
                        icon: Icons.access_time,
                        label: route.formattedDuration,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacings.xs),
                  // 策略
                  Text(
                    route.strategy,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            // 选中指示
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// 信息标签
/// ============================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.primaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextColor : AppColors.textColor,
          ),
        ),
      ],
    );
  }
}

/// ============================================
/// 路线结果数据模型（供 UI 使用）
/// ============================================

class RouteResultItem {
  final String distance;
  final String formattedDistance;
  final String duration;
  final String formattedDuration;
  final String strategy;
  final double? tolls;

  const RouteResultItem({
    required this.distance,
    required this.formattedDistance,
    required this.duration,
    required this.formattedDuration,
    required this.strategy,
    this.tolls,
  });
}