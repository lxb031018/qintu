/// ============================================
/// 地图显示服务 Provider
///
/// 提供 MapDisplayService 接口实现
/// 委托给 mapControllerNotifierProvider.notifier
/// ============================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'map_display_service.dart';
import 'map_controller_provider.dart';

final mapDisplayServiceProvider = Provider<MapDisplayService>((ref) {
  return ref.read(mapControllerNotifierProvider.notifier);
});