import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_spacings.dart';
import '../../provider/location_Input/location_input_provider.dart';
import '../../provider/map_display/map_controller_provider.dart';
import 'category_button.dart';
import 'close_button.dart';
import '../my_location_button.dart';

/// ============================================
/// 位置分类 Tab 栏组件
///
/// 显示在地图顶部的分类按钮栏，包含：
/// - 我的位置按钮
/// - 绑定者分类按钮
/// - 历史分类按钮
/// - 关闭按钮
///
/// 架构原则：单向数据流
/// - Widget 通过 callback 与 Provider 交互
/// - 不直接调用 notifier 方法
/// ============================================
class CategoryTabBar extends ConsumerWidget {
  final LocationInputState state;
  final VoidCallback onClose;

  const CategoryTabBar({
    super.key,
    required this.state,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapController = ref.watch(mapControllerNotifierProvider);
    final callbacks = ref.read(locationInputProvider).callbacks;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.sm,
        vertical: AppSpacings.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  MyLocationButton(
                    onTap: () {
                      if (mapController != null) {
                        callbacks?.onFillMyLocation?.call(
                          () async => await mapController.getCurrentLocation(),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: AppSpacings.sm),
                  LocationCategoryButton(
                    label: '绑定者',
                    icon: Icons.people,
                    isSelected: state.selectedCategory != LocationCategory.none &&
                        state.selectedCategory == LocationCategory.binder,
                    onTap: () => callbacks?.onSelectCategory?.call(LocationCategory.binder),
                  ),
                  const SizedBox(width: AppSpacings.sm),
                  LocationCategoryButton(
                    label: '历史',
                    icon: Icons.history,
                    isSelected: state.selectedCategory != LocationCategory.none &&
                        state.selectedCategory == LocationCategory.history,
                    onTap: () => callbacks?.onSelectCategory?.call(LocationCategory.history),
                  ),
                ],
              ),
            ),
          ),
          LocationCloseButton(onTap: onClose),
        ],
      ),
    );
  }
}