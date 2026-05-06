import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_radii.dart';
import '../../../../constants/app_spacings.dart';
import '../../models/poi_models.dart';
import '../../provider/location_input_provider.dart';
import '../../provider/map_navigation_provider.dart';
import 'location_list_item.dart';
import 'category_tab_bar.dart';
import 'history_selection_bar.dart';
import 'history_list_item.dart';

/// ============================================
/// 位置分类列表组件
///
/// 地图导航功能的核心 UI 组件，显示在地图顶部
/// 顶部包含分类按钮栏，主体显示不同分类的位置列表
///
/// 分类按钮（从左到右）：
/// - 我的位置：获取当前 GPS 位置并填入
/// - 绑定者：显示绑定的其他用户位置（占位）
/// - 历史：显示历史搜索位置
/// - 路线：弹出路线规划底部弹窗
/// - 关闭：隐藏列表并收起键盘
///
/// 列表内容根据当前选中的分类动态切换：
/// - 有 POI 搜索时：优先显示搜索结果
/// - 绑定者分类：显示占位提示
/// - 历史分类：显示历史位置列表
///
/// 依赖：
/// - locationInputProvider：管理位置输入状态
/// - mapNavigationProvider：管理地图导航状态
/// ============================================

class LocationCategoryList extends ConsumerStatefulWidget {
  const LocationCategoryList({super.key});

  @override
  ConsumerState<LocationCategoryList> createState() => _LocationCategoryListState();
}

class _LocationCategoryListState extends ConsumerState<LocationCategoryList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(locationInputProvider.notifier).loadHistoryLocations();
      ref.read(locationInputProvider.notifier).loadBinderLocations();
    });
  }

  void _selectLocationAndUnfocus(PoiSuggestion poi) {
    ref.read(locationInputProvider.notifier).selectPoi(
      poi,
      ref.read(mapNavigationProvider.notifier),
    );
    FocusScope.of(context).unfocus();
  }

  void _hideListAndUnfocus() {
    ref.read(locationInputProvider.notifier).hideList();
    ref.read(locationInputProvider.notifier).exitHistorySelectionMode();
    FocusScope.of(context).unfocus();
  }

  void _onHistoryLongPress(PoiSuggestion poi) {
    final notifier = ref.read(locationInputProvider.notifier);
    final currentState = ref.read(locationInputProvider);
    if (!currentState.isHistorySelectionMode) {
      notifier.enterHistorySelectionMode();
    }
    notifier.toggleHistorySelection(poi.id);
  }

  void _onHistoryTap(PoiSuggestion poi) {
    final notifier = ref.read(locationInputProvider.notifier);
    final currentState = ref.read(locationInputProvider);
    if (currentState.isHistorySelectionMode) {
      notifier.toggleHistorySelection(poi.id);
    } else {
      _selectLocationAndUnfocus(poi);
    }
  }

  void _onSelectAll() {
    ref.read(locationInputProvider.notifier).selectAllHistory();
  }

  void _onDeleteSelected() {
    ref.read(locationInputProvider.notifier).deleteSelectedHistory();
  }

  void _onExitSelectionMode() {
    ref.read(locationInputProvider.notifier).exitHistorySelectionMode();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationInputProvider);
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
          CategoryTabBar(
            state: state,
            onClose: _hideListAndUnfocus,
          ),
          Container(height: 1, color: isDark ? AppColors.darkDividerColor : AppColors.grey200),
          if (state.isHistorySelectionMode)
            HistorySelectionBar(
              onSelectAll: _onSelectAll,
              onDeleteSelected: _onDeleteSelected,
              onExitSelectionMode: _onExitSelectionMode,
            ),
          _buildListContent(state),
        ],
      ),
    );
  }

  Widget _buildListContent(LocationInputState state) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacings.sm),
        child: _buildCategoryContent(state),
      ),
    );
  }

  Widget _buildCategoryContent(LocationInputState state) {
    if (state.searchResults.isNotEmpty || state.isSearching || state.searchError != null) {
      return _buildPoiSearchResults(state);
    }

    switch (state.selectedCategory) {
      case LocationCategory.recommended:
        return const SizedBox.shrink();
      case LocationCategory.binder:
      case LocationCategory.none:
        return _buildBinderContent(state);
      case LocationCategory.history:
        return _buildHistoryContent(state);
    }
  }

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

  Widget _buildBinderContent(LocationInputState state) {
    if (state.isLoadingBinderItems) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacings.md),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (state.binderItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacings.md),
          child: Text(
            '暂无绑定者位置',
            style: TextStyle(
              color: AppColors.grey500,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: state.binderItems.map((poi) => LocationListItem(
        icon: Icons.people,
        iconColor: AppColors.primaryColor,
        title: poi.name,
        subtitle: poi.address.isNotEmpty ? poi.address : poi.district,
        onTap: () => _selectLocationAndUnfocus(poi),
      )).toList(),
    );
  }

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
      children: state.historyItems.map((poi) => HistoryListItem(
        poi: poi,
        isSelected: state.selectedHistoryIds.contains(poi.id),
        isSelectionMode: state.isHistorySelectionMode,
        onTap: () => _onHistoryTap(poi),
        onLongPress: () => _onHistoryLongPress(poi),
      )).toList(),
    );
  }
}