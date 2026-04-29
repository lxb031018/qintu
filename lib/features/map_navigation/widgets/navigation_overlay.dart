import 'package:flutter/material.dart';
import '../../../constants/app_spacings.dart';

/// 无 View 导航覆盖层
///
/// 在路径规划地图上显示实时导航信息
class NavigationOverlay extends StatelessWidget {
  final double speed;
  final int remainingDistance;
  final int remainingTime;
  final String currentRoad;
  final VoidCallback? onExit;

  const NavigationOverlay({
    super.key,
    this.speed = 0,
    this.remainingDistance = 0,
    this.remainingTime = 0,
    this.currentRoad = '',
    this.onExit,
  });

  String get _distanceText {
    if (remainingDistance >= 1000) {
      return '${(remainingDistance / 1000).toStringAsFixed(1)}公里';
    }
    return '${remainingDistance}米';
  }

  String get _timeText {
    final min = remainingTime ~/ 60;
    final hour = min ~/ 60;
    final minPart = min % 60;
    if (hour > 0) {
      return '$hour小时$minPart分';
    }
    return '$minPart分钟';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 顶部道路名称
        Positioned(
          top: 52,
          left: AppSpacings.lg,
          right: AppSpacings.lg,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentRoad.isNotEmpty ? currentRoad : '正在导航',
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        // 右下角速度 + 距离 + 时间
        Positioned(
          bottom: 32,
          right: AppSpacings.md,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 剩余距离和时间
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _distanceText,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _timeText,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 速度
              if (speed > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1890FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${speed.toInt()}',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        ' km/h',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // 退出按钮（右上角）
        Positioned(
          top: 52,
          right: AppSpacings.md,
          child: GestureDetector(
            onTap: onExit,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}
