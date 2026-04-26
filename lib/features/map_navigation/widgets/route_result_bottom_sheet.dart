import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../models/amap_routing_models.dart';
import '../models/map_overlay_models.dart';

/// ============================================
/// 路线规划结果底部弹窗
///
/// 纯 UI 组件，以底部弹窗形式显示路线规划结果
/// 供用户选择不同的路线方案
///
/// 功能特性：
/// - 横向显示多条路线选项（距离、耗时）
/// - 支持路线选择交互
/// - 空状态提示
/// - 暗黑模式适配
/// ============================================

class RouteResultBottomSheet extends StatelessWidget {
  /// 路线选项数据模型列表
  final List<RouteResultItem> routes;

  /// 当前选中的路线索引
  final int selectedIndex;

  /// 路线选择回调，参数为选中的路线索引
  final ValueChanged<int>? onRouteSelected;

  /// 关闭按钮点击回调
  final VoidCallback? onClose;

  /// 当前选中的出行方式
  final RouteType currentRouteType;

  /// 出行方式切换回调
  final ValueChanged<RouteType>? onRouteTypeChanged;

  const RouteResultBottomSheet({
    super.key,
    this.routes = const [],
    this.selectedIndex = 0,
    this.onRouteSelected,
    this.onClose,
    this.currentRouteType = RouteType.driving,
    this.onRouteTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 160,
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
          // 路线列表（横向）
          if (routes.isEmpty)
            _buildEmptyState(isDark)
          else
            _buildRouteList(isDark),
        ],
      ),
    );
  }

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

  Widget _buildEmptyState(bool isDark) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route,
              size: 36,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey400,
            ),
            const SizedBox(height: AppSpacings.xs),
            Text(
              '暂无路线',
              style: TextStyle(
                color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteList(bool isDark) {
    return Expanded(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.md,
          vertical: AppSpacings.sm,
        ),
        itemCount: routes.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacings.sm),
        itemBuilder: (context, index) => _RouteCard(
          route: routes[index],
          isSelected: index == selectedIndex,
          onTap: () => onRouteSelected?.call(index),
          isDark: isDark,
        ),
      ),
    );
  }
}

/// ============================================
/// 路线选项卡片
///
/// 显示单条路线：距离、耗时
/// ============================================

class _RouteCard extends StatelessWidget {
  final RouteResultItem route;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDark;

  const _RouteCard({
    required this.route,
    required this.isSelected,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.sm,
          vertical: AppSpacings.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkBackgroundColor : AppColors.grey50),
          borderRadius: BorderRadius.all(AppRadii.medium),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 距离
            Row(
              children: [
                Icon(
                  Icons.straighten,
                  size: 14,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  route.formattedDistance,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // 耗时
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: AppColors.grey500,
                ),
                const SizedBox(width: 4),
                Text(
                  route.formattedDuration,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // 策略
            Text(
              route.strategy,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.darkLightTextColor : AppColors.grey400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
