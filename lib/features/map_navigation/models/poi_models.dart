import 'package:qintu/models/location/lat_lng.dart';

class PoiSearchResult {
  final List<PoiSuggestion> suggestions;
  final int errorCode;
  final String? errorMessage;

  const PoiSearchResult({
    this.suggestions = const [],
    this.errorCode = 0,
    this.errorMessage,
  });

  bool get isSuccess => errorCode == 0 && suggestions.isNotEmpty;
}

class PoiSuggestion {
  final String id;
  final String name;
  final String district;
  final String address;
  final String location;
  int? distance;
  final String? entrLocation;

  PoiSuggestion({
    required this.id,
    required this.name,
    required this.district,
    required this.address,
    required this.location,
    this.distance,
    this.entrLocation,
  });

  LatLng? get latLng {
    if (location.isEmpty || location == '[]') return null;
    final parts = location.split(',');
    if (parts.length != 2) return null;
    return LatLng.fromAmapString(location);
  }

  LatLng? get distanceLatLng {
    final locStr = entrLocation ?? location;
    if (locStr.isEmpty || locStr == '[]') return null;
    return LatLng.fromAmapString(locStr);
  }

  factory PoiSuggestion.fromMap(Map<String, dynamic> map) {
    return PoiSuggestion(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      district: map['district']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      distance: int.tryParse(map['distance']?.toString() ?? ''),
      entrLocation: map['entr_location']?.toString(),
    );
  }
}