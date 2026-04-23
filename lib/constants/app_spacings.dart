// 统一间距常量
//
// 用于项目中所有 padding、margin、gap 等间距相关场景
// 确保视觉一致性，避免硬编码魔法数字

class AppSpacings {
  AppSpacings._();

  /// 超小间距：4px
  /// 使用场景：图标与文字间距、紧密排列的元素
  static const double xs = 4.0;

  /// 小间距：6px
  /// 使用场景：图标与文字间距（中等紧密）
  static const double xsm = 6.0;

  /// 小间距：8px
  /// 使用场景：卡片内边距、元素间距、Positioned 偏移
  static const double sm = 8.0;

  /// 中小间距：10px
  /// 使用场景：按钮内边距、列表项内间距
  static const double smd = 10.0;

  /// 中等间距：12px
  /// 使用场景：输入框内边距、列表项间距
  static const double md = 12.0;

  /// 标准间距：16px
  /// 使用场景：页面边距、卡片外边距、主要内容间距
  static const double lg = 16.0;

  /// 大间距：24px
  /// 使用场景：区块间距、标题与内容间距
  static const double xl = 24.0;

  /// 超大间距：32px
  /// 使用场景：页面主要区块间距
  static const double xxl = 32.0;

  /// 特大间距：48px
  /// 使用场景：页面顶部留白、大区块分隔
  static const double xxxl = 48.0;
}
