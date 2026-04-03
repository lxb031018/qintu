import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// ============================================
/// 应用装饰样式
///
/// 统一定义应用中使用的装饰样式
/// ============================================

class AppDecorations {
  // ==================== 卡片装饰 ====================

  /// 普通卡片
  static BoxDecoration card = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryColor.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// 强调卡片
  static BoxDecoration cardHighlighted = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.primaryColor.withOpacity(0.3),
      width: 2,
    ),
  );

  /// 选中卡片
  static BoxDecoration cardSelected(Color color) => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );

  // ==================== 按钮装饰 ====================

  /// 渐变按钮
  static BoxDecoration gradientButton = BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        AppColors.primaryColor,
        AppColors.primaryLight,
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryColor.withOpacity(0.4),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );

  /// 纯色按钮
  static BoxDecoration solidButton(Color color) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      );

  // ==================== 输入框装饰 ====================

  /// 输入框
  static BoxDecoration textField = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryColor.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// 带边框输入框
  static BoxDecoration textFieldWithBorder = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.primaryColor.withOpacity(0.3),
    ),
  );

  // ==================== 容器装饰 ====================

  /// 圆形容器
  static BoxDecoration circle(Color color) => BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      );

  /// 圆角容器
  static BoxDecoration roundedContainer({
    Color color = AppColors.cardBackground,
    double radius = 16,
    Color? borderColor,
  }) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      );

  // ==================== 错误提示装饰 ====================

  /// 错误卡片
  static BoxDecoration errorCard = BoxDecoration(
    color: AppColors.errorColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.errorColor.withOpacity(0.3),
    ),
  );

  // ==================== 成功提示装饰 ====================

  /// 成功卡片
  static BoxDecoration successCard = BoxDecoration(
    color: AppColors.successColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.successColor.withOpacity(0.3),
    ),
  );

  // ==================== 背景装饰 ====================

  /// 渐变背景
  static BoxDecoration gradientBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.backgroundColor,
        AppColors.primaryColor.withOpacity(0.1),
      ],
    ),
  );

  // ==================== 阴影 ====================

  /// 轻微阴影
  static List<BoxShadow> shadowLight = [
    BoxShadow(
      color: AppColors.primaryColor.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  /// 普通阴影
  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: AppColors.primaryColor.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  /// 强阴影
  static List<BoxShadow> shadowStrong = [
    BoxShadow(
      color: AppColors.primaryColor.withOpacity(0.2),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];

  /// 彩色阴影
  static List<BoxShadow> shadowColored(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
}