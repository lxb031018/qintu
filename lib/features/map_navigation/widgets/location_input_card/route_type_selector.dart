import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_spacings.dart';
import '../../models/amap_routing_models.dart';
import '../../provider/location_Input/location_input_provider.dart';
import '../../provider/map_navigation/map_navigation_provider.dart';
import 'route_type_button.dart';

class RouteTypeSelector extends ConsumerWidget {
  final bool isDark;

  const RouteTypeSelector({
    super.key,
    required this.isDark,
  });

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
            onTap: () => callbacks?.onRouteTypeSelected?.call(RouteType.walking),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacings.sm),
          RouteTypeButton(
            label: '骑行',
            isSelected: navState.currentRouteType == RouteType.riding,
            onTap: () => callbacks?.onRouteTypeSelected?.call(RouteType.riding),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacings.sm),
          RouteTypeButton(
            label: '公共交通',
            isSelected: navState.currentRouteType == RouteType.transit,
            onTap: () => callbacks?.onRouteTypeSelected?.call(RouteType.transit),
            isDark: isDark,
          ),
          SizedBox(width: AppSpacings.sm),
          RouteTypeButton(
            label: '出租车',
            isSelected: navState.currentRouteType == RouteType.driving,
            onTap: () => callbacks?.onRouteTypeSelected?.call(RouteType.driving),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}