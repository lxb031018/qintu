import 'package:flutter/services.dart';
import 'package:qintu/core/constants/platform_channels.dart';
import 'package:qintu/utils/logger.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';
import 'package:qintu/features/map_navigation/models/amap_bus_models.dart';

class AmapRouteSearchBridge {
  static const _methodChannel = MethodChannel(PlatformChannels.routeSearch);

  static Future<List<RouteOption>> calculateRoute({
    required RouteType type,
    required LatLng origin,
    required LatLng destination,
    int strategy = 0,
    String? city,
    int maxTrans = 3,
    int alternativeRoute = 1,
    String? time,
    String? timeType,
    String? destCity,
    int? carType,
    double? truckHeight,
    double? truckWeight,
    double? truckWidth,
    double? truckLength,
    int? truckAxis,
  }) async {
    try {
      Logs.navigation.info('🗺️ RouteSearch 算路：$type, ($origin → $destination), strategy=$strategy');

      Map<dynamic, dynamic>? result;

      switch (type) {
        case RouteType.driving:
          result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
            'calculateDriveRoute',
            {
              'fromLat': origin.latitude,
              'fromLng': origin.longitude,
              'toLat': destination.latitude,
              'toLng': destination.longitude,
              'strategy': strategy,
              'alternativeRoute': alternativeRoute,
            },
          );
          if (result != null) {
            return _parseDrivePaths(result, strategy);
          }
          break;

        case RouteType.walking:
          result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
            'calculateWalkRoute',
            {
              'fromLat': origin.latitude,
              'fromLng': origin.longitude,
              'toLat': destination.latitude,
              'toLng': destination.longitude,
            },
          );
          if (result != null) {
            return _parseWalkPaths(result);
          }
          break;

        case RouteType.riding:
          result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
            'calculateRideRoute',
            {
              'fromLat': origin.latitude,
              'fromLng': origin.longitude,
              'toLat': destination.latitude,
              'toLng': destination.longitude,
            },
          );
          if (result != null) {
            return _parseRidePaths(result);
          }
          break;

        case RouteType.eleBike:
          result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
            'calculateRideRoute',
            {
              'fromLat': origin.latitude,
              'fromLng': origin.longitude,
              'toLat': destination.latitude,
              'toLng': destination.longitude,
            },
          );
          if (result != null) {
            return _parseRidePaths(result, isEleBike: true);
          }
          break;

        case RouteType.transit:
          if (city == null || city.isEmpty) {
            throw const RoutingException('公共交通路线需要城市区号');
          }
          result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
            'calculateBusRoute',
            {
              'fromLat': origin.latitude,
              'fromLng': origin.longitude,
              'toLat': destination.latitude,
              'toLng': destination.longitude,
              'city': city,
              'mode': strategy,
              'maxTrans': maxTrans,
              'alternativeRoute': alternativeRoute,
              'time': time,
              'timeType': timeType,
              'destCity': destCity,
            },
          );
          if (result != null) {
            return _parseBusPaths(result, origin, destination, strategy);
          }
          break;
      }

      Logs.navigation.warning('⚠️ RouteSearch 算路返回为空');
      return [];
    } on PlatformException catch (e) {
      Logs.navigation.error('❌ RouteSearch 算路失败：${e.message}');
      throw RoutingException(e.message ?? '算路失败');
    } catch (e) {
      Logs.navigation.error('❌ RouteSearch 算路异常：$e');
      throw RoutingException('算路异常：$e');
    }
  }

  static List<RouteOption> _parseDrivePaths(Map<dynamic, dynamic> result, int strategyId) {
    final paths = result['paths'] as List<dynamic>? ?? [];
    Logs.navigation.info('✅ 驾车算路成功：${paths.length} 条路线');

    return paths.map((p) {
      final map = p as Map<dynamic, dynamic>;
      final polylineList = map['polyline'] as List<dynamic>? ?? [];
      final points = polylineList.map((p) {
        final pm = p as Map<dynamic, dynamic>;
        return LatLng((pm['lat'] as num).toDouble(), (pm['lng'] as num).toDouble());
      }).toList();

      final stepsList = map['steps'] as List<dynamic>? ?? [];

      return RouteOption(
        routeId: (map['routeId'] as num?)?.toInt() ?? -1,
        distance: (map['distance'] as num?)?.toDouble() ?? 0,
        duration: (map['duration'] as num?)?.toDouble() ?? 0,
        strategy: map['strategy']?.toString() ?? '',
        tolls: (map['tolls'] as num?)?.toDouble() ?? 0,
        points: points,
        routeType: RouteType.driving,
        trafficLights: (map['trafficLights'] as num?)?.toInt() ?? 0,
        strategyId: strategyId,
        driveSteps: stepsList.map((s) => _parseDriveStep(s as Map<dynamic, dynamic>)).toList(),
        mainRoadInfo: map['mainRoadInfo']?.toString(),
        restrictionInfo: map['restrictionInfo'] as Map<String, dynamic>?,
      );
    }).toList();
  }

  static DriveStep _parseDriveStep(Map<dynamic, dynamic> map) {
    final polylineList = map['polyline'] as List<dynamic>? ?? [];
    final points = polylineList.map((p) {
      final pm = p as Map<dynamic, dynamic>;
      return LatLng((pm['lat'] as num).toDouble(), (pm['lng'] as num).toDouble());
    }).toList();

    return DriveStep(
      instruction: map['instruction']?.toString() ?? '',
      action: map['action']?.toString() ?? '',
      road: map['road']?.toString() ?? '',
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      duration: (map['duration'] as num?)?.toDouble() ?? 0,
      points: points,
      driveAction: DriveStep.parseAction(map['action']?.toString()),
      tmcStatus: map['tmcStatus']?.toString(),
      lat: (map['lat'] as num?)?.toDouble() ?? 0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0,
      chargeLength: (map['chargeLength'] as num?)?.toDouble() ?? 0,
      tollCost: (map['tollCost'] as num?)?.toDouble() ?? 0,
      trafficLightCount: (map['trafficLightCount'] as num?)?.toInt() ?? 0,
    );
  }

  static List<RouteOption> _parseWalkPaths(Map<dynamic, dynamic> result) {
    final paths = result['paths'] as List<dynamic>? ?? [];
    Logs.navigation.info('✅ 步行算路成功：${paths.length} 条路线');

    return paths.map((p) {
      final map = p as Map<dynamic, dynamic>;
      final polylineList = map['polyline'] as List<dynamic>? ?? [];
      final points = polylineList.map((p) {
        final pm = p as Map<dynamic, dynamic>;
        return LatLng((pm['lat'] as num).toDouble(), (pm['lng'] as num).toDouble());
      }).toList();

      final stepsList = map['steps'] as List<dynamic>? ?? [];

      return RouteOption(
        routeId: (map['routeId'] as num?)?.toInt() ?? -1,
        distance: (map['distance'] as num?)?.toDouble() ?? 0,
        duration: (map['duration'] as num?)?.toDouble() ?? 0,
        strategy: map['strategy']?.toString() ?? '',
        tolls: 0,
        points: points,
        routeType: RouteType.walking,
        walkSteps: stepsList.map((s) => _parseWalkStep(s as Map<dynamic, dynamic>)).toList(),
      );
    }).toList();
  }

  static WalkStep _parseWalkStep(Map<dynamic, dynamic> map) {
    final polylineList = map['polyline'] as List<dynamic>? ?? [];
    final points = polylineList.map((p) {
      final pm = p as Map<dynamic, dynamic>;
      return LatLng((pm['lat'] as num).toDouble(), (pm['lng'] as num).toDouble());
    }).toList();

    return WalkStep(
      instruction: map['instruction']?.toString() ?? '',
      action: map['action']?.toString() ?? '',
      road: map['road']?.toString() ?? '',
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      duration: (map['duration'] as num?)?.toDouble() ?? 0,
      points: points,
      walkAction: WalkStep.parseAction(map['action']?.toString()),
      lat: (map['lat'] as num?)?.toDouble() ?? 0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0,
    );
  }

  static List<RouteOption> _parseRidePaths(Map<dynamic, dynamic> result, {bool isEleBike = false}) {
    final paths = result['paths'] as List<dynamic>? ?? [];
    Logs.navigation.info('✅ 骑行算路成功：${paths.length} 条路线');

    final routeType = isEleBike ? RouteType.eleBike : RouteType.riding;

    return paths.map((p) {
      final map = p as Map<dynamic, dynamic>;
      final polylineList = map['polyline'] as List<dynamic>? ?? [];
      final points = polylineList.map((p) {
        final pm = p as Map<dynamic, dynamic>;
        return LatLng((pm['lat'] as num).toDouble(), (pm['lng'] as num).toDouble());
      }).toList();

      final stepsList = map['steps'] as List<dynamic>? ?? [];

      return RouteOption(
        routeId: (map['routeId'] as num?)?.toInt() ?? -1,
        distance: (map['distance'] as num?)?.toDouble() ?? 0,
        duration: (map['duration'] as num?)?.toDouble() ?? 0,
        strategy: map['strategy']?.toString() ?? '',
        tolls: 0,
        points: points,
        routeType: routeType,
        rideSteps: stepsList.map((s) => _parseWalkStep(s as Map<dynamic, dynamic>)).toList(),
      );
    }).toList();
  }

  static List<RouteOption> _parseBusPaths(
    Map<dynamic, dynamic> result,
    LatLng origin,
    LatLng destination,
    int strategyMode,
  ) {
    final paths = result['paths'] as List<dynamic>? ?? [];
    final taxiCost = (result['taxiCost'] as num?)?.toDouble();
    Logs.navigation.info('✅ 公交算路成功：${paths.length} 条路线');

    return paths.map((p) {
      final map = p as Map<dynamic, dynamic>;
      final polylineList = map['polyline'] as List<dynamic>? ?? [];
      final points = polylineList.map((p) {
        final pm = p as Map<dynamic, dynamic>;
        return LatLng((pm['lat'] as num).toDouble(), (pm['lng'] as num).toDouble());
      }).toList();

      final stepsList = map['steps'] as List<dynamic>? ?? [];

      return RouteOption(
        routeId: (map['routeId'] as num?)?.toInt() ?? -1,
        distance: (map['distance'] as num?)?.toDouble() ?? 0,
        duration: (map['duration'] as num?)?.toDouble() ?? 0,
        strategy: '',
        tolls: (map['cost'] as num?)?.toDouble() ?? 0,
        points: points,
        routeType: RouteType.transit,
        strategyMode: strategyMode,
        walkDistance: (map['walkDistance'] as num?)?.toDouble(),
        busDistance: (map['busDistance'] as num?)?.toDouble(),
        isNightBus: map['isNightBus'] as bool?,
        taxiCost: taxiCost,
        userOrigin: origin,
        userDest: destination,
        transitSegments: _parseTransitSegments(stepsList),
      );
    }).toList();
  }

  static List<TransitSegment> _parseTransitSegments(List<dynamic> steps) {
    final segments = <TransitSegment>[];

    for (final stepData in steps) {
      final step = stepData as Map<dynamic, dynamic>;

      final lines = <TransitLine>[];

      final busLinesRaw = step['busLines'] as List<dynamic>?;
      if (busLinesRaw != null) {
        for (final busLineData in busLinesRaw) {
          final bl = busLineData as Map<dynamic, dynamic>;
          final polyline = bl['polyline'] as List<dynamic>? ?? [];
          if (polyline.isNotEmpty) {
            // polyline available but not stored in TransitLine model
          }

          final passStationsRaw = bl['passStations'] as List<dynamic>?;
          final passStations = passStationsRaw?.map((s) {
            final ps = s as Map<dynamic, dynamic>;
            return BusLineStation(
              name: ps['name']?.toString() ?? '',
              id: ps['id']?.toString() ?? '',
              lat: (ps['lat'] as num?)?.toDouble() ?? 0,
              lng: (ps['lng'] as num?)?.toDouble() ?? 0,
            );
          }).toList() ?? [];

          lines.add(TransitLine(
            name: bl['name']?.toString() ?? '',
            type: TransitLineType.bus,
            stationCount: passStations.length,
            busLineId: bl['busLineId']?.toString(),
            basicPrice: (bl['basicPrice'] as num?)?.toDouble(),
            totalPrice: (bl['totalPrice'] as num?)?.toDouble(),
            firstBusTime: bl['firstBusTime']?.toString(),
            lastBusTime: bl['lastBusTime']?.toString(),
            originatingStation: bl['originatingStation']?.toString(),
            terminalStation: bl['terminalStation']?.toString(),
            busCompany: bl['busCompany']?.toString(),
            passStations: passStations,
          ));
        }
      }

      final railwayData = step['railway'] as Map<dynamic, dynamic>?;
      if (railwayData != null) {
        final stationsRaw = railwayData['stations'] as List<dynamic>? ?? [];
        final railwayStations = stationsRaw.map((s) {
          final rs = s as Map<dynamic, dynamic>;
          return RailwayStationDetail(
            id: rs['id']?.toString() ?? '',
            name: rs['name']?.toString() ?? '',
            lat: (rs['lat'] as num?)?.toDouble() ?? 0,
            lng: (rs['lng'] as num?)?.toDouble() ?? 0,
            time: rs['time']?.toString() ?? '',
            wait: (rs['wait'] as num?)?.toDouble() ?? 0,
            isStart: rs['isStart'] as bool? ?? false,
            isEnd: rs['isEnd'] as bool? ?? false,
          );
        }).toList();

        final spacesRaw = railwayData['spaces'] as List<dynamic>?;
        final spaces = spacesRaw?.map((s) {
          final sp = s as Map<dynamic, dynamic>;
          return RailwaySpace(
            code: sp['code']?.toString() ?? '',
            cost: (sp['cost'] as num?)?.toDouble() ?? 0,
          );
        }).toList() ?? [];

        lines.add(TransitLine(
          name: railwayData['name']?.toString() ?? '',
          type: TransitLineType.subway,
          stationCount: railwayStations.length,
          trip: railwayData['trip']?.toString(),
          railwayType: railwayData['type']?.toString(),
          railwayDistance: (railwayData['distance'] as num?)?.toDouble(),
          railwayStations: railwayStations,
          spaces: spaces,
        ));
      }

      final walkData = step['walk'] as Map<dynamic, dynamic>?;
      int walkDistance = 0;
      List<LatLng> walkPoints = [];
      List<WalkStep>? walkSteps;

      if (walkData != null) {
        walkDistance = (walkData['distance'] as num?)?.toInt() ?? 0;
        final walkPolyline = walkData['polyline'] as List<dynamic>? ?? [];
        walkPoints = walkPolyline.map((p) {
          final pm = p as Map<dynamic, dynamic>;
          return LatLng((pm['lat'] as num).toDouble(), (pm['lng'] as num).toDouble());
        }).toList();

        final stepsRaw = walkData['steps'] as List<dynamic>?;
        if (stepsRaw != null) {
          walkSteps = stepsRaw.map((s) {
            final ws = s as Map<dynamic, dynamic>;
            final wsPolyline = ws['polyline'] as List<dynamic>? ?? [];
            final wsPoints = wsPolyline.map((p) {
              final pm = p as Map<dynamic, dynamic>;
              return LatLng((pm['lat'] as num).toDouble(), (pm['lng'] as num).toDouble());
            }).toList();
            return WalkStep(
              instruction: ws['instruction']?.toString() ?? '',
              action: ws['action']?.toString() ?? '',
              road: ws['road']?.toString() ?? '',
              distance: (ws['distance'] as num?)?.toDouble() ?? 0,
              duration: (ws['duration'] as num?)?.toDouble() ?? 0,
              points: wsPoints,
              walkAction: WalkStep.parseAction(ws['action']?.toString()),
            );
          }).toList();
        }
      }

      final taxiData = step['taxi'] as Map<dynamic, dynamic>?;
      TaxiSegment? taxiSegment;
      if (taxiData != null) {
        final taxiPolyline = taxiData['polyline'] as List<dynamic>? ?? [];
        final taxiPoints = taxiPolyline.map((p) {
          final pm = p as Map<dynamic, dynamic>;
          return LatLng((pm['lat'] as num).toDouble(), (pm['lng'] as num).toDouble());
        }).toList();

        taxiSegment = TaxiSegment(
          origin: _parseCoord(taxiData['origin']),
          destination: _parseCoord(taxiData['destination']),
          distance: (taxiData['distance'] as num?)?.toDouble(),
          duration: (taxiData['duration'] as num?)?.toDouble(),
          price: (taxiData['price'] as num?)?.toDouble(),
          points: taxiPoints,
        );
      }

      StationEntrance? entrance;
      final entranceData = step['entrance'] as Map<dynamic, dynamic>?;
      if (entranceData != null) {
        entrance = StationEntrance(
          name: entranceData['name']?.toString() ?? '',
          lat: (entranceData['lat'] as num?)?.toDouble() ?? 0,
          lng: (entranceData['lng'] as num?)?.toDouble() ?? 0,
        );
      }

      StationEntrance? exit;
      final exitData = step['exit'] as Map<dynamic, dynamic>?;
      if (exitData != null) {
        exit = StationEntrance(
          name: exitData['name']?.toString() ?? '',
          lat: (exitData['lat'] as num?)?.toDouble() ?? 0,
          lng: (exitData['lng'] as num?)?.toDouble() ?? 0,
        );
      }

      segments.add(TransitSegment(
        lines: lines,
        walkingDistance: walkDistance,
        points: walkPoints,
        entrance: entrance,
        exit: exit,
        walkSteps: walkSteps,
        taxi: taxiSegment,
      ));
    }

    return segments;
  }

  static LatLng? _parseCoord(dynamic coord) {
    if (coord == null) return null;
    final m = coord as Map<dynamic, dynamic>;
    final lat = (m['lat'] as num?)?.toDouble();
    final lng = (m['lng'] as num?)?.toDouble();
    if (lat != null && lng != null) return LatLng(lat, lng);
    return null;
  }
}