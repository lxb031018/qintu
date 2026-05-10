import 'package:flutter/material.dart';
import '../../../../../../../constants/app_colors.dart';

/// ============================================
/// 箭头分隔符组件
///
/// 用于在行程段标签之间显示箭头分隔
/// ============================================
class ArrowSeparator extends StatelessWidget {
  const ArrowSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.arrow_forward,
      size: 12,
      color: AppColors.grey400,
    );
  }
}