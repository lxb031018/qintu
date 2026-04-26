import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../models/amap_routing_models.dart';
import '../models/map_overlay_models.dart';

/// ============================================
/// 路线规划结果底部弹窗
///
/// 纯 UI 组件，以底部弹窗（Modal Bottom Sheet）形式显示路线规划结果
/// 供用户选择不同的路线方案
///
/// 功能特性：
/// - 显示多条路线选项（距离、耗时、策略）
/// - 支持路线选择交互
/// - 空状态提示
/// - 暗黑模式适配
///
/// 使用方式：
/// 1. 直接作为 Widget 使用
/// 2. 调用静态方法 RouteResultBottomSheet.show() 显示弹窗
/// ============================================

class RouteResultBottomSheet extends StatelessWidget {
  /// 路线选项数据模型列表
  /// 包含多条路线的距离、耗时、策略等信息
  /// 简化版：真实数据由 Provider 提供
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

  /// 显示底部弹窗的静态方法
  /// 
  /// 使用 showModalBottomSheet 显示全屏可控的底部弹窗
  /// 背景透明以支持圆角效果
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
    // 判断当前是否为暗黑模式
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 获取屏幕尺寸信息
    final mediaQuery = MediaQuery.of(context);

    return Container(
      // 限制最大高度为屏幕高度的 60%
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.6,
      ),
      decoration: BoxDecoration(
        // 背景颜色根据暗黑/明亮模式切换
        color: isDark ? AppColors.darkCardBackground : AppColors.backgroundColor,
        // 仅顶部圆角
        borderRadius: const BorderRadius.vertical(
          top: AppRadii.large,
        ),
      ),
      child: Column(
        // 垂直布局，高度根据内容自适应
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动条
          _buildDragHandle(isDark),
          // 标题栏
          _buildHeader(isDark),
          // 路线列表（可滚动区域）
          Flexible(
            child: routes.isEmpty
                ? _buildEmptyState(isDark)
                : _buildRouteList(isDark),
          ),
        ],
      ),
    );
  }

  /// 构建顶部拖动条
  /// 
  /// 视觉提示，表示这是一个可拖动的底部弹窗
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

  /// 构建标题栏
  ///
  /// 已移除标题文本和关闭按钮
  Widget _buildHeader(bool isDark) {
    return const SizedBox.shrink();
  }

  /// 构建空状态
  /// 
  /// 当没有路线数据时显示提示图标和文本
  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacings.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 路线图标
          Icon(
            Icons.route,
            size: 48,
            color: isDark ? AppColors.darkLightTextColor : AppColors.grey400,
          ),
          const SizedBox(height: AppSpacings.sm),
          // 提示文本
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

  /// 构建路线列表
  /// 
  /// 使用 ListView.separated 显示可滚动列表
  /// 每个路线项之间添加间距
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
/// 路线选项卡片（私有组件）
///
/// 显示单条路线的详细信息：
/// - 距离和耗时（带图标的信息标签）
/// - 路线策略（如"高速优先"、"时间优先"等）
/// - 选中状态指示器
/// ============================================

class _RouteCard extends StatelessWidget {
  /// 路线数据项
  final RouteResultItem route;
  
  /// 是否为当前选中的路线
  final bool isSelected;
  
  /// 点击回调
  final VoidCallback? onTap;

  const _RouteCard({
    required this.route,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 判断当前是否为暗黑模式
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      // 点击选中路线
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacings.md),
        decoration: BoxDecoration(
          // 选中时显示主题色背景，未选中时显示普通背景
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkBackgroundColor : AppColors.grey50),
          borderRadius: BorderRadius.all(AppRadii.medium),
          // 选中时显示主题色边框
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 路线信息区
            Expanded(
              child: Column(
                // 左对齐
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 距离和耗时（横向排列）
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
                  // 路线策略文本
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
            // 选中指示器（仅选中时显示）
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
/// 信息标签（私有组件）
///
/// 显示带图标的小型信息标签
/// 用于展示路线的距离、耗时等信息
/// ============================================

class _InfoChip extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 标签文本
  final String label;

  /// 是否为暗黑模式
  final bool isDark;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      // 行宽根据内容自适应
      mainAxisSize: MainAxisSize.min,
      children: [
        // 图标
        Icon(
          icon,
          size: 14,
          color: AppColors.primaryColor,
        ),
        const SizedBox(width: 4),
        // 标签文本
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