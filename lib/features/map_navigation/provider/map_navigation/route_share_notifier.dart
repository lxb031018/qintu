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

/// 分享结果（供 widget 决定 UI 提示）
class ShareRouteResult {
  final bool isSuccess;
  final String? errorMessage;

  const ShareRouteResult._({required this.isSuccess, this.errorMessage});

  const ShareRouteResult.success() : this._(isSuccess: true);

  const ShareRouteResult.error(String message)
      : this._(isSuccess: false, errorMessage: message);
}

/// ============================================
/// 路由分享 Notifier
///
/// 处理路由分享的UI状态管理，以及待接收分享的轮询
/// ============================================
class RouteShareNotifier extends Notifier<RouteShareState> {
  late final RouteShareService _service = ref.read(routeShareServiceProvider);
  Timer? _pollingTimer;
  bool _isFetching = false;

  static const _pollingIntervalSeconds = 2;
  static const _debounceMs = 500;

  @override
  RouteShareState build() {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    return const RouteShareState();
  }

  Future<bool> shareRoute({
    required String binderUserID,
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
        binderUserID: binderUserID,
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

  /// 分享当前路线（封装校验与 SnackBar 提示逻辑）
  ///
  /// 由 widget 调用，widget 只需根据 [ShareRouteResult] 显示对应 UI
  Future<ShareRouteResult> shareCurrentRoute({
    required PoiSuggestion? binderPoi,
    required PoiSuggestion? originPoi,
    required PoiSuggestion? destinationPoi,
    required RouteType? routeType,
    required int selectedRouteId,
  }) async {
    if (binderPoi == null) {
      return const ShareRouteResult.error('请先选择一个绑定者作为分享目标');
    }
    if (originPoi == null || destinationPoi == null) {
      return const ShareRouteResult.error('请先选择起点和终点');
    }
    if (routeType == null) {
      return const ShareRouteResult.error('请先选择出行方式');
    }

    final success = await shareRoute(
      binderUserID: binderPoi.id,
      origin: originPoi,
      destination: destinationPoi,
      routeType: routeType,
      routeId: selectedRouteId,
    );

    if (success) {
      return const ShareRouteResult.success();
    }
    return ShareRouteResult.error(state.errorMessage ?? '未知错误');
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

  /// 执行一次获取（带防抖）
  Future<void> _fetchOnce() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final newShares = await _service.getPendingShares();
      await Future.delayed(const Duration(milliseconds: _debounceMs));

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
    } finally {
      _isFetching = false;
    }
  }

  /// 将分享数据交给 MapNavigationNotifier 处理（编排逻辑下沉到 nav notifier）
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

    ref.read(mapNavigationProvider.notifier).applySharedRoute(
          origin: origin,
          destination: dest,
          routeType: routeType,
          targetRouteId: share.routeId,
        );
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