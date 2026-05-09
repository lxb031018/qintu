import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_radii.dart';
import '../../../../constants/app_spacings.dart';
import '../../../../widgets/common/qintu_action_button.dart';
import '../../models/map_overlay_models.dart';
import 'detail_page_header.dart';
import 'drag_handle.dart';
import 'empty_state.dart';
import 'transit_route_summary_card.dart';
import 'transit_itinerary_card/transit_itinerary_card.dart';

/// 公共交通路线结果底部弹窗
///
/// 纯 UI 组件，与 [RouteResultBottomSheet] 平级，
/// 专用于公交路线规划结果的展示：
/// - 纵向全宽路线列表（摘要卡片）
/// - 点击路线进入行程详情页（时间线视图）
/// - 空状态 / 加载状态
/// - 暗黑模式适配
///
/// 拖拽关闭由父级 [Positioned] 层处理，本组件不包含拖拽逻辑。
class TransitRouteSheet extends StatefulWidget {
  /// 路线选项数据模型列表
  final List<RouteResultItem> routes;

  /// 当前选中的路线索引
  final int selectedIndex;

  /// 路线选择回调，参数为选中的路线索引
  final ValueChanged<int>? onRouteSelected;

  /// 关闭弹窗回调
  final VoidCallback? onClose;

  /// 开始导航/查看路线图回调
  final VoidCallback? onStartNavigation;

  /// 退出详情页回调，用于恢复地图扁平渲染
  final VoidCallback? onDetailExited;

  /// 错误信息（空结果时显示）
  final String? errorMessage;

  /// 是否正在加载路线数据
  final bool isLoading;

  const TransitRouteSheet({
    super.key,
    this.routes = const [],
    this.selectedIndex = 0,
    this.onRouteSelected,
    this.onClose,
    this.onStartNavigation,
    this.onDetailExited,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  State<TransitRouteSheet> createState() => _TransitRouteSheetState();
}

class _TransitRouteSheetState extends State<TransitRouteSheet> {
  /// 当前查看详情的路线（null = 列表页）
  RouteResultItem? _detailRoute;

  @override
  void didUpdateWidget(TransitRouteSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 路线数据整体刷新时退出详情
    if (oldWidget.routes != widget.routes) {
      _detailRoute = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
      child: _detailRoute != null
          ? _buildDetailPage(isDark)
          : _buildListPage(isDark),
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
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacings.sm),
              itemCount: widget.routes.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacings.sm),
              itemBuilder: (context, index) {
                return TransitRouteSummaryCard(
                  route: widget.routes[index],
                  isSelected: index == widget.selectedIndex,
                  onTap: () {
                    setState(() => _detailRoute = widget.routes[index]);
                    widget.onRouteSelected?.call(index);
                  },
                  isDark: isDark,
                );
              },
            ),
          ),
          _buildActionButtons(isDark),
        ],
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SizedBox(
      height: 80,
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

  Widget _buildDetailPage(bool isDark) {
    final route = _detailRoute;
    if (route == null) return const SizedBox.shrink();

    final segments = route.transitSegments;
    if (segments == null || segments.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        RouteDetailHeader(
          route: route,
          isDark: isDark,
          onBack: () {
            setState(() => _detailRoute = null);
            widget.onDetailExited?.call();
          },
        ),
        Container(
          padding: const EdgeInsets.only(
            left: AppSpacings.sm,
            right: AppSpacings.sm,
            bottom: AppSpacings.sm,
          ),
          child: TransitRouteSummaryCard(
            route: route,
            isSelected: true,
            onTap: null,
            isDark: isDark,
          ),
        ),
        Container(height: 1, color: isDark ? AppColors.darkDividerColor : AppColors.grey200),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacings.sm),
            child: TransitItineraryCard(
              segments: segments,
              totalDistance: route.distance,
              totalDuration: route.duration,
              tolls: route.tolls ?? 0,
              walkDistance: route.walkDistance,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacings.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              QintuActionButton(
                label: '查看路线图',
                icon: Icons.map,
                onTap: widget.onStartNavigation,
                backgroundColor: AppColors.grey600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacings.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          QintuActionButton(
            label: '查看路线图',
            icon: Icons.map,
            onTap: widget.onStartNavigation,
            backgroundColor: AppColors.grey600,
          ),
        ],
      ),
    );
  }
}
