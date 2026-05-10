/// ============================================
/// 地图导航服务 Provider
///
/// 提供 MapNavigationService 接口实现
/// 委托给 mapNavigationProvider.notifier
/// ============================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'map_navigation_provider.dart';

final mapNavigationServiceProvider = Provider<MapNavigationService>((ref) {
  return ref.read(mapNavigationProvider.notifier);
});