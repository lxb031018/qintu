import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../models/amap_routing_models.dart';
import '../provider/map_navigation_provider.dart';

/// ============================================
/// 路线结果列表组件
///
/// 显示路线规划结果列表，供用户选择不同的路线方案
/// 与地图导航状态管理器（mapNavigationProvider）紧密集成
///
/// 功能特性：
/// - 显示多条路线选项（策略、距离、耗时、费用）
/// - 支持路线选择交互（点击切换选中状态）
/// - 空状态提示（无路线规划结果时）
/// - 暗黑模式适配
///
/// 依赖：
/// - mapNavigationProvider：管理路线规划和选择状态
/// ============================================

class RouteResultList extends ConsumerWidget {
  const RouteResultList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听地图导航状态
    final state = ref.watch(mapNavigationProvider);
    // 获取状态管理器（用于触发状态变更）
    final notifier = ref.read(mapNavigationProvider.notifier);
    // 判断当前是否为暗黑模式
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 如果没有路线数据，显示空状态
    if (state.routes.isEmpty) {
      return _buildEmptyState(isDark);
    }

    // 显示路线列表
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.routes.length,
      itemBuilder: (context, index) {
        final route = state.routes[index];
        // 判断当前路线是否为选中状态
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

  /// 构建空状态
  /// 
  /// 当没有路线规划结果时显示提示图标和文本
  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 路线图标
            Icon(
              Icons.route,
              size: 48,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey400,
            ),
            const SizedBox(height: 16),
            // 提示文本
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

/// ============================================
/// 路线结果卡片（私有组件）
///
/// 显示单条路线的详细信息卡片，包含：
/// - 路线策略标签（如"高速优先"、"时间优先"等）
/// - 距离和时长信息（带图标）
/// - 费用信息
/// - 选中状态指示器
///
/// 点击卡片可切换选中状态，并通过 Provider 更新全局状态
/// ============================================

class _RouteResultCard extends StatelessWidget {
  /// 路线数据项
  final RouteOption route;
  
  /// 路线索引（用于判断选中状态）
  final int index;
  
  /// 是否为当前选中的路线
  final bool isSelected;
  
  /// 是否为暗黑模式
  final bool isDark;
  
  /// 点击回调
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
      // 点击选择路线
      onTap: onTap,
      child: Container(
        // 卡片间距
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // 选中时显示主题色背景，未选中时显示普通背景
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkCardBackground : Colors.white),
          borderRadius: BorderRadius.circular(12),
          // 选中时显示主题色边框
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (isDark ? AppColors.darkDividerColor : AppColors.borderColor),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          // 左对齐
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线策略标签和选中指示器
            Row(
              children: [
                // 策略标签
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
                // 选中指示器（仅选中时显示）
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 距离和时长信息
            Row(
              children: [
                // 路线图标
                Icon(
                  route.routeIcon,
                  size: 24,
                  color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                ),
                const SizedBox(width: 8),
                // 距离文本
                Text(
                  route.distanceText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                  ),
                ),
                const SizedBox(width: 16),
                // 时长文本
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
