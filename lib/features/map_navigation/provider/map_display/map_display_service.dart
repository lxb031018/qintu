abstract class MapDisplayService {
  Future<void> setNaviShowMode(int mode);
  Future<void> moveCamera({required double lat, required double lng, double zoom = 15.0});
  Future<void> moveCameraToCenter({required double lat, required double lng, double zoom = 15.0});
}