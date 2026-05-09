import 'package:qintu/constants/app_spacings.dart';

/// 计算公共交通 sheet 的最大高度
///
/// 公式：maxHeight = screenHeight - statusBarHeight - inputCardHeight - smd*2
///
/// [screenHeight] 屏幕高度
/// [statusBarHeight] 顶部系统栏高度
/// [inputCardHeight] 地点输入卡片高度（包含出行方式按钮）
double calculateTransitSheetMaxHeight({
  required double screenHeight,
  required double statusBarHeight,
  required double inputCardHeight,
  double spacing = AppSpacings.smd * 2,
}) {
  return screenHeight - statusBarHeight - inputCardHeight - spacing;
}

/// 计算收起状态的比例（用于 DraggableScrollableSheet snapSizes 中间点）
///
/// [summaryHeight] 摘要卡片实测高度
/// [maxHeight] sheet 最大高度
double calculateCollapsedRatio({
  required double summaryHeight,
  required double maxHeight,
}) {
  if (maxHeight <= 0) return 0.0;
  return (summaryHeight / maxHeight).clamp(0.0, 1.0);
}