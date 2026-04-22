import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../models/amap_routing_models.dart';
import '../provider/map_navigation_provider.dart';

/// ============================================
/// 路线结果列表组件
/// ============================================

class RouteResultList extends ConsumerWidget {
  const RouteResultList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapNavigationProvider);
    final notifier = ref.read(mapNavigationProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.routes.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.routes.length,
      itemBuilder: (context, index) {
        final route = state.routes[index];
        final isSelected = index == state.selectedRouteIndex;

        return _RouteResultCard(
          route: route,
          index: index,
          isSelected: isSelected,
          isDark: isDark,
          onTap: () => notifier.selectRoute(index),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route,
              size: 48,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无路线规划结果',
              style: TextStyle(
                color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteResultCard extends StatelessWidget {
  final RouteOption route;
  final int index;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _RouteResultCard({
    required this.route,
    required this.index,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkCardBackground : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (isDark ? AppColors.darkDividerColor : AppColors.borderColor),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线策略标签
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    route.strategyText,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 距离和时长
            Row(
              children: [
                Icon(
                  route.routeIcon,
                  size: 24,
                  color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                ),
                const SizedBox(width: 8),
                Text(
                  route.distanceText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '约 ${route.durationText}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 费用信息
            Text(
              route.tollsText,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
