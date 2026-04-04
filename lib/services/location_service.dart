import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';

/// 位置服务 - 负责获取用户位置信息

class LocationService {
  /// 检查位置权限状态
  static Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Logger.warning('位置服务未开启');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      Logger.auth('位置权限被拒绝，请求权限...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Logger.warning('位置权限被拒绝');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Logger.warning('位置权限被永久拒绝');
      return false;
    }

    Logger.authSuccess('位置权限已授权');
    return true;
  }

  /// 请求位置权限
  static Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Logger.warning('位置服务未开启，请前往设置开启');
      return false;
    }

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      Logger.warning('位置权限被拒绝');
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      Logger.warning('位置权限被永久拒绝，请前往设置开启');
      return false;
    }

    Logger.authSuccess('位置权限授权成功');
    return true;
  }

  /// 获取当前位置
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        return null;
      }

      Logger.auth('正在获取位置信息...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      Logger.authSuccess('获取位置成功: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      Logger.authError('获取位置失败: $e');
      return null;
    }
  }

  /// 获取位置流（实时位置更新）
  static Stream<Position>? getPositionStream() {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // 每移动 10 米更新一次
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// 打开位置设置页面
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// 打开应用设置页面（用于权限被永久拒绝的情况）
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// 计算两点之间的距离（米）
  static double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// 计算两点之间的方位角（度）
  static double bearingBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }
}