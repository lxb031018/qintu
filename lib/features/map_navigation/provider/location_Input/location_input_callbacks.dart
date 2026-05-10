import '../../models/poi_models.dart';
import '../../models/amap_routing_models.dart';
import 'location_category.dart';

/// ============================================
/// 位置输入卡片回调函数集合
///
/// 定义位置输入卡片的各类交互回调
/// 供 Widget 层与 Provider 层解耦使用
/// ============================================
class LocationInputCardCallbacks {
  final void Function(String value)? onOriginTextChanged;
  final void Function(String value)? onDestinationTextChanged;
  final void Function()? onSwapRequested;
  final void Function(bool isOrigin)? onClearField;
  final void Function(bool hasFocus)? onOriginFocusChanged;
  final void Function(bool hasFocus)? onDestinationFocusChanged;
  final void Function(RouteType type)? onRouteTypeSelected;
  final void Function(bool isOrigin)? onInputTap;
  final void Function()? onHideList;
  final void Function(PoiSuggestion poi)? onSelectPoi;
  final void Function()? onExitHistorySelectionMode;
  final void Function(String poiId)? onToggleHistorySelection;
  final void Function()? onSelectAllHistory;
  final void Function()? onDeleteSelectedHistory;
  final void Function()? onEnterHistorySelectionMode;
  final void Function(Future<Map<String, dynamic>?> Function() getCurrentLocationFn)? onFillMyLocation;
  final void Function(LocationCategory category)? onSelectCategory;

  const LocationInputCardCallbacks({
    this.onOriginTextChanged,
    this.onDestinationTextChanged,
    this.onSwapRequested,
    this.onClearField,
    this.onOriginFocusChanged,
    this.onDestinationFocusChanged,
    this.onRouteTypeSelected,
    this.onInputTap,
    this.onHideList,
    this.onSelectPoi,
    this.onExitHistorySelectionMode,
    this.onToggleHistorySelection,
    this.onSelectAllHistory,
    this.onDeleteSelectedHistory,
    this.onEnterHistorySelectionMode,
    this.onFillMyLocation,
    this.onSelectCategory,
  });
}