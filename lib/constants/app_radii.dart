// ============================================
// 应用圆角常量
//
// 统一定义应用中使用的圆角值
// 便于维护和保持 UI 一致性
// ============================================

import 'package:flutter/material.dart';

class AppRadii {
  // ==================== 圆角值 ====================

  /// 极小圆角（4px，用于小标签）
  static const Radius xsmall = Radius.circular(4);

  /// 小圆角（8px，用于小按钮、标签）
  static const Radius small = Radius.circular(8);

  /// 中等圆角（12px，用于卡片、输入框）
  static const Radius medium = Radius.circular(12);

  /// 大圆角（16px，用于对话框、大卡片）
  static const Radius large = Radius.circular(16);

  /// 超大圆角（20px，用于特殊卡片）
  static const Radius xlarge = Radius.circular(20);

  /// 极大圆角（24px，用于首页特殊组件）
  static const Radius xxlarge = Radius.circular(24);

  // ==================== 快捷方式 ====================

  /// 极小圆角矩形
  static RoundedRectangleBorder get xsmallRect => RoundedRectangleBorder(
        borderRadius: BorderRadius.all(xsmall),
      );

  /// 小圆角矩形
  static RoundedRectangleBorder get smallRect => RoundedRectangleBorder(
        borderRadius: BorderRadius.all(small),
      );

  /// 中等圆角矩形
  static RoundedRectangleBorder get mediumRect => RoundedRectangleBorder(
        borderRadius: BorderRadius.all(medium),
      );

  /// 大圆角矩形
  static RoundedRectangleBorder get largeRect => RoundedRectangleBorder(
        borderRadius: BorderRadius.all(large),
      );

  /// 超大圆角矩形
  static RoundedRectangleBorder get xlargeRect => RoundedRectangleBorder(
        borderRadius: BorderRadius.all(xlarge),
      );

  /// 极大圆角矩形
  static RoundedRectangleBorder get xxlargeRect => RoundedRectangleBorder(
        borderRadius: BorderRadius.all(xxlarge),
      );
}
