import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_text_styles.dart';

/// ============================================
/// 应用主题配置
///
/// 统一管理应用的主题样式
/// ============================================

class AppTheme {
  // ==================== 浅色主题 ====================

  static ThemeData get lightTheme {
    return ThemeData(
      // 基础配置
      useMaterial3: false,
      brightness: Brightness.light,

      // 颜色配置
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      cardColor: AppColors.cardBackground,

      // 文字主题
      textTheme: AppTextStyles.textTheme,

      // AppBar 主题
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle,
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTextStyles.buttonRadius),
          ),
          minimumSize: const Size(double.infinity, 60),
        ),
      ),

      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: AppTextStyles.button,
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTextStyles.textFieldRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTextStyles.textFieldRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTextStyles.textFieldRadius),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTextStyles.textFieldRadius),
          borderSide: BorderSide(color: AppColors.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTextStyles.cardRadius),
        ),
      ),

      // 分割线主题
      dividerTheme: DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
      ),

      // 图标主题
      iconTheme: IconThemeData(
        color: AppColors.primaryColor,
        size: AppTextStyles.iconSize,
      ),

      // 浮动操作按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteText,
      ),

      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTextStyles.cardRadius),
        ),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.lightTextColor,
      ),
    );
  }

  // ==================== 深色主题（预留）====================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      // TODO: 添加深色主题配置
    );
  }
}