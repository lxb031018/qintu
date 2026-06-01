import 'package:flutter_test/flutter_test.dart';
import 'package:qintu/features/map_navigation/models/poi_models.dart';
import 'package:qintu/features/map_navigation/models/route_option_model.dart';
import 'package:qintu/features/map_navigation/models/map_overlay_models.dart';
import 'package:qintu/features/map_navigation/provider/location_input/location_input_state.dart';
import 'package:qintu/features/map_navigation/utils/location_distance_service.dart';

void main() {
  group('RouteTypeCodec', () {
    test('toApiString 双向对称', () {
      for (final type in RouteType.values) {
        final s = RouteTypeCodec.toApiString(type);
        expect(RouteTypeCodec.parseFromApiString(s), type);
      }
    });

    test('parseFromApiString 未知值回退到默认', () {
      expect(RouteTypeCodec.parseFromApiString('spaceship'),
          RouteType.driving);
      expect(RouteTypeCodec.parseFromApiString(null), RouteType.driving);
      expect(
        RouteTypeCodec.parseFromApiString('walking', fallback: RouteType.riding),
        RouteType.walking,
      );
    });

    test('labelFor 与 labelFromApiString 一致', () {
      for (final type in RouteType.values) {
        final s = RouteTypeCodec.toApiString(type);
        expect(RouteTypeCodec.labelFromApiString(s), RouteTypeCodec.labelFor(type));
      }
    });

    test('iconFor 返回非 null 图标', () {
      for (final type in RouteType.values) {
        expect(RouteTypeCodec.iconFor(type), isNotNull);
      }
    });
  });

  group('RouteResultItem.fromRoute', () {
    RouteOption makeRoute({
      required int routeId,
      required double distance,
      required double duration,
    }) {
      return RouteOption(
        routeId: routeId,
        distance: distance,
        duration: duration,
        strategy: '速度最快',
        tolls: 0,
        points: const [],
        routeType: RouteType.driving,
        cityCodes: const ['010'],
      );
    }

    test('无 selectedFor 时不计算差异', () {
      final item = RouteResultItem.fromRoute(makeRoute(
        routeId: 1,
        distance: 5000,
        duration: 600,
      ));
      expect(item.timeDiff, isNull);
      expect(item.distanceDiff, isNull);
      expect(item.distance, 5000);
      expect(item.duration, 600);
    });

    test('时间差 < 60 秒不写入 timeDiff', () {
      final base = makeRoute(routeId: 1, distance: 5000, duration: 600);
      final other = makeRoute(routeId: 2, distance: 5000, duration: 630);
      final item = RouteResultItem.fromRoute(other, selectedFor: base);
      expect(item.timeDiff, isNull); // 30s 不到阈值
    });

    test('时间差 ≥ 60 秒写入 timeDiff（正负）', () {
      final base = makeRoute(routeId: 1, distance: 5000, duration: 600);
      final faster = makeRoute(routeId: 2, distance: 5000, duration: 480);
      final slower = makeRoute(routeId: 3, distance: 5000, duration: 720);

      expect(RouteResultItem.fromRoute(faster, selectedFor: base).timeDiff, -120);
      expect(RouteResultItem.fromRoute(slower, selectedFor: base).timeDiff, 120);
    });

    test('距离差 < 100 米不写入 distanceDiff', () {
      final base = makeRoute(routeId: 1, distance: 5000, duration: 600);
      final close = makeRoute(routeId: 2, distance: 5050, duration: 600);
      final item = RouteResultItem.fromRoute(close, selectedFor: base);
      expect(item.distanceDiff, isNull);
    });

    test('cityCode 优先取列表首项', () {
      final r = makeRoute(routeId: 1, distance: 1000, duration: 60);
      final item = RouteResultItem.fromRoute(r);
      expect(item.cityCode, '010');
    });
  });

  group('PoiSuggestion.fromMap', () {
    test('缺失字段回退到空值', () {
      final p = PoiSuggestion.fromMap(const {});
      expect(p.id, '');
      expect(p.name, '');
      expect(p.location, '');
      expect(p.distance, isNull);
    });

    test('distance 可解析字符串', () {
      final p = PoiSuggestion.fromMap({'distance': '123'});
      expect(p.distance, 123);
    });

    test('latLng 解析 "lng,lat" 格式', () {
      final p = PoiSuggestion.fromMap({
        'id': 'a',
        'name': '北京站',
        'location': '116.43,39.90',
      });
      expect(p.latLng, isNotNull);
      expect(p.latLng!.latitude, closeTo(39.90, 0.001));
      expect(p.latLng!.longitude, closeTo(116.43, 0.001));
    });

    test('latLng 处理空字符串与 "[]"', () {
      final empty = PoiSuggestion.fromMap({'location': ''});
      final bracket = PoiSuggestion.fromMap({'location': '[]'});
      expect(empty.latLng, isNull);
      expect(bracket.latLng, isNull);
    });

    test('latLng 处理格式错误', () {
      final bad = PoiSuggestion.fromMap({'location': 'single_value'});
      expect(bad.latLng, isNull);
    });

    test('fromTip 转换经纬度', () {
      final p = PoiSuggestion.fromTip({
        'poiId': 'tip-1',
        'name': '天安门',
        'district': '东城区',
        'address': '北京市东城区',
        'latitude': 39.91,
        'longitude': 116.40,
      });
      expect(p.id, 'tip-1');
      expect(p.latLng, isNotNull);
      expect(p.latLng!.latitude, closeTo(39.91, 0.001));
    });
  });

  group('DistanceThrottle', () {
    test('首次调用始终允许', () {
      final t = DistanceThrottle();
      expect(t.shouldAllow(39.9, 116.4), isTrue);
    });

    test('距离 < 阈值被拒', () {
      final t = DistanceThrottle(minDistanceMeters: 10);
      t.shouldAllow(0, 0); // 首次
      expect(t.shouldAllow(0.0001, 0), isFalse); // ~11 米
    });

    test('距离 ≥ 阈值且时间 ≥ 间隔被允许', () {
      final t = DistanceThrottle(
        minDistanceMeters: 5,
        minInterval: Duration.zero,
      );
      t.shouldAllow(0, 0);
      expect(t.shouldAllow(0.001, 0), isTrue);
    });

    test('reset 后视为首次', () {
      final t = DistanceThrottle(minDistanceMeters: 100);
      t.shouldAllow(0, 0);
      expect(t.shouldAllow(0.0001, 0), isFalse);
      t.reset();
      expect(t.hasRecorded, isFalse);
      expect(t.shouldAllow(0, 0), isTrue);
    });

    test('hasRecorded 在首次前为 false', () {
      final t = DistanceThrottle();
      expect(t.hasRecorded, isFalse);
      t.shouldAllow(0, 0);
      expect(t.hasRecorded, isTrue);
    });
  });

  group('LocationInputState 基础', () {
    test('inputCardHeight 默认为 0', () {
      const s = LocationInputState();
      expect(s.inputCardHeight, 0);
    });

    test('copyWith 保留未指定字段', () {
      const s = LocationInputState(inputCardHeight: 100);
      final next = s.copyWith(list: const LocationListState(listVisible: true));
      expect(next.inputCardHeight, 100);
      expect(next.listVisible, isTrue);
    });
  });
}
