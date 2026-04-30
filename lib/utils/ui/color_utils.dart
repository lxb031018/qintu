/// 按系数降低颜色透明度。
///
/// [color] 是 32 位 ARGB 整数 (0xAARRGGBB)。
/// [factor] 取值 0.0（完全透明）到 1.0（完全不透明）。
int dimColor(int color, double factor) {
  final a = ((color >> 24) & 0xFF) * factor;
  final r = (color >> 16) & 0xFF;
  final g = (color >> 8) & 0xFF;
  final b = color & 0xFF;
  return (a.toInt() << 24) | (r << 16) | (g << 8) | b;
}
