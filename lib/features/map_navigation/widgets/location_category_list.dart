import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../core/amap_map_controller.dart';
import '../core/poi_api.dart';
import '../provider/location_input_provider.dart';
import '../provider/map_navigation_provider.dart';
import 'category_button.dart';
import 'close_button.dart';
import 'location_list_item.dart';
import 'my_location_button.dart';
import 'route_button.dart';

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
  /// 路线按钮点击回调，用于弹出路线规划底部弹窗
  final VoidCallback? onRouteTap;
  
  /// 地图控制器，用于获取当前位置
  /// 当用户点击"我的位置"时，通过此控制器获取 GPS 坐标
  final AmapMapController? mapController;

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
    // 初始化时加载历史位置记录和绑定者位置（延迟到 widget 构建完成后）
    Future.microtask(() {
      ref.read(locationInputProvider.notifier).loadHistoryLocations();
      ref.read(locationInputProvider.notifier).loadBinderLocations();
    });
  }

  /// 选择位置并收起键盘
  /// 
  /// 将选中的 POI 位置传递给导航状态管理器，并隐藏键盘
  void _selectLocationAndUnfocus(PoiSuggestion poi) {
    ref.read(locationInputProvider.notifier).selectLocation(
      poi,
      ref.read(mapNavigationProvider.notifier),
    );
    FocusScope.of(context).unfocus();
  }

  /// 隐藏列表并收起键盘
  /// 
  /// 调用状态管理器隐藏列表，同时隐藏键盘
  void _hideListAndUnfocus() {
    ref.read(locationInputProvider.notifier).hideList();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // 监听位置输入状态
    final state = ref.watch(locationInputProvider);
    // 判断当前是否为暗黑模式
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // 卡片背景样式
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
        // 垂直布局，高度根据内容自适应
        mainAxisSize: MainAxisSize.min,
        children: [
          // 分类按钮栏
          _buildCategoryBar(state, isDark),
          // 分隔线
          Container(height: 1, color: isDark ? AppColors.darkDividerColor : AppColors.grey200),
          // 列表内容区
          _buildListContent(state),
        ],
      ),
    );
  }

  /// 构建分类按钮栏
  /// 
  /// 包含 6 个元素（从左到右）：
  /// 1. 我的位置按钮
  /// 2. 绑定者按钮
  /// 3. 历史按钮
  /// 4. 路线按钮
  /// 5. Spacer（弹性空间）
  /// 6. 关闭按钮
  Widget _buildCategoryBar(LocationInputState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.sm,
        vertical: AppSpacings.sm,
      ),
      child: Row(
        children: [
          // 我的位置
          MyLocationButton(
            onTap: () => ref.read(locationInputProvider.notifier).fillMyLocation(
              () async => widget.mapController != null
                  ? await widget.mapController!.getCurrentLocation()
                  : null,
              ref.read(mapNavigationProvider.notifier),
            ),
          ),
          const SizedBox(width: AppSpacings.sm),
          // 绑定者
          LocationCategoryButton(
            label: '绑定者',
            icon: Icons.people,
            isSelected: state.selectedCategory != LocationCategory.none &&
                state.selectedCategory == LocationCategory.binder,
            onTap: () => ref.read(locationInputProvider.notifier).selectCategory(LocationCategory.binder),
          ),
          const SizedBox(width: AppSpacings.sm),
          // 历史
          LocationCategoryButton(
            label: '历史',
            icon: Icons.history,
            isSelected: state.selectedCategory != LocationCategory.none &&
                state.selectedCategory == LocationCategory.history,
            onTap: () => ref.read(locationInputProvider.notifier).selectCategory(LocationCategory.history),
          ),
          const SizedBox(width: AppSpacings.sm),
          // 路线按钮（点击弹出底部弹窗）
          LocationRouteButton(onTap: widget.onRouteTap),
          // 关闭按钮
          const Spacer(),
          LocationCloseButton(onTap: _hideListAndUnfocus),
        ],
      ),
    );
  }

  /// 构建列表内容区
  /// 
  /// 限制最大高度为 200，支持垂直滚动
  Widget _buildListContent(LocationInputState state) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacings.sm),
        child: _buildCategoryContent(state),
      ),
    );
  }

  /// 根据当前分类构建内容
  /// 
  /// 优先级：
  /// 1. 如果有搜索结果（或正在搜索、搜索错误），优先显示搜索结果
  /// 2. 否则根据选中的分类显示对应内容：
  ///    - recommended：已移除，显示空占位
  ///    - binder：显示"暂无可用绑定者位置"
  ///    - history：显示历史位置列表
  Widget _buildCategoryContent(LocationInputState state) {
    // 如果有搜索结果，显示搜索结果列表
    if (state.searchResults.isNotEmpty || state.isSearching || state.searchError != null) {
      return _buildPoiSearchResults(state);
    }

    switch (state.selectedCategory) {
      case LocationCategory.recommended:
        // 推荐分类已移除，点击"我的位置"按钮直接填入坐标
        return const SizedBox.shrink();
      case LocationCategory.binder:
      case LocationCategory.none:
        // none：搜索清除后默认显示绑定者内容
        return _buildBinderContent(state);
      case LocationCategory.history:
        return _buildHistoryContent(state);
    }
  }

  /// 构建 POI 搜索结果列表
  /// 
  /// 处理四种状态：
  /// - 加载中（isSearching）：显示加载动画
  /// - 搜索错误（searchError）：显示错误信息
  /// - 搜索结果为空：显示"未找到结果"
  /// - 有结果：显示位置列表项
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

  /// "绑定者" 内容
  ///
  /// 处理三种状态：
  /// - 加载中（isLoadingBinderItems）：显示加载动画
  /// - 无绑定者位置：显示"暂无绑定者位置"
  /// - 有绑定者位置：显示位置列表
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

  /// "历史" 内容
  /// 
  /// 处理三种状态：
  /// - 加载中（isLoadingHistory）：显示"加载中..."
  /// - 无历史记录：显示"暂无历史位置"
  /// - 有历史记录：显示历史位置列表
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
