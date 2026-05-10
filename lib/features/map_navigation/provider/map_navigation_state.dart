import 'package:qintu/models/async_state.dart';
import '../models/poi_models.dart';
import '../models/amap_routing_models.dart';

class MapNavigationState {
  final String searchKeyword;
  final PoiSuggestion? originPoi;
  final PoiSuggestion? destinationPoi;
  final LatLng? originLocation;
  final LatLng? destinationLocation;
  final List<RouteOption> routes;
  final int selectedRouteIndex;
  final AsyncState<List<RouteOption>> routesState;
  final AsyncState<List<PoiSuggestion>> searchState;
  final bool isOriginFocused;
  final String? errorMessage;
  final RouteType? currentRouteType;
  final bool showRoutesSheet;
  final bool isNavigating;
  final double navSpeed;
  final int navRemainingDistance;
  final int navRemainingTime;
  final String navNextRoad;
  final String navCurrentRoad;

  const MapNavigationState({
    this.searchKeyword = '',
    this.originPoi,
    this.destinationPoi,
    this.originLocation,
    this.destinationLocation,
    this.routes = const [],
    this.selectedRouteIndex = 0,
    this.routesState = const AsyncState.loading(),
    this.searchState = const AsyncState.loading(),
    this.isOriginFocused = true,
    this.errorMessage,
    this.currentRouteType,
    this.showRoutesSheet = false,
    this.isNavigating = false,
    this.navSpeed = 0,
    this.navRemainingDistance = 0,
    this.navRemainingTime = 0,
    this.navNextRoad = '',
    this.navCurrentRoad = '',
  });

  bool get canPlanRoute => originLocation != null && destinationLocation != null;

  RouteOption? get selectedRoute =>
      routes.isNotEmpty && selectedRouteIndex < routes.length
          ? routes[selectedRouteIndex]
          : null;

  MapNavigationState copyWith({
    String? searchKeyword,
    PoiSuggestion? originPoi,
    PoiSuggestion? destinationPoi,
    LatLng? originLocation,
    LatLng? destinationLocation,
    List<RouteOption>? routes,
    int? selectedRouteIndex,
    AsyncState<List<RouteOption>>? routesState,
    AsyncState<List<PoiSuggestion>>? searchState,
    bool? isOriginFocused,
    String? errorMessage,
    RouteType? currentRouteType,
    bool clearCurrentRouteType = false,
    bool? showRoutesSheet,
    bool? isNavigating,
    double? navSpeed,
    int? navRemainingDistance,
    int? navRemainingTime,
    String? navNextRoad,
    String? navCurrentRoad,
  }) {
    return MapNavigationState(
      searchKeyword: searchKeyword ?? this.searchKeyword,
      originPoi: originPoi ?? this.originPoi,
      destinationPoi: destinationPoi ?? this.destinationPoi,
      originLocation: originLocation ?? this.originLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      routes: routes ?? this.routes,
      selectedRouteIndex: selectedRouteIndex ?? this.selectedRouteIndex,
      routesState: routesState ?? this.routesState,
      searchState: searchState ?? this.searchState,
      isOriginFocused: isOriginFocused ?? this.isOriginFocused,
      errorMessage: errorMessage,
      currentRouteType: clearCurrentRouteType ? null : (currentRouteType ?? this.currentRouteType),
      showRoutesSheet: showRoutesSheet ?? this.showRoutesSheet,
      isNavigating: isNavigating ?? this.isNavigating,
      navSpeed: navSpeed ?? this.navSpeed,
      navRemainingDistance: navRemainingDistance ?? this.navRemainingDistance,
      navRemainingTime: navRemainingTime ?? this.navRemainingTime,
      navNextRoad: navNextRoad ?? this.navNextRoad,
      navCurrentRoad: navCurrentRoad ?? this.navCurrentRoad,
    );
  }
}