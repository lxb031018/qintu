import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/background/background_location_channel.dart';

/// ============================================
/// 后台定位服务（service 层）
///
/// 管理后台定位生命周期。运行时状态由 channel 层持有。
/// provider 层通过全局单例 [backgroundLocationService] 访问。
/// ============================================
class BackgroundLocationService {
  final BackgroundLocationChannel _channel;

  BackgroundLocationService({BackgroundLocationChannel? channel})
      : _channel = channel ?? BackgroundLocationChannel();

  /// 启动后台定位并开始监听
  ///
  /// [onUpdate] 每次收到位置时回调，传递标准化的位置 Map
  Future<bool> start({
    void Function(Map<String, dynamic> location)? onUpdate,
  }) async {
    final success = await _channel.start();
    if (success) {
      _channel.listenLocationUpdates(
        onLocationUpdate: (location) {
          if (onUpdate != null) onUpdate(location);
        },
        onError: (_) {
          // 定位错误由 channel 层已记录日志
        },
      );
    }
    return success;
  }

  /// 停止后台定位
  Future<bool> stop() => _channel.stop();

  void dispose() => _channel.dispose();
}

/// 全局单例
final backgroundLocationServiceProvider = Provider<BackgroundLocationService>((ref) => BackgroundLocationService());
