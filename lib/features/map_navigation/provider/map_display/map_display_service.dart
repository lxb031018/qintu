/// ============================================
/// 地图显示服务接口
///
/// 定义地图控制器的基本操作接口
/// 由 MapControllerNotifier 实现
/// ============================================
abstract class MapDisplayService {
  Future<void> setNaviShowMode(int mode);
  Future<void> moveCamera({required double lat, required double lng, double zoom = 15.0});
  Future<void> moveCameraToCenter({required double lat, required double lng, double zoom = 15.0});
}