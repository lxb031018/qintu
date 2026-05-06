import 'package:flutter/material.dart';
import 'package:qintu/constants/app_colors.dart';
import 'package:qintu/constants/app_spacings.dart';
import 'package:qintu/features/map_navigation/models/amap_routing_models.dart';

/// 进站口/出站口信息
class EntranceExitInfo extends StatelessWidget {
  final StationEntrance? entrance;
  final StationEntrance? exit;
  final bool isDark;

  const EntranceExitInfo({
    super.key,
    this.entrance,
    this.exit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (entrance != null && entrance!.name.isNotEmpty) {
      parts.add('进站口: ${entrance!.name}');
    }
    if (exit != null && exit!.name.isNotEmpty) {
      parts.add('出站口: ${exit!.name}');
    }
    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacings.xs),
      child: Wrap(
        spacing: AppSpacings.md,
        children: parts.map((p) => Text(
          p,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
          ),
        )).toList(),
      ),
    );
  }
}