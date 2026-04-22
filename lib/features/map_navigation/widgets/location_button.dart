import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// 地图定位按钮
///
/// 使用主题颜色的 FloatingActionButton
/// 点击后将用户所在位置（蓝色箭头）移回屏幕中心
/// 注意：此组件不包含 Positioned，由父组件负责定位

class LocationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool visible;

  const LocationButton({
    super.key,
    required this.onPressed,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return FloatingActionButton(
      heroTag: 'locate',
      mini: true,
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      onPressed: onPressed,
      child: const Icon(Icons.my_location),
    );
  }
}
