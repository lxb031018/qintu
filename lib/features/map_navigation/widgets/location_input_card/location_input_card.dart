import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_radii.dart';
import '../../../../constants/app_spacings.dart';
import '../../provider/location_input_provider.dart';
import 'route_type_selector.dart';
import 'swappable_location_row.dart';

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
          SwappableLocationRow(
            icon: Icons.place,
            placeholder: '起点',
            isOrigin: true,
            controller: _originController,
            focusNode: _originFocusNode,
            state: state.origin,
            onFocusChange: (hasFocus) {
              callbacks?.onOriginFocusChanged?.call(hasFocus);
            },
            onTap: (isOrigin) {
              callbacks?.onInputTap?.call(isOrigin);
            },
            onChanged: (value) {
              callbacks?.onOriginTextChanged?.call(value);
            },
            onClear: (isOrigin) {
              callbacks?.onClearField?.call(isOrigin);
            },
          ),
          const SizedBox(height: AppSpacings.sm),
          // 终点输入框
          SwappableLocationRow(
            icon: Icons.place,
            placeholder: '终点',
            isOrigin: false,
            controller: _destinationController,
            focusNode: _destinationFocusNode,
            state: state.destination,
            onFocusChange: (hasFocus) {
              callbacks?.onDestinationFocusChanged?.call(hasFocus);
            },
            onTap: (isOrigin) {
              callbacks?.onInputTap?.call(isOrigin);
            },
            onChanged: (value) {
              callbacks?.onDestinationTextChanged?.call(value);
            },
            onClear: (isOrigin) {
              callbacks?.onClearField?.call(isOrigin);
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
            RouteTypeSelector(isDark: isDark),
          ],
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
}