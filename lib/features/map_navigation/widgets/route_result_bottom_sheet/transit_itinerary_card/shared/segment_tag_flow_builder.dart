import 'package:flutter/material.dart';
import '../../../../../../features/map_navigation/models/bus_route_models.dart';
import 'walk_tag.dart';
import 'transit_tag.dart';
import 'taxi_tag.dart';
import 'arrow_separator.dart';

class SegmentTagFlowBuilder {
  final List<BusTransitSegment> segments;
  final bool isDark;

  const SegmentTagFlowBuilder({
    required this.segments,
    required this.isDark,
  });

  List<Widget> build() {
    final tags = <Widget>[];

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];

      if (seg.hasWalking) {
        tags.add(WalkTag(distance: seg.distance, isDark: isDark));
        if (i < segments.length - 1) {
          tags.add(const ArrowSeparator());
        }
      }

      if (seg.hasTransit) {
        tags.add(TransitTag(
          name: seg.lineName ?? '',
          stationCount: seg.stationCount ?? 0,
          type: seg.type,
          cityCode: seg.cityCode,
        ));
        if (i < segments.length - 1) {
          tags.add(const ArrowSeparator());
        }
      }

      if (seg.hasTaxi) {
        tags.add(TaxiTag(isDark: isDark));
        if (i < segments.length - 1) {
          tags.add(const ArrowSeparator());
        }
      }
    }

    return tags;
  }
}