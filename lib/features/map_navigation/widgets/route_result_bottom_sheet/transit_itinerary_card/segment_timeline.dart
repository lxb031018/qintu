import 'package:flutter/material.dart';
import '../../../../../../constants/app_colors.dart';

/// 时间线组件（连接线 + 圆点）
class SegmentTimeline extends StatelessWidget {
  final Color color;
  final bool showTopLine;
  final bool showBottomLine;
  final bool isDark;

  const SegmentTimeline({
    super.key,
    required this.color,
    required this.showTopLine,
    required this.showBottomLine,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Column(
        children: [
          if (showTopLine)
            _buildConnector(isDark, topHalf: true)
          else
            const SizedBox(height: 12),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkBackgroundColor : Colors.white,
                width: 2,
              ),
            ),
          ),
          if (showBottomLine)
            _buildConnector(isDark, topHalf: false)
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildConnector(bool isDark, {required bool topHalf}) {
    return Expanded(
      child: Container(
        width: 2,
        color: isDark ? AppColors.darkDividerColor : AppColors.grey300,
      ),
    );
  }
}