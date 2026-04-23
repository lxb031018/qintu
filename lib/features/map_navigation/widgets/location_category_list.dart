import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../../../widgets/map/amap_map_widget.dart';
import '../api/poi_api.dart';
import '../provider/location_input_provider.dart';
import '../provider/map_navigation_provider.dart';
import 'category_button.dart';
import 'close_button.dart';
import 'location_list_item.dart';
import 'route_button.dart';

/// ============================================
/// 位置分类列表组件
///
/// 顶部包含分类按钮栏，主体显示不同分类的位置列表
///
/// 分类按钮：
/// - 我的位置
/// - 绑定者
/// - 历史
/// - 路线（点击弹出 route_result_bottom_sheet）
/// - 关闭 (x)
///
/// 列表内容由父组件通过枚举控制显示
/// ============================================

class LocationCategoryList extends ConsumerStatefulWidget {
  final VoidCallback? onRouteTap;
  final AmapMapController? mapController;  // 地图控制器，用于获取当前位置

  const LocationCategoryList({
    super.key,
    this.onRouteTap,
    this.mapController,
  });

  @override
  ConsumerState<LocationCategoryList> createState() => _LocationCategoryListState();
}

class _LocationCategoryListState extends ConsumerState<LocationCategoryList> {
  @override
  void initState() {
    super.initState();
    ref.read(locationInputProvider.notifier).loadHistoryLocations();
  }

  /// 选择位置并收起键盘
  void _selectLocationAndUnfocus(PoiSuggestion poi) {
    ref.read(locationInputProvider.notifier).selectLocation(
      poi,
      ref.read(mapNavigationProvider.notifier),
    );
    FocusScope.of(context).unfocus();
  }

  /// 选择"我的位置"
  Future<void> _selectMyLocation() async {
    final controller = widget.mapController;
    if (controller == null) return;

    final poi = await ref.read(locationInputProvider.notifier).getMyLocation(
      () => controller.getCurrentLocation(),
    );
    if (poi != null && mounted) {
      _selectLocationAndUnfocus(poi);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationInputProvider);
    final notifier = ref.read(locationInputProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.backgroundColor,
        borderRadius: BorderRadius.all(AppRadii.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 分类按钮栏
          _buildCategoryBar(state, isDark),
          // 分隔线
          Container(height: 1, color: isDark ? AppColors.darkDividerColor : AppColors.grey200),
          // 列表内容区
          _buildListContent(state, notifier),
        ],
      ),
    );
  }

  /// 构建分类按钮栏
  Widget _buildCategoryBar(LocationInputState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.sm,
        vertical: AppSpacings.sm,
      ),
      child: Row(
        children: [
          // 我的位置
          LocationCategoryButton(
            label: '我的位置',
            icon: Icons.my_location,
            isSelected: state.selectedCategory == LocationCategory.recommended,
            onTap: () => ref.read(locationInputProvider.notifier).selectCategory(LocationCategory.recommended),
          ),
          const SizedBox(width: AppSpacings.sm),
          // 绑定者
          LocationCategoryButton(
            label: '绑定者',
            icon: Icons.people,
            isSelected: state.selectedCategory == LocationCategory.binder,
            onTap: () => ref.read(locationInputProvider.notifier).selectCategory(LocationCategory.binder),
          ),
          const SizedBox(width: AppSpacings.sm),
          // 历史
          LocationCategoryButton(
            label: '历史',
            icon: Icons.history,
            isSelected: state.selectedCategory == LocationCategory.history,
            onTap: () => ref.read(locationInputProvider.notifier).selectCategory(LocationCategory.history),
          ),
          const SizedBox(width: AppSpacings.sm),
          // 路线按钮（点击弹出底部弹窗）
          LocationRouteButton(onTap: widget.onRouteTap),
          // 关闭按钮
          const Spacer(),
          LocationCloseButton(onTap: () {
              ref.read(locationInputProvider.notifier).hideList();
              FocusScope.of(context).unfocus();
            }),
        ],
      ),
    );
  }

  /// 构建列表内容区
  Widget _buildListContent(LocationInputState state, LocationInputNotifier notifier) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacings.sm),
        child: _buildCategoryContent(state),
      ),
    );
  }

  /// 根据当前分类构建内容
  Widget _buildCategoryContent(LocationInputState state) {
    // 如果有搜索结果，显示搜索结果列表
    if (state.searchResults.isNotEmpty || state.isSearching || state.searchError != null) {
      return _buildPoiSearchResults(state);
    }

    switch (state.selectedCategory) {
      case LocationCategory.recommended:
        return _buildMyLocationContent();
      case LocationCategory.binder:
        return _buildBinderPlaceholder();
      case LocationCategory.history:
        return _buildHistoryContent(state);
    }
  }

  /// 构建 POI 搜索结果列表
  Widget _buildPoiSearchResults(LocationInputState state) {
    if (state.isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacings.md),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (state.searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacings.md),
          child: Text(
            state.searchError!,
            style: const TextStyle(color: AppColors.grey500, fontSize: 14),
          ),
        ),
      );
    }

    if (state.searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacings.md),
          child: Text(
            '未找到结果',
            style: TextStyle(color: AppColors.grey500, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: state.searchResults.map((poi) => LocationListItem(
        icon: Icons.place,
        iconColor: AppColors.primaryColor,
        title: poi.name,
        subtitle: poi.address.isNotEmpty ? poi.address : poi.district,
        onTap: () => _selectLocationAndUnfocus(poi),
      )).toList(),
    );
  }

  /// "我的位置" 内容
  Widget _buildMyLocationContent() {
    return LocationListItem(
      icon: Icons.my_location,
      iconColor: AppColors.primaryColor,
      title: '我的位置',
      subtitle: '使用 GPS 获取当前位置',
      onTap: _selectMyLocation,
    );
  }

  /// "绑定者" 占位内容
  Widget _buildBinderPlaceholder() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacings.md),
        child: Text(
          '暂无可用绑定者位置',
          style: TextStyle(
            color: AppColors.grey500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// "历史" 内容
  Widget _buildHistoryContent(LocationInputState state) {
    if (state.isLoadingHistory) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacings.md),
          child: Text(
            '加载中...',
            style: TextStyle(color: AppColors.grey500, fontSize: 14),
          ),
        ),
      );
    }

    if (state.historyItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacings.md),
          child: Text(
            '暂无历史位置',
            style: TextStyle(color: AppColors.grey500, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: state.historyItems.map((poi) => LocationListItem(
        icon: Icons.history,
        iconColor: AppColors.grey600,
        title: poi.name,
        subtitle: poi.address.isNotEmpty ? poi.address : poi.district,
        onTap: () => _selectLocationAndUnfocus(poi),
      )).toList(),
    );
  }
}
