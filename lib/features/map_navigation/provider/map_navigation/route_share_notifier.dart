import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/poi_models.dart';
import '../../models/route_option_model.dart';
import '../../service/route_share_service.dart';

/// ============================================
/// 路由分享状态
/// ============================================
class RouteShareState {
  final bool isSharing;
  final String? errorMessage;

  const RouteShareState({
    this.isSharing = false,
    this.errorMessage,
  });

  RouteShareState copyWith({
    bool? isSharing,
    String? errorMessage,
  }) {
    return RouteShareState(
      isSharing: isSharing ?? this.isSharing,
      errorMessage: errorMessage,
    );
  }
}

/// ============================================
/// 路由分享 Notifier
///
/// 处理路由分享的UI状态管理
/// ============================================
class RouteShareNotifier extends Notifier<RouteShareState> {
  late final RouteShareService _service = ref.read(routeShareServiceProvider);

  @override
  RouteShareState build() {
    return const RouteShareState();
  }

  Future<bool> shareRoute({
    required String binderOpenid,
    required PoiSuggestion origin,
    required PoiSuggestion destination,
    required RouteType routeType,
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
}

final routeShareNotifierProvider =
    NotifierProvider<RouteShareNotifier, RouteShareState>(
  RouteShareNotifier.new,
);