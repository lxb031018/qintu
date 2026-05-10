import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'map_navigation_provider.dart';

final mapNavigationServiceProvider = Provider<MapNavigationService>((ref) {
  return ref.read(mapNavigationProvider.notifier);
});