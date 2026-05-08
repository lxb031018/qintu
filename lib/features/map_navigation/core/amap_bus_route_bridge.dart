import 'package:flutter/services.dart';
import 'package:qintu/core/constants/platform_channels.dart';
import 'package:qintu/features/map_navigation/models/bus_route_models.dart';
import 'package:qintu/models/location/lat_lng.dart';
import 'package:qintu/utils/logger.dart';

class AmapBusRouteBridge {
  static const _channelName = PlatformChannels.routeSearch;

  static const _channel = MethodChannel(_channelName);

  Future<List<BusPath>> calculateBusRoute({
    required LatLng from,
    required LatLng to,
    required String city,
    int mode = BusModeValues.defaultMode,
    int nightFlag = 0,
  }) async {
    try {
      final result = await _channel.invokeMethod('calculateBusRoute', {
        'fromLat': from.latitude,
        'fromLng': from.longitude,
        'toLat': to.latitude,
        'toLng': to.longitude,
        'city': city,
        'mode': mode,
        'nightFlag': nightFlag,
      });

      if (result == null) return [];

      final routes = result as List<dynamic>;
      return routes.map((r) => BusPath.fromMap(r as Map<String, dynamic>)).toList();
    } on PlatformException catch (e) {
      Logs.ui.warning('Bus route search failed: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      Logs.ui.warning('Bus route search unexpected error: $e');
      rethrow;
    }
  }
}
