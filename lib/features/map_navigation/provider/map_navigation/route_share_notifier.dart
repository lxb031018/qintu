import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/route_share_api.dart';
import '../../models/poi_models.dart';
import '../../models/route_option_model.dart';
import '../../service/route_share_service.dart';
import 'map_navigation_notifier.dart';

/// ============================================
/// 路由分享状态
/// ============================================
class RouteShareState {
  final bool isSharing;
  final String? errorMessage;
  final List<PendingRouteShare> pendingShares;
  final bool isPolling;
  final PendingRouteShare? latestShare;

  const RouteShareState({
    this.isSharing = false,
    this.errorMessage,
    this.pendingShares = const [],
    this.isPolling = false,
    this.latestShare,
  });

  RouteShareState copyWith({
    bool? isSharing,
    String? errorMessage,
    List<PendingRouteShare>? pendingShares,
    bool? isPolling,
    PendingRouteShare? latestShare,
    bool clearLatestShare = false,
  }) {
    return RouteShareState(
      isSharing: isSharing ?? this.isSharing,
      errorMessage: errorMessage,
      pendingShares: pendingShares ?? this.pendingShares,
      isPolling: isPolling ?? this.isPolling,
      latestShare: clearLatestShare ? null : (latestShare ?? this.latestShare),
    );
  }
}

/// ============================================
/// 路由分享 Notifier
///
/// 处理路由分享的UI状态管理，以及待接收分享的轮询
/// ============================================
class RouteShareNotifier extends Notifier<RouteShareState> {
  late final RouteShareService _service = ref.read(routeShareServiceProvider);
  Timer? _pollingTimer;

  static const _pollingIntervalSeconds = 2;

  @override
  RouteShareState build() {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    return const RouteShareState();
  }

  Future<bool> shareRoute({
    required String binderOpenid,
    required PoiSuggestion origin,
    required PoiSuggestion destination,
    required RouteType routeType,
    required int routeId,
  }) async {
    if (state.isSharing) {
      return false;
    }

    state = state.copyWith(isSharing: true, errorMessage: null);

    try {
      await _service.shareRoute(
        binderOpenid: binderOpenid,
        origin: origin,
        destination: destination,
        routeType: routeType,
        routeId: routeId,
      );
      state = state.copyWith(isSharing: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSharing: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 启动轮询
  void startPolling() {
    if (state.isPolling) return;

    state = state.copyWith(isPolling: true, errorMessage: null);
    _fetchOnce();

    _pollingTimer = Timer.periodic(
      const Duration(seconds: _pollingIntervalSeconds),
      (_) => _fetchOnce(),
    );
  }

  /// 停止轮询
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    state = state.copyWith(isPolling: false);
  }

  /// 执行一次获取
  Future<void> _fetchOnce() async {
    try {
      final newShares = await _service.getPendingShares();

      if (newShares.isNotEmpty) {
        final existingIds = state.pendingShares.map((s) => s.id).toSet();
        final newOnes = newShares.where((s) => !existingIds.contains(s.id)).toList();

        if (newOnes.isNotEmpty) {
          final latest = newOnes.first;
          state = state.copyWith(
            pendingShares: newShares,
            latestShare: latest,
          );
          _triggerNavigation(latest);
        } else {
          state = state.copyWith(pendingShares: newShares);
        }
      } else {
        state = state.copyWith(pendingShares: []);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 将分享数据设置到 MapNavigationNotifier 并触发算路
  void _triggerNavigation(PendingRouteShare share) {
    final origin = _toPoiSuggestion(
      lat: share.originLat,
      lng: share.originLng,
      name: share.originName,
      address: share.originAddress,
    );

    final dest = _toPoiSuggestion(
      lat: share.destLat,
      lng: share.destLng,
      name: share.destName,
      address: share.destAddress,
    );

    final routeType = _service.stringToRouteType(share.routeType);
    final targetRouteId = share.routeId;

    ref.read(mapNavigationProvider.notifier).setOrigin(origin);
    ref.read(mapNavigationProvider.notifier).setDestination(dest);

    // 监听 routes 变化，算路完成后自动开始导航
    ref.listen(mapNavigationProvider.select((s) => s.routes), (previous, next) {
      if (next.isEmpty) return;

      // 找到匹配的路线
      final index = targetRouteId >= 0
          ? next.indexWhere((r) => r.routeId == targetRouteId)
          : 0;
      if (index >= 0) {
        ref.read(mapNavigationProvider.notifier).selectRoute(index);
      }

      // 直接开始导航，不显示预览路线 sheet
      ref.read(mapNavigationProvider.notifier).startNavigation();
    });

    ref.read(mapNavigationProvider.notifier).switchRouteType(routeType);
  }

  PoiSuggestion _toPoiSuggestion({
    required double lat,
    required double lng,
    required String name,
    required String address,
  }) {
    return PoiSuggestion(
      id: '',
      name: name,
      district: '',
      address: address,
      location: '$lng,$lat',
      source: PoiSource.history,
    );
  }

  /// 清除最新分享
  void clearLatestShare() {
    state = state.copyWith(clearLatestShare: true);
  }
}

final routeShareNotifierProvider =
    NotifierProvider<RouteShareNotifier, RouteShareState>(
  RouteShareNotifier.new,
);