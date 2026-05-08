import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_spacings.dart';
import '../../models/amap_routing_models.dart';
import '../../provider/location_input_provider.dart';
import '../../provider/map_navigation_provider.dart';
import 'route_type_button.dart';

/// 出行方式选择器
///
/// 四种出行方式按钮水平排列：步行、骑行、公共交通、驾车
class RouteTypeSelector extends ConsumerWidget {
  final bool isDark;

  const RouteTypeSelector({
    super.key,
    required this.isDark,
  });

  void _onRouteTypeTap(WidgetRef ref, LocationInputCardCallbacks? callbacks, RouteType type) {
    if (callbacks != null) {
      callbacks.onRouteTypeSelected?.call(type);
    } else {
      ref.read(mapNavigationProvider.notifier).switchRouteType(type);
      ref.read(mapNavigationProvider.notifier).showRoutesSheet();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(mapNavigationProvider);
    final callbacks = ref.read(locationInputProvider).callbacks;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          RouteTypeButton(
            label: '步行',
            isSelected: navState.currentRouteType == RouteType.walking,
            onTap: () => _onRouteTypeTap(ref, callbacks, RouteType.walking),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacings.sm),
          RouteTypeButton(
            label: '骑行',
            isSelected: navState.currentRouteType == RouteType.riding,
            onTap: () => _onRouteTypeTap(ref, callbacks, RouteType.riding),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacings.sm),
          RouteTypeButton(
            label: '公共交通',
            isSelected: navState.currentRouteType == RouteType.transit,
            onTap: () => _onRouteTypeTap(ref, callbacks, RouteType.transit),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacings.sm),
          RouteTypeButton(
            label: '出租车',
            isSelected: navState.currentRouteType == RouteType.driving,
            onTap: () => _onRouteTypeTap(ref, callbacks, RouteType.driving),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}