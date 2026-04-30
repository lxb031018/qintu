import 'package:qintu/models/location/lat_lng.dart';

/// 公交线路简版信息（内嵌于 BusStationInfo，仅供列表展示）
class BusLineBrief {
  final String id;
  final String name;
  final String type;

  const BusLineBrief({
    required this.id,
    required this.name,
    required this.type,
  });

  factory BusLineBrief.fromMap(Map<dynamic, dynamic> map) {
    return BusLineBrief(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
    );
  }
}

/// 公交站点信息
class BusStationInfo {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String cityCode;
  final String adCode;
  final List<BusLineBrief> busLines;

  const BusStationInfo({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.cityCode,
    required this.adCode,
    required this.busLines,
  });

  factory BusStationInfo.fromMap(Map<dynamic, dynamic> map) {
    final lines = (map['busLines'] as List<dynamic>?)
            ?.map((e) => BusLineBrief.fromMap(e as Map<dynamic, dynamic>))
            .toList() ??
        [];
    return BusStationInfo(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      lat: (map['lat'] as num?)?.toDouble() ?? 0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0,
      cityCode: map['cityCode']?.toString() ?? '',
      adCode: map['adCode']?.toString() ?? '',
      busLines: lines,
    );
  }

  LatLng get latLng => LatLng(lat, lng);
}

/// 公交站点搜索结果
class BusStationResult {
  final List<BusStationInfo> stations;
  final int pageCount;
  final List<String> suggestionKeywords;
  final List<String> suggestionCities;

  const BusStationResult({
    required this.stations,
    required this.pageCount,
    required this.suggestionKeywords,
    required this.suggestionCities,
  });

  factory BusStationResult.fromMap(Map<dynamic, dynamic> map) {
    final stations = (map['stations'] as List<dynamic>?)
            ?.map((e) => BusStationInfo.fromMap(e as Map<dynamic, dynamic>))
            .toList() ??
        [];
    final keywords = (map['suggestionKeywords'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final cities = (map['suggestionCities'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return BusStationResult(
      stations: stations,
      pageCount: (map['pageCount'] as num?)?.toInt() ?? 0,
      suggestionKeywords: keywords,
      suggestionCities: cities,
    );
  }
}

/// 公交线路详细站点信息
class BusLineStation {
  final String id;
  final String name;
  final double lat;
  final double lng;

  const BusLineStation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory BusLineStation.fromMap(Map<dynamic, dynamic> map) {
    return BusLineStation(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      lat: (map['lat'] as num?)?.toDouble() ?? 0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// 公交线路详情（按ID查询的完整版）
class BusLineDetail {
  final String id;
  final String name;
  final String type;
  final String cityCode;
  final String originStation;
  final String terminalStation;
  final double distance;
  final double basicPrice;
  final double totalPrice;
  final String company;
  final String firstBusTime;
  final String lastBusTime;
  final List<BusLineStation> stations;
  final List<LatLng> coordinates;

  const BusLineDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.cityCode,
    required this.originStation,
    required this.terminalStation,
    required this.distance,
    required this.basicPrice,
    required this.totalPrice,
    required this.company,
    required this.firstBusTime,
    required this.lastBusTime,
    required this.stations,
    required this.coordinates,
  });

  factory BusLineDetail.fromMap(Map<dynamic, dynamic> map) {
    final sts = (map['stations'] as List<dynamic>?)
            ?.map((e) => BusLineStation.fromMap(e as Map<dynamic, dynamic>))
            .toList() ??
        [];
    final coords = (map['coordinates'] as List<dynamic>?)
            ?.map((e) {
              final m = e as Map<dynamic, dynamic>;
              return LatLng(
                (m['lat'] as num).toDouble(),
                (m['lng'] as num).toDouble(),
              );
            })
            .toList() ??
        [];
    return BusLineDetail(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      cityCode: map['cityCode']?.toString() ?? '',
      originStation: map['originStation']?.toString() ?? '',
      terminalStation: map['terminalStation']?.toString() ?? '',
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      basicPrice: (map['basicPrice'] as num?)?.toDouble() ?? 0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0,
      company: map['company']?.toString() ?? '',
      firstBusTime: map['firstBusTime']?.toString() ?? '',
      lastBusTime: map['lastBusTime']?.toString() ?? '',
      stations: sts,
      coordinates: coords,
    );
  }
}

/// 公交线路搜索结果
class BusLineResult {
  final List<BusLineDetail> lines;
  final int pageCount;
  final List<String> suggestionKeywords;
  final List<String> suggestionCities;

  const BusLineResult({
    required this.lines,
    required this.pageCount,
    required this.suggestionKeywords,
    required this.suggestionCities,
  });

  factory BusLineResult.fromMap(Map<dynamic, dynamic> map) {
    final lines = (map['lines'] as List<dynamic>?)
            ?.map((e) => BusLineDetail.fromMap(e as Map<dynamic, dynamic>))
            .toList() ??
        [];
    final keywords = (map['suggestionKeywords'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final cities = (map['suggestionCities'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return BusLineResult(
      lines: lines,
      pageCount: (map['pageCount'] as num?)?.toInt() ?? 0,
      suggestionKeywords: keywords,
      suggestionCities: cities,
    );
  }
}
