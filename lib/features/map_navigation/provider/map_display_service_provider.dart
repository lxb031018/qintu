import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'map_display_service.dart';
import 'map_controller_provider.dart';

final mapDisplayServiceProvider = Provider<MapDisplayService>((ref) {
  return ref.read(mapControllerNotifierProvider.notifier);
});