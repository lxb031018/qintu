import '../../models/poi_models.dart';
import '../../models/route_option_model.dart';

abstract class MapNavigationService {
  void setOrigin(PoiSuggestion poi);
  void setDestination(PoiSuggestion poi);
  void clearOrigin();
  void clearDestination();
  Future<void> swapOriginAndDestination();
  Future<void> switchRouteType(RouteType type);
  void showRoutesSheet();
}