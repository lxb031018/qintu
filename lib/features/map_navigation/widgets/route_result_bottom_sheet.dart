import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../models/amap_routing_models.dart';
import '../models/map_overlay_models.dart';
import 'driving_strategy_selector.dart';
import 'transit_itinerary_card.dart';

/// ============================================
/// 路线规划结果底部弹窗
///
/// 纯 UI 组件，以底部弹窗形式显示路线规划结果
/// 供用户选择不同的路线方案
///
/// 功能特性：
/// - 纵向全宽显示多条路线选项（距离、耗时、策略、线路名称）
/// - 支持路线选择交互
/// - 空状态提示
/// - 暗黑模式适配
/// - 支持下拉拖动隐藏
/// - 公交路线显示行程详情
/// ============================================

class RouteResultBottomSheet extends StatefulWidget {
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

  /// 是否可见（用于控制显示/隐藏动画）
  final bool isVisible;

  /// 开始导航按钮点击回调
  final VoidCallback? onStartNavigation;

  /// 查看行程详情回调（公交模式）
  final VoidCallback? onViewItinerary;

  /// 退出详情页回调（公交模式），用于恢复地图扁平渲染
  final VoidCallback? onDetailExited;

  /// 当前驾车策略 (10-20)，驾车模式时传递给策略选择器
  final int drivingStrategy;

  /// 驾车策略切换回调
  final ValueChanged<int>? onDrivingStrategyChanged;

  const RouteResultBottomSheet({
    super.key,
    this.routes = const [],
    this.selectedIndex = 0,
    this.onRouteSelected,
    this.onClose,
    this.currentRouteType = RouteType.driving,
    this.onRouteTypeChanged,
    this.isVisible = true,
    this.onStartNavigation,
    this.onViewItinerary,
    this.onDetailExited,
    this.drivingStrategy = 10,
    this.onDrivingStrategyChanged,
  });

  @override
  State<RouteResultBottomSheet> createState() => _RouteResultBottomSheetState();
}

class _RouteResultBottomSheetState extends State<RouteResultBottomSheet> {
  double _dragOffset = 0;
  bool _isDragging = false;

  /// 下拉隐藏阈值
  static const double _dismissThreshold = 80;

  /// 最大拖动距离
  static const double _maxDragOffset = 120;

  /// 是否显示策略选择器（仅驾车/货车模式）
  bool get _showStrategySelector =>
      widget.currentRouteType == RouteType.driving ||
      widget.currentRouteType == RouteType.truck;

  /// 当前查看详情的路线（仅公交模式，null = 列表页）
  RouteResultItem? _detailRoute;

  @override
  void didUpdateWidget(RouteResultBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 切换出行方式时退出详情
    if (oldWidget.currentRouteType != widget.currentRouteType) {
      _detailRoute = null;
    }
  }

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset = 0;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      // 只能向下拉（正值），不能向上推
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0, _maxDragOffset);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset > _dismissThreshold) {
      // 拖动超过阈值，隐藏 bottom sheet
      widget.onClose?.call();
    }
    setState(() {
      _isDragging = false;
      _dragOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 计算拖动时的偏移量
    final double translateY = _isDragging ? _dragOffset : 0;

    final isTransit = widget.currentRouteType == RouteType.transit;
    final showDetail = isTransit && _detailRoute != null;

    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Transform.translate(
        offset: Offset(0, translateY),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBackground : AppColors.backgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: AppRadii.large,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: showDetail
              ? _buildDetailPage(isDark)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDragHandle(isDark),
                    if (_showStrategySelector)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacings.sm),
                        child: DrivingStrategySelector(
                          selectedStrategy: widget.drivingStrategy,
                          onStrategyChanged: widget.onDrivingStrategyChanged ?? (_) {},
                        ),
                      ),
                    if (widget.routes.isEmpty)
                      _buildEmptyState(isDark)
                    else
                      _buildRouteList(isDark),
                    if (widget.routes.isNotEmpty) _buildActionButtons(isDark),
                  ],
                ),
        ),
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
    return SizedBox(
      height: 80,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route,
              size: 36,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey400,
            ),
            SizedBox(height: AppSpacings.xs),
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
    final isTransit = widget.currentRouteType == RouteType.transit;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 240),
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.all(AppSpacings.sm),
        itemCount: widget.routes.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacings.sm),
        itemBuilder: (context, index) => _RouteCard(
          route: widget.routes[index],
          isSelected: index == widget.selectedIndex,
          onTap: () {
            if (isTransit) {
              setState(() => _detailRoute = widget.routes[index]);
            }
            widget.onRouteSelected?.call(index);
          },
          isDark: isDark,
          currentRouteType: widget.currentRouteType,
        ),
      ),
    );
  }

  Widget _buildDetailPage(bool isDark) {
    final route = _detailRoute;
    if (route == null) return const SizedBox.shrink();

    final segments = route.transitSegments;
    if (segments == null || segments.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 顶部：返回按钮 + 标题
        Padding(
          padding: const EdgeInsets.all(AppSpacings.sm),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _detailRoute = null);
                  widget.onDetailExited?.call();
                },
                child: const Icon(Icons.arrow_back, size: 20, color: AppColors.grey600),
              ),
              const SizedBox(width: AppSpacings.sm),
              Text(
                '行程详情',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                ),
              ),
              const Spacer(),
              // 路线摘要：距离 + 耗时
              Text(
                '${route.formattedDistance} · ${route.formattedDuration}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
        // 分隔线
        Container(height: 1, color: isDark ? AppColors.darkDividerColor : AppColors.grey200),
        // 中部：行程时间线
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacings.sm),
            child: TransitItineraryCard(
              segments: segments,
              totalDistance: route.distance,
              totalDuration: route.duration,
              tolls: route.tolls ?? 0,
              walkDistance: route.walkDistance,
              transferCount: route.transferCount,
            ),
          ),
        ),
        // 底部：操作按钮
        Padding(
          padding: const EdgeInsets.all(AppSpacings.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: widget.onStartNavigation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacings.md,
                    vertical: AppSpacings.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey600,
                    borderRadius: BorderRadius.all(AppRadii.small),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map, size: 16, color: isDark ? AppColors.darkTextColor : Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '查看路线图',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextColor : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    final isTransit = widget.currentRouteType == RouteType.transit;

    return Padding(
      padding: const EdgeInsets.all(AppSpacings.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 开始导航 / 查看行程按钮
          GestureDetector(
            onTap: widget.onStartNavigation,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacings.md,
                vertical: AppSpacings.xs,
              ),
              decoration: BoxDecoration(
                color: isTransit ? AppColors.grey600 : AppColors.primaryColor,
                borderRadius: BorderRadius.all(AppRadii.small),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isTransit ? Icons.map : Icons.navigation,
                    size: 16,
                    color: isDark ? AppColors.darkTextColor : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isTransit ? '查看路线图' : '开始导航',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextColor : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================
/// 路线选项卡片
///
/// 全宽横向布局：左侧距离+耗时，中部策略+线路名，右侧费用信息
/// ============================================

class _RouteCard extends StatelessWidget {
  final RouteResultItem route;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDark;
  final RouteType currentRouteType;

  const _RouteCard({
    required this.route,
    required this.isSelected,
    this.onTap,
    required this.isDark,
    required this.currentRouteType,
  });

  @override
  Widget build(BuildContext context) {
    final isTransit = currentRouteType == RouteType.transit;
    final transitLines = route.transitLineNames;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.sm,
          vertical: AppSpacings.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.08)
              : (isDark ? AppColors.darkBackgroundColor : AppColors.grey50),
          borderRadius: BorderRadius.all(AppRadii.medium),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // 选中指示条
                if (isSelected)
                  Container(
                    width: 3,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                if (isSelected) const SizedBox(width: AppSpacings.sm),
                // 左侧：距离 + 耗时
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      route.formattedDistance,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 12, color: AppColors.grey500),
                        const SizedBox(width: 2),
                        Text(
                          route.formattedDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacings.md),
                // 中部：策略 + 线路名称
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        route.strategy,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isTransit && transitLines != null && transitLines.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: transitLines.map((name) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: _transitLineColor(name, isDark),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacings.sm),
                // 右侧：费用 / 换乘信息 / 差异标记
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isTransit && route.tolls != null && route.tolls! > 0)
                      Text(
                        '¥${route.tolls!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      )
                    else if (!isTransit && route.tolls != null && route.tolls! > 0)
                      Text(
                        '¥${route.tolls!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                        ),
                      ),
                    if (isTransit && route.transferCount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '换乘${route.transferCount}次',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
                        ),
                      ),
                    ],
                    if (!isSelected && (route.timeDiff != null || route.distanceDiff != null))
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: _buildDiffLabel(route, isDark),
                      ),
                  ],
                ),
                // 选中图标
                if (isSelected) ...[
                  const SizedBox(width: AppSpacings.xs),
                  const Icon(Icons.check_circle, size: 18, color: AppColors.primaryColor),
                ],
              ],
            ),
            if (isSelected && currentRouteType == RouteType.driving)
              _buildTrafficBar(route, isDark),
          ],
        ),
      ),
    );
  }

  Color _transitLineColor(String name, bool isDark) {
    if (name.contains('号线') || name.contains('地铁') || name.contains('轨')) {
      return const Color(0xFFFF4D4F);
    }
    return const Color(0xFF1890FF);
  }

  /// 构建路线对比差异标签
  Widget _buildDiffLabel(RouteResultItem route, bool isDark) {
    final parts = <String>[];
    if (route.timeDiff != null) {
      final absMin = (route.timeDiff!.abs() / 60).round();
      if (route.timeDiff! < 0) {
        parts.add('快$absMin分钟');
      } else {
        parts.add('慢$absMin分钟');
      }
    }
    if (route.distanceDiff != null) {
      final absKm = (route.distanceDiff!.abs() / 1000).toStringAsFixed(1);
      if (route.distanceDiff! < 0) {
        parts.add('少${absKm}km');
      } else {
        parts.add('多${absKm}km');
      }
    }
    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join(' · '),
      style: TextStyle(
        fontSize: 10,
        color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
      ),
    );
  }

  /// 构建路况摘要条（仅驾车模式选中时显示）
  Widget _buildTrafficBar(RouteResultItem route, bool isDark) {
    final statuses = route.trafficStatuses;
    if (statuses == null || statuses.isEmpty) return const SizedBox.shrink();

    final totalCount = statuses.length;
    if (totalCount == 0) return const SizedBox.shrink();

    int smoothCount = 0;
    int slowCount = 0;
    int jamCount = 0;

    for (final s in statuses) {
      final status = s['status'] as String? ?? '';
      if (status == '畅通') {
        smoothCount++;
      } else if (status == '缓行') {
        slowCount++;
      } else if (status == '拥堵' || status == '严重拥堵') {
        jamCount++;
      }
    }

    if (smoothCount + slowCount + jamCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          height: 4,
          child: Row(
            children: [
              if (smoothCount > 0)
                Expanded(flex: smoothCount, child: Container(color: Color(RouteColors.trafficSmooth))),
              if (slowCount > 0)
                Expanded(flex: slowCount, child: Container(color: Color(RouteColors.trafficSlow))),
              if (jamCount > 0)
                Expanded(flex: jamCount, child: Container(color: Color(RouteColors.trafficJam))),
            ],
          ),
        ),
      ),
    );
  }
}
