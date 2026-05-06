import 'package:flutter/material.dart';

/// 公交线路标签颜色
const Color _subwayTagColor = Color(0xFFFF4D4F);
const Color _busTagColor = Color(0xFF1890FF);

/// 获取公交线路标签颜色
///
/// 地铁/轨交线路返回红色，其他返回蓝色
Color getTransitLineColor(String name) {
  if (name.contains('号线') || name.contains('地铁') || name.contains('轨')) {
    return _subwayTagColor;
  }
  return _busTagColor;
}

/// 公交/地铁线路标签
///
/// 显示地铁或公交线路名称的彩色小标签
class TransitLineTag extends StatelessWidget {
  final String name;

  const TransitLineTag({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: getTransitLineColor(name),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        name,
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
  }
}
