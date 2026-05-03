import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../config/ui_config.dart';
import 'app_text_styles.dart';

/// 应用主题配置
///
/// 统一管理浅色和深色主题的配置
class AppTheme {
  /// 构建浅色主题
  static ThemeData buildLightTheme() {
    return _buildTheme(
      scaffoldColor: AppColors.backgroundColor,
      cardColor: AppColors.cardBackground,
      dialogColor: AppColors.cardBackground,
      dividerColor: AppColors.dividerColor,
      textColor: AppColors.textColor,
      lightTextColor: AppColors.lightTextColor,
      inputFillColor: AppColors.cardBackground,
      borderColor: AppColors.borderColor,
      focusedBorderColor: AppColors.focusBorderColor,
      fabColor: Colors.white,
    );
  }

  /// 构建深色主题
  static ThemeData buildDarkTheme() {
    return _buildTheme(
      scaffoldColor: AppColors.darkBackgroundColor,
      cardColor: AppColors.darkCardBackground,
      dialogColor: AppColors.darkCardBackground,
      dividerColor: AppColors.darkDividerColor,
      textColor: AppColors.darkTextColor,
      lightTextColor: AppColors.darkLightTextColor,
      inputFillColor: AppColors.darkInputBackground,
      borderColor: AppColors.darkBorderColor,
      focusedBorderColor: AppColors.focusBorderColor,
      fabColor: AppColors.darkOnPrimaryColor,
    );
  }

  static ThemeData _buildTheme({
    required Color scaffoldColor,
    required Color cardColor,
    required Color dialogColor,
    required Color dividerColor,
    required Color textColor,
    required Color lightTextColor,
    required Color inputFillColor,
    required Color borderColor,
    required Color focusedBorderColor,
    required Color fabColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        brightness: scaffoldColor == AppColors.backgroundColor ? Brightness.light : Brightness.dark,
      ),
      scaffoldBackgroundColor: scaffoldColor,
      cardColor: cardColor,
      dialogTheme: DialogThemeData(backgroundColor: dialogColor),
      dividerColor: dividerColor,
      textTheme: AppTextStyles.textTheme,
      appBarTheme: _buildAppBarTheme(scaffoldColor, textColor),
      cardTheme: _buildCardTheme(cardColor),
      inputDecorationTheme: _buildInputDecoration(inputFillColor, borderColor, focusedBorderColor, lightTextColor),
      elevatedButtonTheme: _buildButtonTheme(),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: fabColor,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(Color backgroundColor, Color textColor) {
    return AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.appBarTitle,
    );
  }

  static CardThemeData _buildCardTheme(Color cardColor) {
    return CardThemeData(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConfig.borderRadius),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecoration(
    Color fillColor,
    Color borderColor,
    Color focusedBorderColor,
    Color hintColor,
  ) {
    return InputDecorationTheme(
      fillColor: fillColor,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(UIConfig.borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(UIConfig.borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(UIConfig.borderRadius),
        borderSide: BorderSide(color: focusedBorderColor, width: 2),
      ),
      labelStyle: TextStyle(color: AppColors.primaryColor, fontFamily: UIConfig.fontFamily),
      hintStyle: TextStyle(color: hintColor, fontFamily: UIConfig.fontFamily),
    );
  }

  static ElevatedButtonThemeData _buildButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, UIConfig.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConfig.borderRadius),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  // ==================== 保留旧方法以兼容过渡（后续可删除）====================

  /// 浅色主题（已废弃，使用 buildLightTheme 代替）
  @Deprecated('Use buildLightTheme() instead')
  static ThemeData get lightTheme => buildLightTheme();

  /// 深色主题（已废弃，使用 buildDarkTheme 代替）
  @Deprecated('Use buildDarkTheme() instead')
  static ThemeData get darkTheme => buildDarkTheme();
}

