import 'package:flutter/material.dart';
import '../../../../../../../constants/app_colors.dart';

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