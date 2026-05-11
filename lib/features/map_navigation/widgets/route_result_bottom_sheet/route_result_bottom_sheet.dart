import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_radii.dart';
import '../../../../constants/app_spacings.dart';
import '../../../../widgets/common/qintu_action_button.dart';
import '../../models/amap_routing_models.dart';
import '../../models/map_overlay_models.dart';
import 'drag_handle.dart';
import 'empty_state.dart';
import 'route_card.dart';

/// ============================================
/// 路线规划结果底部弹窗（非公交模式）
///
/// 纯 UI 组件，以底部弹窗形式显示驾车/步行/骑行路线规划结果，
/// 供用户选择不同的路线方案。
///
/// 功能特性：
/// - 横向滚动显示多条路线卡片（距离、耗时）
/// - 支持路线选择交互
/// - 空状态提示
/// - 暗黑模式适配
/// - 支持下拉拖动隐藏
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

  /// 是否可见（用于控制显示/隐藏动画）
  final bool isVisible;

  /// 开始导航按钮点击回调
  final VoidCallback? onStartNavigation;

  /// 分享按钮点击回调
  final VoidCallback? onShare;

  /// 错误信息（空结果时显示）
  final String? errorMessage;

  /// 是否正在加载路线数据
  final bool isLoading;

  const RouteResultBottomSheet({
    super.key,
    this.routes = const [],
    this.selectedIndex = 0,
    this.onRouteSelected,
    this.onClose,
    this.currentRouteType = RouteType.driving,
    this.isVisible = true,
    this.onStartNavigation,
    this.onShare,
    this.errorMessage,
    this.isLoading = false,
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

  /// 加载状态容器高度
  static const double _loadingHeight = 80;

  /// 非公交路线列表高度
  static const double _routeListHeight = 120;

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
          child: _buildListPage(isDark),
        ),
      ),
    );
  }

  Widget _buildListPage(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const RouteDragHandle(),
        if (widget.isLoading)
          _buildLoadingState(isDark)
        else if (widget.routes.isEmpty)
          RouteEmptyState(errorMessage: widget.errorMessage)
        else ...[
          _buildRouteList(isDark),
          _buildActionButtons(),
        ],
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SizedBox(
      height: _loadingHeight,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
              ),
            ),
            const SizedBox(height: AppSpacings.xs),
            Text(
              '正在规划路线...',
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
    return SizedBox(
      height: _routeListHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(AppSpacings.sm),
        itemCount: widget.routes.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacings.sm),
        itemBuilder: (context, index) {
          return RouteCard(
            route: widget.routes[index],
            isSelected: index == widget.selectedIndex,
            onTap: () {
              widget.onRouteSelected?.call(index);
            },
            isDark: isDark,
            currentRouteType: widget.currentRouteType,
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacings.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          QintuActionButton(
            label: '分享',
            icon: Icons.share,
            onTap: widget.onShare,
            backgroundColor: AppColors.grey400,
          ),
          const SizedBox(width: AppSpacings.sm),
          QintuActionButton(
            label: '开始导航',
            icon: Icons.navigation,
            onTap: widget.onStartNavigation,
            backgroundColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}
