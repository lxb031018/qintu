import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_spacings.dart';
import '../../provider/location_input_provider.dart';
import '../../provider/map_controller_provider.dart';
import '../../provider/map_navigation_provider.dart';
import 'category_button.dart';
import 'close_button.dart';
import '../my_location_button.dart';

/// ============================================
/// 分类标签栏组件
///
/// 显示"我的位置"、"绑定者"、"历史"三个标签按钮
/// 右侧包含关闭按钮
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
                    onTap: () => ref.read(locationInputProvider.notifier).fillMyLocation(
                      () async => mapController != null
                          ? await mapController.getCurrentLocation()
                          : null,
                      ref.read(mapNavigationProvider.notifier),
                    ),
                  ),
                  const SizedBox(width: AppSpacings.sm),
                  LocationCategoryButton(
                    label: '绑定者',
                    icon: Icons.people,
                    isSelected: state.selectedCategory != LocationCategory.none &&
                        state.selectedCategory == LocationCategory.binder,
                    onTap: () => ref.read(locationInputProvider.notifier).selectCategory(LocationCategory.binder),
                  ),
                  const SizedBox(width: AppSpacings.sm),
                  LocationCategoryButton(
                    label: '历史',
                    icon: Icons.history,
                    isSelected: state.selectedCategory != LocationCategory.none &&
                        state.selectedCategory == LocationCategory.history,
                    onTap: () => ref.read(locationInputProvider.notifier).selectCategory(LocationCategory.history),
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