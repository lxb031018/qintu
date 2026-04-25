import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';
import '../provider/location_input_provider.dart';
import '../provider/map_navigation_provider.dart';

/// ============================================
/// 地点输入卡片
///
/// 父组件，管理输入框和列表的显示状态
/// 列表出现后只有点击 (x) 按钮才会消失
/// 支持上下滑动交换起点和终点
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
    // 监听起点输入框文本变化
    _originController.addListener(_onOriginTextChanged);
    // 监听终点输入框文本变化
    _destinationController.addListener(_onDestinationTextChanged);
  }

  /// 将 provider 的 POI 同步到 TextEditingController
  ///
  /// 仅当输入框当前文本与 POI 名称不同时才更新，
  /// 避免用户正在输入时覆盖已有文字。
  void _syncControllerFromProvider(LocationInputState state) {
    final newOriginText = state.originPoi?.name ?? '';
    final newDestinationText = state.destinationPoi?.name ?? '';
    // 仅在文本不同时才更新，避免覆盖用户正在输入的内容
    if (_originController.text != newOriginText) {
      _originController.text = newOriginText;
    }
    if (_destinationController.text != newDestinationText) {
      _destinationController.text = newDestinationText;
    }
  }

  /// 起点文本变化监听：用户清空文本时清除 POI 状态
  void _onOriginTextChanged() {
    if (_originController.text.isEmpty) {
      ref.read(locationInputProvider.notifier).clearOrigin();
      ref.read(mapNavigationProvider.notifier).clearOrigin();
    }
  }

  /// 终点文本变化监听：用户清空文本时清除 POI 状态
  void _onDestinationTextChanged() {
    if (_destinationController.text.isEmpty) {
      ref.read(locationInputProvider.notifier).clearDestination();
      ref.read(mapNavigationProvider.notifier).clearDestination();
    }
  }

  @override
  void dispose() {
    _originController.removeListener(_onOriginTextChanged);
    _destinationController.removeListener(_onDestinationTextChanged);
    _originController.dispose();
    _destinationController.dispose();
    _originFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 监听 provider 变化，同步 POI 到 TextEditingController
    final state = ref.watch(locationInputProvider);
    _syncControllerFromProvider(state);

    return Container(
      // 卡片内边距: sm（上下左右均为 sm，内容到卡边）
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
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                ref.read(locationInputProvider.notifier).showList(isOrigin: true);
              }
            },
          ),
          // 间距: sm（终点输入框上面的总间距为 sm）
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
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                ref.read(locationInputProvider.notifier).showList(isOrigin: false);
              }
            },
          ),
        ],
      ),
    );
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

        // 滑动了 50px 以上才认为是交换手势
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
        onFocusChange: onFocusChange,
        onTextChanged: (value) {
          ref.read(locationInputProvider.notifier).updateSearchKeyword(value);
        },
      ),
    );
  }

  /// 执行交换逻辑
  void _performSwap() {
    final state = ref.read(locationInputProvider);
    final notifier = ref.read(locationInputProvider.notifier);

    // 判断是否可以交换
    if (!notifier.canSwapOriginAndDestination()) {
      return;
    }

    // 保存交换前的 POI（用于更新输入框）
    final newOrigin = state.destinationPoi;
    final newDestination = state.originPoi;

    // 更新 provider
    notifier.swapOriginAndDestination(ref.read(mapNavigationProvider.notifier));

    // 同步更新输入框文本
    if (newOrigin != null) {
      _originController.text = newOrigin.name;
    } else {
      _originController.clear();
    }
    if (newDestination != null) {
      _destinationController.text = newDestination.name;
    } else {
      _destinationController.clear();
    }
  }

  /// 构建输入行
  /// - 输入框左/右边的总间距为 sm
  /// - 输入框上面的总间距为 sm（首行由 Card 的 top padding 处理）
  /// - 输入框下面的总间距为 sm（末行由 Card 的 bottom padding 处理）
  /// - 图标在输入框内的左边距、上边距、右边距、下边距一样大（均为 sm）
  Widget _buildInputRow({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String placeholder,
    required bool isOrigin,
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<bool> onFocusChange,
    ValueChanged<String>? onTextChanged,
  }) {
    return Focus(
      onFocusChange: onFocusChange,
      child: Row(
        children: [
          // 图标: sm 内边距（上下左右均为 sm）
          Padding(
            padding: const EdgeInsets.all(AppSpacings.sm),
            child: Icon(
              icon,
              size: 20,
              color: isOrigin ? AppColors.primaryColor : AppColors.warningColor,
            ),
          ),
          // 输入框: 占据剩余空间
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onTextChanged,
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
        ],
      ),
    );
  }
}