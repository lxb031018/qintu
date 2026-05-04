import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../../../widgets/common/qintu_pill_chip.dart';
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
/// - Widget 通过 callback 与 Provider 交互
/// - 不直接调用 notifier 方法
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(locationInputProvider);
    final callbacks = state.callbacks;

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
            icon: Icons.place,
            placeholder: '起点',
            isOrigin: true,
            controller: _originController,
            focusNode: _originFocusNode,
            state: state.origin,
            onFocusChange: (hasFocus) {
              callbacks?.onOriginFocusChanged?.call(hasFocus);
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
              callbacks?.onDestinationFocusChanged?.call(hasFocus);
            },
          ),
          // 当起点和终点都有真实 POI 时，显示出行方式按钮
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
  /// 显示四种出行方式按钮（步行、骑行、公共交通、驾车）
  /// 选择任意出行方式后自动弹出路线结果
  Widget _buildRouteTypeRow(BuildContext context, WidgetRef ref, bool isDark) {
    final navState = ref.watch(mapNavigationProvider);
    final callbacks = ref.read(locationInputProvider).callbacks;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 步行
          _RouteTypeButton(
            label: '步行',
            isSelected: navState.currentRouteType == RouteType.walking,
            onTap: () {
              callbacks?.onRouteTypeSelected?.call(RouteType.walking);
            },
            isDark: isDark,
          ),
          SizedBox(width: AppSpacings.sm),
          // 骑行
          _RouteTypeButton(
            label: '骑行',
            isSelected: navState.currentRouteType == RouteType.riding,
            onTap: () {
              callbacks?.onRouteTypeSelected?.call(RouteType.riding);
            },
            isDark: isDark,
          ),
          SizedBox(width: AppSpacings.sm),
          // 电动自行车
          _RouteTypeButton(
            label: '电动车',
            isSelected: navState.currentRouteType == RouteType.eleBike,
            onTap: () {
              callbacks?.onRouteTypeSelected?.call(RouteType.eleBike);
            },
            isDark: isDark,
          ),
          SizedBox(width: AppSpacings.sm),
          // 公共交通
          _RouteTypeButton(
            label: '公共交通',
            isSelected: navState.currentRouteType == RouteType.transit,
            onTap: () {
              callbacks?.onRouteTypeSelected?.call(RouteType.transit);
            },
            isDark: isDark,
          ),
          SizedBox(width: AppSpacings.sm),
          // 驾车
          _RouteTypeButton(
            label: '驾车',
            isSelected: navState.currentRouteType == RouteType.driving,
            onTap: () {
              callbacks?.onRouteTypeSelected?.call(RouteType.driving);
            },
            isDark: isDark,
          ),
        ],
      ),
    );
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
          ref.read(locationInputProvider).callbacks?.onSwapRequested?.call();
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
    final callbacks = ref.read(locationInputProvider).callbacks;

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
              color: isOrigin ? AppColors.successColor : AppColors.errorColor,
            ),
          ),
          // 输入框
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onTap: () {
                callbacks?.onInputTap?.call(isOrigin);
              },
              onChanged: isOrigin
                  ? (value) {
                      callbacks?.onOriginTextChanged?.call(value);
                    }
                  : (value) {
                      callbacks?.onDestinationTextChanged?.call(value);
                    },
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
                callbacks?.onClearField?.call(isOrigin);
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
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _RouteTypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return QintuPillChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      height: 36,
      selectedBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
      selectedTextColor: AppColors.primaryColor,
      unselectedTextColor: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
      selectedBorderColor: AppColors.primaryColor,
    );
  }
}