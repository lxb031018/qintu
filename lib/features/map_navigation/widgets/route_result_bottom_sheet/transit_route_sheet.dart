import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_radii.dart';
import '../../../../constants/app_spacings.dart';
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
/// 列表页使用 [DraggableScrollableSheet] 处理滚动与拖拽关闭手势，
/// 详情页亦使用 [DraggableScrollableSheet]，支持下拉折叠为摘要卡片、
/// 上拉或点击摘要卡片展开完整行程详情。
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

  /// 防止重复触发关闭
  bool _dismissTriggered = false;

  /// 详情页展开/折叠状态
  bool _detailExpanded = true;

  final DraggableScrollableController _detailSheetController =
      DraggableScrollableController();

  /// 测量摘要卡片实际高度，动态计算 DSS 折叠/初始尺寸
  final GlobalKey _summaryKey = GlobalKey();
  double? _detailMinSize;
  double? _detailInitSize;
  bool _detailSizesMeasured = false;

  @override
  void dispose() {
    _detailSheetController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TransitRouteSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routes.length != widget.routes.length) {
      _detailRoute = null;
      _dismissTriggered = false;
      _detailExpanded = true;
      _detailSizesMeasured = false;
      _detailMinSize = null;
      _detailInitSize = null;
    }
  }

  void _measureDetailSizes() {
    if (_detailSizesMeasured) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _detailRoute == null) return;

      final ctx = _summaryKey.currentContext;
      if (ctx == null) return;

      final RenderBox box = ctx.findRenderObject() as RenderBox;
      final summaryHeight = box.size.height;
      final sheetHeight = context.size?.height;
      if (sheetHeight == null || sheetHeight <= 0) return;

      // 折叠态固定内容：RouteDetailHeader + 卡片 bottom padding + 缓冲
      final collapsedH = summaryHeight + 36 + AppSpacings.sm + 8;
      final minSize = (collapsedH / sheetHeight).clamp(0.2, 0.45);
      final initSize = (minSize * 2.5).clamp(minSize + 0.15, 0.8);

      setState(() {
        _detailMinSize = minSize;
        _detailInitSize = initSize;
        _detailSizesMeasured = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_detailRoute != null) {
      _measureDetailSizes();
    }

    return _detailRoute != null
        ? _buildDraggableDetailPage(isDark)
        : _buildDraggableListPage(isDark);
  }

  /// 详情页：DraggableScrollableSheet，支持下拉折叠为摘要
  Widget _buildDraggableDetailPage(bool isDark) {
    final route = _detailRoute;
    final segments = route?.transitSegments;
    if (route == null || segments == null || segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final expanded = notification.extent >= 0.35;
        if (expanded != _detailExpanded) {
          setState(() => _detailExpanded = expanded);
        }
        if (notification.extent <= 0.02 && !_dismissTriggered) {
          _dismissTriggered = true;
          widget.onClose?.call();
          return true;
        }
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _detailSheetController,
        initialChildSize: _detailInitSize ?? 0.6,
        minChildSize: _detailMinSize ?? 0.2,
        maxChildSize: 1.0,
        snap: true,
        snapSizes: [
          _detailMinSize ?? 0.2,
          _detailInitSize ?? 0.6,
        ],
        builder: (context, scrollController) {
          return Container(
            decoration: _sheetDecoration(isDark),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: AppRadii.large),
              child: _detailExpanded
                  ? _buildExpandedDetail(isDark, scrollController)
                  : _buildCollapsedDetail(isDark),
            ),
          );
        },
      ),
    );
  }

  /// 详情页展开态：全量内容
  Widget _buildExpandedDetail(bool isDark, ScrollController scrollController) {
    final route = _detailRoute!;
    final segments = route.transitSegments!;

    return Column(
      children: [
        RouteDetailHeader(
          route: route,
          isDark: isDark,
          onBack: () {
            _detailSheetController.animateTo(
              _detailInitSize ?? 0.6,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
            setState(() {
              _detailRoute = null;
              _detailExpanded = true;
              _detailSizesMeasured = false;
            });
            widget.onDetailExited?.call();
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: AppSpacings.sm),
            child: TransitItineraryCard(
              segments: segments,
              totalDistance: route.distance,
              totalDuration: route.duration,
              tolls: route.tolls ?? 0,
              walkDistance: route.walkDistance,
              summaryRoute: route,
              summaryKey: _summaryKey,
              isDark: isDark,
              isCollapsed: false,
            ),
          ),
        ),
      ],
    );
  }

  /// 详情页折叠态：仅头部 + 摘要
  Widget _buildCollapsedDetail(bool isDark) {
    final route = _detailRoute!;
    final segments = route.transitSegments ?? [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RouteDetailHeader(
          route: route,
          isDark: isDark,
          onBack: () {
            setState(() {
              _detailRoute = null;
              _detailExpanded = true;
              _detailSizesMeasured = false;
            });
            widget.onDetailExited?.call();
          },
        ),
        TransitItineraryCard(
          segments: segments,
          totalDistance: route.distance,
          totalDuration: route.duration,
          tolls: route.tolls ?? 0,
          walkDistance: route.walkDistance,
          summaryRoute: route,
          summaryKey: _summaryKey,
          isDark: isDark,
          isCollapsed: true,
          onSummaryTap: () {
            _detailSheetController.animateTo(
              _detailInitSize ?? 0.6,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }

  /// 列表页：DraggableScrollableSheet 接管手势
  Widget _buildDraggableListPage(bool isDark) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent <= 0.02 && !_dismissTriggered) {
          _dismissTriggered = true;
          widget.onClose?.call();
          return true;
        }
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.0,
        maxChildSize: 1.0,
        snap: true,
        snapSizes: const [0.0, 0.55],
        builder: (context, scrollController) {
          return Container(
            decoration: _sheetDecoration(isDark),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: AppRadii.large),
              child: Column(
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
                        controller: scrollController,
                        padding: const EdgeInsets.all(AppSpacings.sm),
                        itemCount: widget.routes.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacings.sm),
                        itemBuilder: (context, index) {
                          return TransitRouteSummaryCard(
                            route: widget.routes[index],
                            isSelected: index == widget.selectedIndex,
                            onTap: () {
                              setState(() {
                                _detailRoute = widget.routes[index];
                                _detailExpanded = true;
                                _detailSizesMeasured = false;
                                _detailMinSize = null;
                                _detailInitSize = null;
                              });
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
              ),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _sheetDecoration(bool isDark) {
    return BoxDecoration(
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

  Widget _buildActionButtons(bool isDark) {
    return const SizedBox.shrink();
  }
}
