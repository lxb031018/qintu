import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

      // 系统UI样式
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // 文字主题
      textTheme: AppTextStyles.textTheme,

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

  // ==================== 深色主题 ====================

  static ThemeData get darkTheme {
    return ThemeData(
      // 基础配置
      useMaterial3: false,
      brightness: Brightness.dark,

      // 颜色配置
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      cardColor: AppColors.darkCardBackground,
      canvasColor: AppColors.darkBackgroundColor,

      // 文字主题（深色模式适配）
      textTheme: AppTextStyles.textTheme.copyWith(
        // 标题样式
        displayLarge: AppTextStyles.titleLarge.copyWith(
          color: AppColors.darkTextColor,
        ),
        displayMedium: AppTextStyles.titleMedium.copyWith(
          color: AppColors.darkTextColor,
        ),
        displaySmall: AppTextStyles.titleSmall.copyWith(
          color: AppColors.darkTextColor,
        ),
        headlineLarge: AppTextStyles.titleLarge.copyWith(
          color: AppColors.darkTextColor,
        ),
        headlineMedium: AppTextStyles.titleMedium.copyWith(
          color: AppColors.darkTextColor,
        ),
        headlineSmall: AppTextStyles.titleSmall.copyWith(
          color: AppColors.darkTextColor,
        ),
        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: AppColors.darkTextColor,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: AppColors.darkTextColor,
        ),
        titleSmall: AppTextStyles.titleSmall.copyWith(
          color: AppColors.darkTextColor,
        ),
        // 正文样式
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.darkTextColor,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextColor,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.darkLightTextColor,
        ),
        // 标签样式
        labelLarge: AppTextStyles.button.copyWith(
          color: AppColors.darkOnPrimaryColor,
        ),
        labelMedium: AppTextStyles.buttonSmall.copyWith(
          color: AppColors.darkOnPrimaryColor,
        ),
        labelSmall: AppTextStyles.captionSmall.copyWith(
          color: AppColors.darkLightTextColor,
        ),
      ),

      // 系统UI样式
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurfaceColor,
        foregroundColor: AppColors.darkTextColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle.copyWith(
          color: AppColors.darkTextColor,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.darkOnPrimaryColor,
          disabledBackgroundColor: AppColors.darkDisabledColor,
          disabledForegroundColor: AppColors.darkLightTextColor,
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
          disabledForegroundColor: AppColors.darkDisabledColor,
          textStyle: AppTextStyles.button,
        ),
      ),

      // 图标按钮主题
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.darkIconColor,
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputBackground,
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTextStyles.textFieldRadius),
          borderSide: BorderSide(color: AppColors.errorColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTextStyles.textFieldRadius),
          borderSide: BorderSide(color: AppColors.darkBorderColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        hintStyle: TextStyle(
          color: AppColors.darkInputHintColor,
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTextStyles.cardRadius),
        ),
      ),

      // 分割线主题
      dividerTheme: DividerThemeData(
        color: AppColors.darkDividerColor,
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
        foregroundColor: AppColors.darkOnPrimaryColor,
      ),

      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCardBackground,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: AppColors.darkLightTextColor,
          fontSize: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTextStyles.cardRadius),
        ),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurfaceColor,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.darkIconColor,
        selectedLabelStyle: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          color: AppColors.darkIconColor,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),

      // 复选框主题
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.darkDisabledColor;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryColor;
          }
          return AppColors.darkIconColor;
        }),
        checkColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.darkLightTextColor;
          }
          return AppColors.darkOnPrimaryColor;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(color: AppColors.darkIconColor, width: 2),
      ),

      // 单选按钮主题
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.darkDisabledColor;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryColor;
          }
          return AppColors.darkIconColor;
        }),
      ),

      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.darkDisabledColor;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryColor;
          }
          return AppColors.darkIconColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.darkDisabledColor.withValues(alpha: 0.5);
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryOpacity40;
          }
          return AppColors.darkDividerColor;
        }),
      ),

      // 滑块主题
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryColor,
        inactiveTrackColor: AppColors.primaryOpacity10,
        thumbColor: AppColors.primaryColor,
        overlayColor: AppColors.primaryOpacity10,
        activeTickMarkColor: AppColors.darkOnPrimaryColor,
        inactiveTickMarkColor: AppColors.primaryOpacity10,
      ),

      // 进度条主题
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryColor,
        linearTrackColor: AppColors.darkDividerColor,
      ),

      // 标签栏主题
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.darkIconColor,
        indicatorColor: AppColors.primaryColor,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),

      // 列表瓦片主题
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primaryColor,
        textColor: AppColors.darkTextColor,
      ),

      // 文本选择主题
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryColor,
        selectionColor: AppColors.primaryOpacity30,
        selectionHandleColor: AppColors.primaryColor,
      ),

      // 芯片主题
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkInputBackground,
        deleteIconColor: AppColors.darkIconColor,
        labelStyle: TextStyle(color: AppColors.darkTextColor),
        secondaryLabelStyle: TextStyle(color: AppColors.primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 提示框主题
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceColor,
        contentTextStyle: TextStyle(
          color: AppColors.darkTextColor,
          fontSize: 16,
        ),
        actionTextColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTextStyles.borderRadius),
        ),
      ),
    );
  }
}