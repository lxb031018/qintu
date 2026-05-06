import 'package:flutter/material.dart';
import '../../../../../../constants/app_colors.dart';

/// 带图标的信息小标签
class InfoTag extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isDark;

  const InfoTag({
    super.key,
    required this.text,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: AppColors.grey400),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.darkLightTextColor : AppColors.grey500,
          ),
        ),
      ],
    );
  }
}