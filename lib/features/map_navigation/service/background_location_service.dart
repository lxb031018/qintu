import '../../../core/background/background_location_channel.dart';

/// ============================================
/// 后台定位服务（service 层）
///
/// 管理后台定位生命周期和状态。
/// provider 层通过全局单例 [backgroundLocationService] 访问。
/// ============================================
class BackgroundLocationService {
  final BackgroundLocationChannel _channel;

  BackgroundLocationService({BackgroundLocationChannel? channel})
      : _channel = channel ?? BackgroundLocationChannel();

  bool _isRunning = false;
  Map<String, dynamic>? _lastLocation;

  bool get isRunning => _isRunning;
  Map<String, dynamic>? get lastLocation => _lastLocation;

  /// 启动后台定位并开始监听
  ///
  /// [onUpdate] 每次收到位置时回调，传递标准化的位置 Map
  Future<bool> start({
    void Function(Map<String, dynamic> location)? onUpdate,
  }) async {
    final success = await _channel.start();
    if (success) {
      _isRunning = true;
      _channel.listenLocationUpdates(
        onLocationUpdate: (location) {
          _lastLocation = location;
          onUpdate?.call(location);
        },
        onError: (_) {
          // 定位错误由 channel 层已记录日志
        },
      );
    }
    return success;
  }

  /// 停止后台定位
  Future<bool> stop() async {
    final success = await _channel.stop();
    if (success) {
      _isRunning = false;
      _lastLocation = null;
    }
    return success;
  }

  void dispose() => _channel.dispose();
}

/// 全局单例
final backgroundLocationService = BackgroundLocationService();
