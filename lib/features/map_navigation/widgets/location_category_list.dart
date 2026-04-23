import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../../../widgets/map/amap_map_widget.dart';
import '../api/poi_api.dart';
import '../provider/location_input_provider.dart';
import '../provider/map_navigation_provider.dart';

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

enum LocationCategory {
  recommended, // 推荐地点
  binder,     // 绑定者位置
  history,    // 历史地点
}

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
  late LocationCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = LocationCategory.recommended;
    ref.read(locationInputProvider.notifier).loadHistoryLocations();
  }

  void _selectCategory(LocationCategory category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  /// 选择"我的位置"
  Future<void> _selectMyLocation() async {
    final controller = widget.mapController;
    if (controller == null) return;

    final poi = await ref.read(locationInputProvider.notifier).getMyLocation(
      () => controller.getCurrentLocation(),
    );
    if (poi != null && mounted) {
      _handleLocationSelected(poi);
    }
  }

  /// 处理位置选择
  void _handleLocationSelected(PoiSuggestion poi) {
    final state = ref.read(locationInputProvider);
    final notifier = ref.read(locationInputProvider.notifier);
    final mapNotifier = ref.read(mapNavigationProvider.notifier);

    if (state.isOriginFocused) {
      notifier.setOrigin(poi);
      mapNotifier.setOrigin(poi);
    } else {
      notifier.setDestination(poi);
      mapNotifier.setDestination(poi);
    }
    notifier.hideList();
    FocusScope.of(context).unfocus();
  }

  /// 选择历史位置
  void _selectHistoryItem(PoiSuggestion poi) {
    _handleLocationSelected(poi);
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
          _buildCategoryBar(isDark),
          // 分隔线
          Container(height: 1, color: isDark ? AppColors.darkDividerColor : AppColors.grey200),
          // 列表内容区
          _buildListContent(state, notifier),
        ],
      ),
    );
  }

  /// 构建分类按钮栏
  Widget _buildCategoryBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.sm,
        vertical: AppSpacings.sm,
      ),
      child: Row(
        children: [
          // 我的位置
          _CategoryButton(
            label: '我的位置',
            icon: Icons.my_location,
            isSelected: _selectedCategory == LocationCategory.recommended,
            onTap: () => _selectCategory(LocationCategory.recommended),
          ),
          const SizedBox(width: AppSpacings.sm),
          // 绑定者
          _CategoryButton(
            label: '绑定者',
            icon: Icons.people,
            isSelected: _selectedCategory == LocationCategory.binder,
            onTap: () => _selectCategory(LocationCategory.binder),
          ),
          const SizedBox(width: AppSpacings.sm),
          // 历史
          _CategoryButton(
            label: '历史',
            icon: Icons.history,
            isSelected: _selectedCategory == LocationCategory.history,
            onTap: () => _selectCategory(LocationCategory.history),
          ),
          const SizedBox(width: AppSpacings.sm),
          // 路线按钮（点击弹出底部弹窗）
          _RouteButton(onTap: widget.onRouteTap),
          // 关闭按钮
          const Spacer(),
          _CloseButton(onTap: () {
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

    switch (_selectedCategory) {
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
      children: state.searchResults.map((poi) => _ListItem(
        icon: Icons.place,
        iconColor: AppColors.primaryColor,
        title: poi.name,
        subtitle: poi.address.isNotEmpty ? poi.address : poi.district,
        onTap: () => _handleLocationSelected(poi),
      )).toList(),
    );
  }

  /// "我的位置" 内容
  Widget _buildMyLocationContent() {
    return _ListItem(
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
      children: state.historyItems.map((poi) => _ListItem(
        icon: Icons.history,
        iconColor: AppColors.grey600,
        title: poi.name,
        subtitle: poi.address.isNotEmpty ? poi.address : poi.district,
        onTap: () => _selectHistoryItem(poi),
      )).toList(),
    );
  }
}

/// ============================================
/// 列表项组件
/// ============================================

class _ListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ListItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.sm,
          vertical: AppSpacings.xs,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: AppSpacings.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// 分类按钮
/// ============================================

class _CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.sm,
          vertical: AppSpacings.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppColors.primaryColor
                  : (isDark ? AppColors.darkLightTextColor : AppColors.grey600),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? AppColors.darkLightTextColor : AppColors.grey600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// 路线按钮（入口，不参与列表分类）
/// ============================================

class _RouteButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _RouteButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacings.sm,
          vertical: AppSpacings.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route,
              size: 16,
              color: isDark ? AppColors.darkLightTextColor : AppColors.grey600,
            ),
            const SizedBox(width: 4),
            Text(
              '路线',
              style: TextStyle(
                fontSize: 12,
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
/// 关闭按钮
/// ============================================

class _CloseButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _CloseButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacings.xs),
        decoration: const BoxDecoration(
          color: AppColors.grey200,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close,
          size: 16,
          color: AppColors.grey600,
        ),
      ),
    );
  }
}