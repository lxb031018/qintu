import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../config/ui_config.dart';

/// 应用主题配置
///
/// 统一管理浅色和深色主题的配置
class AppTheme {
  /// 浅色主题
  static ThemeData get lightTheme => _buildLightTheme();

  /// 深色主题
  static ThemeData get darkTheme => _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandGreen,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      cardColor: AppColors.cardBackground,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
      ),
      dividerColor: AppColors.dividerColor,
      textTheme: _lightTextTheme,
      appBarTheme: _lightAppBarTheme,
      cardTheme: _lightCardTheme,
      inputDecorationTheme: _lightInputDecoration,
      elevatedButtonTheme: _lightButtonTheme,
      floatingActionButtonTheme: _lightFabTheme,
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandGreen,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      cardColor: AppColors.darkCardBackground,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCardBackground,
      ),
      dividerColor: AppColors.darkDividerColor,
      textTheme: _darkTextTheme,
      appBarTheme: _darkAppBarTheme,
      cardTheme: _darkCardTheme,
      inputDecorationTheme: _darkInputDecoration,
      elevatedButtonTheme: _darkButtonTheme,
      floatingActionButtonTheme: _darkFabTheme,
    );
  }

  static final _lightTextTheme = TextTheme(
    displayLarge: _createTextStyle(57, AppColors.textColor),
    displayMedium: _createTextStyle(45, AppColors.textColor),
    headlineLarge: _createTextStyle(UIConfig.titleFontSize, AppColors.textColor, FontWeight.bold),
    headlineMedium: _createTextStyle(UIConfig.subtitleFontSize, AppColors.textColor, FontWeight.bold),
    titleLarge: _createTextStyle(UIConfig.subtitleFontSize, AppColors.textColor, FontWeight.w600),
    bodyLarge: _createTextStyle(UIConfig.bodyFontSize, AppColors.textColor),
    bodyMedium: _createTextStyle(UIConfig.bodyFontSize - 2, AppColors.textColor),
    bodySmall: _createTextStyle(UIConfig.bodyFontSize - 4, AppColors.lightTextColor),
    labelLarge: _createTextStyle(UIConfig.buttonFontSize, AppColors.textColor, FontWeight.bold),
  );

  static final _darkTextTheme = TextTheme(
    displayLarge: _createTextStyle(57, AppColors.darkTextColor),
    displayMedium: _createTextStyle(45, AppColors.darkTextColor),
    headlineLarge: _createTextStyle(UIConfig.titleFontSize, AppColors.darkTextColor, FontWeight.bold),
    headlineMedium: _createTextStyle(UIConfig.subtitleFontSize, AppColors.darkTextColor, FontWeight.bold),
    titleLarge: _createTextStyle(UIConfig.subtitleFontSize, AppColors.darkTextColor, FontWeight.w600),
    bodyLarge: _createTextStyle(UIConfig.bodyFontSize, AppColors.darkTextColor),
    bodyMedium: _createTextStyle(UIConfig.bodyFontSize - 2, AppColors.darkTextColor),
    bodySmall: _createTextStyle(UIConfig.bodyFontSize - 4, AppColors.darkLightTextColor),
    labelLarge: _createTextStyle(UIConfig.buttonFontSize, AppColors.darkTextColor, FontWeight.bold),
  );

  static TextStyle _createTextStyle(double fontSize, Color color, [FontWeight fontWeight = FontWeight.normal]) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: UIConfig.fontFamily,
    );
  }

  static final _lightAppBarTheme = AppBarTheme(
    backgroundColor: AppColors.backgroundColor,
    foregroundColor: AppColors.textColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: _createTextStyle(UIConfig.titleFontSize, AppColors.textColor, FontWeight.bold),
  );

  static final _darkAppBarTheme = AppBarTheme(
    backgroundColor: AppColors.darkBackgroundColor,
    foregroundColor: AppColors.darkTextColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: _createTextStyle(UIConfig.titleFontSize, AppColors.darkTextColor, FontWeight.bold),
  );

  static final _lightCardTheme = CardThemeData(
    color: AppColors.cardBackground,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UIConfig.borderRadius),
    ),
  );

  static final _darkCardTheme = CardThemeData(
    color: AppColors.darkCardBackground,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UIConfig.borderRadius),
    ),
  );

  static final _lightInputDecoration = InputDecorationTheme(
    fillColor: AppColors.cardBackground,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UIConfig.borderRadius),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UIConfig.borderRadius),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UIConfig.borderRadius),
      borderSide: BorderSide(color: AppColors.focusBorderColor, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.brandGreen, fontFamily: UIConfig.fontFamily),
    hintStyle: const TextStyle(color: AppColors.lightTextColor, fontFamily: UIConfig.fontFamily),
  );

  static final _darkInputDecoration = InputDecorationTheme(
    fillColor: AppColors.darkInputBackground,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UIConfig.borderRadius),
      borderSide: const BorderSide(color: AppColors.darkBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UIConfig.borderRadius),
      borderSide: const BorderSide(color: AppColors.darkBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UIConfig.borderRadius),
      borderSide: BorderSide(color: AppColors.focusBorderColor, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.brandGreen, fontFamily: UIConfig.fontFamily),
    hintStyle: const TextStyle(color: AppColors.darkInputHintColor, fontFamily: UIConfig.fontFamily),
  );

  static final _lightButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.brandGreen,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, UIConfig.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConfig.borderRadius),
      ),
      textStyle: _createTextStyle(UIConfig.buttonFontSize, Colors.white, FontWeight.bold),
    ),
  );

  static final _darkButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.brandGreen,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, UIConfig.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConfig.borderRadius),
      ),
      textStyle: _createTextStyle(UIConfig.buttonFontSize, Colors.white, FontWeight.bold),
    ),
  );

  static const _lightFabTheme = FloatingActionButtonThemeData(
    backgroundColor: AppColors.brandGreen,
    foregroundColor: Colors.white,
  );

  static const _darkFabTheme = FloatingActionButtonThemeData(
    backgroundColor: AppColors.brandGreen,
    foregroundColor: AppColors.darkOnPrimaryColor,
  );
}
