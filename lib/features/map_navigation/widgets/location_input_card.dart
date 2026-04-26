import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../models/amap_routing_models.dart';
import '../provider/location_input_provider.dart';
import '../provider/map_navigation_provider.dart';

/// ============================================
/// 地点输入卡片
///
/// 父组件，管理输入框和列表的显示状态
/// 列表出现后只有点击 (x) 按钮才会消失
/// 支持上下滑动交换起点和终点
///
/// 架构原则：单向数据流
/// - 用户输入 → Provider（仅更新文本，不自动清除 POI）
/// - POI 选择 → Provider → UI（由用户主动操作触发）
/// - Provider 不自动覆盖用户输入
/// ============================================

class LocationInputCard extends ConsumerStatefulWidget {
  const LocationInputCard({super.key});

  @override
  ConsumerState<LocationInputCard> createState() => _LocationInputCardState();
}

class _LocationInputCardState extends ConsumerState<LocationInputCard> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _originFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  /// 记录手指按下时的 Y 坐标
  double? _dragStartY;

  @override
  void initState() {
    super.initState();
    // 初始化控制器文本
    final state = ref.read(locationInputProvider);
    _originController.text = state.origin.text;
    _destinationController.text = state.destination.text;
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _originFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  /// 处理起点输入框文本变化
  void _onOriginTextChanged(String value) {
    ref.read(locationInputProvider.notifier).updateText(true, value);
    ref.read(locationInputProvider.notifier).updateSearchKeyword(value);
  }

  /// 处理终点输入框文本变化
  void _onDestinationTextChanged(String value) {
    ref.read(locationInputProvider.notifier).updateText(false, value);
    ref.read(locationInputProvider.notifier).updateSearchKeyword(value);
  }

  /// 执行交换逻辑
  void _performSwap() {
    ref.read(locationInputProvider.notifier).swapOriginAndDestination(
      ref.read(mapNavigationProvider.notifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(locationInputProvider);

    // 同步控制器文本（仅在必要时刻）
    _syncControllers(state);

    return Container(
      padding: const EdgeInsets.all(AppSpacings.sm),
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
          // 起点输入框
          _buildSwappableInputRow(
            context: context,
            isDark: isDark,
            icon: Icons.my_location,
            placeholder: '起点',
            isOrigin: true,
            controller: _originController,
            focusNode: _originFocusNode,
            state: state.origin,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                ref.read(locationInputProvider.notifier).showList(isOrigin: true);
              }
            },
          ),
          const SizedBox(height: AppSpacings.sm),
          // 终点输入框
          _buildSwappableInputRow(
            context: context,
            isDark: isDark,
            icon: Icons.place,
            placeholder: '终点',
            isOrigin: false,
            controller: _destinationController,
            focusNode: _destinationFocusNode,
            state: state.destination,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                ref.read(locationInputProvider.notifier).showList(isOrigin: false);
              }
            },
          ),
          // 当起点和终点都有真实 POI 时，显示出行方式按钮和路线按钮
          if (state.origin.poi != null && state.destination.poi != null) ...[
            const SizedBox(height: AppSpacings.sm),
            Container(
              height: 1,
              color: isDark ? AppColors.darkDividerColor : AppColors.grey200,
            ),
            const SizedBox(height: AppSpacings.sm),
            _buildRouteTypeRow(context, ref, isDark),
          ],
        ],
      ),
    );
  }

  /// 构建出行方式选择行
  ///
  /// 显示四种出行方式按钮（步行、骑行、公共交通、驾车）和"路线"按钮
  Widget _buildRouteTypeRow(BuildContext context, WidgetRef ref, bool isDark) {
    final navState = ref.watch(mapNavigationProvider);

    return Row(
      children: [
        // 步行
        _RouteTypeButton(
          label: '步行',
          icon: Icons.directions_walk,
          isSelected: navState.currentRouteType == RouteType.walking,
          onTap: () => ref.read(mapNavigationProvider.notifier).switchRouteType(RouteType.walking),
          isDark: isDark,
        ),
        // 骑行
        _RouteTypeButton(
          label: '骑行',
          icon: Icons.directions_bike,
          isSelected: navState.currentRouteType == RouteType.riding,
          onTap: () => ref.read(mapNavigationProvider.notifier).switchRouteType(RouteType.riding),
          isDark: isDark,
        ),
        // 公共交通
        _RouteTypeButton(
          label: '公共交通',
          icon: Icons.directions_bus,
          isSelected: navState.currentRouteType == RouteType.transit,
          onTap: () => ref.read(mapNavigationProvider.notifier).switchRouteType(RouteType.transit),
          isDark: isDark,
        ),
        // 驾车
        _RouteTypeButton(
          label: '驾车',
          icon: Icons.directions_car,
          isSelected: navState.currentRouteType == RouteType.driving,
          onTap: () => ref.read(mapNavigationProvider.notifier).switchRouteType(RouteType.driving),
          isDark: isDark,
        ),
        // 路线按钮
        const SizedBox(width: AppSpacings.sm),
        _RouteButton(
          onTap: () => _showRouteResultSheet(ref),
        ),
      ],
    );
  }

  /// 显示路线栏
  void _showRouteResultSheet(WidgetRef ref) {
    ref.read(mapNavigationProvider.notifier).showRoutesSheet();
  }

  /// 同步控制器文本
  /// 仅当 Provider 中的文本与控制器文本不同时才更新
  void _syncControllers(LocationInputState state) {
    if (_originController.text != state.origin.text) {
      _originController.text = state.origin.text;
    }
    if (_destinationController.text != state.destination.text) {
      _destinationController.text = state.destination.text;
    }
  }

  /// 构建可滑动的输入行
  Widget _buildSwappableInputRow({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String placeholder,
    required bool isOrigin,
    required TextEditingController controller,
    required FocusNode focusNode,
    required InputFieldState state,
    required ValueChanged<bool> onFocusChange,
  }) {
    return Listener(
      onPointerDown: (event) {
        _dragStartY = event.position.dy;
      },
      onPointerUp: (event) {
        if (_dragStartY == null) return;
        final dragEndY = event.position.dy;
        final deltaY = dragEndY - _dragStartY!;
        _dragStartY = null;

        if (deltaY.abs() > 50) {
          _performSwap();
        }
      },
      child: _buildInputRow(
        context: context,
        isDark: isDark,
        icon: icon,
        placeholder: placeholder,
        isOrigin: isOrigin,
        controller: controller,
        focusNode: focusNode,
        state: state,
        onFocusChange: onFocusChange,
      ),
    );
  }

  /// 构建输入行
  Widget _buildInputRow({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String placeholder,
    required bool isOrigin,
    required TextEditingController controller,
    required FocusNode focusNode,
    required InputFieldState state,
    required ValueChanged<bool> onFocusChange,
  }) {
    return Focus(
      onFocusChange: onFocusChange,
      child: Row(
        children: [
          // 图标
          Padding(
            padding: const EdgeInsets.all(AppSpacings.sm),
            child: Icon(
              icon,
              size: 20,
              color: isOrigin ? AppColors.primaryColor : AppColors.warningColor,
            ),
          ),
          // 输入框
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: isOrigin ? _onOriginTextChanged : _onDestinationTextChanged,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(
                  color: AppColors.grey400,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(
                  left: AppSpacings.sm,
                  right: AppSpacings.sm,
                  top: AppSpacings.sm,
                  bottom: AppSpacings.sm,
                ),
              ),
            ),
          ),
          // 清除按钮
          if (state.hasText)
            GestureDetector(
              onTap: () {
                ref.read(locationInputProvider.notifier).clearField(
                  isOrigin,
                  ref.read(mapNavigationProvider.notifier),
                );
                if (isOrigin) {
                  _originController.clear();
                } else {
                  _destinationController.clear();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacings.sm),
                child: Icon(
                  Icons.clear,
                  size: 18,
                  color: AppColors.grey400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 出行方式按钮
class _RouteTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _RouteTypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacings.xs),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.all(AppRadii.small),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? AppColors.darkLightTextColor : AppColors.grey500),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primaryColor
                      : (isDark ? AppColors.darkLightTextColor : AppColors.grey500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 路线按钮
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
          horizontal: AppSpacings.md,
          vertical: AppSpacings.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.all(AppRadii.small),
        ),
        child: Text(
          '路线',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextColor : Colors.white,
          ),
        ),
      ),
    );
  }
}