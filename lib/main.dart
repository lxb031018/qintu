import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../config/ui_config.dart';
import 'features/home/sender_main_screen.dart';
import 'features/auth/auth_page.dart';
import 'providers/user_provider.dart';
import 'providers/binding_provider.dart';
import 'services/secure_storage.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 加载环境变量 (.env)
  try {
    await dotenv.load(fileName: ".env");
    Logs.app.info('✅ 环境变量加载成功: ${dotenv.env['CLOUDBASE_ENV_ID']}');
  } catch (e) {
    Logs.app.warning('⚠️ 环境变量加载失败: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BindingProvider()),
        // TODO: 添加其他 Provider
        // ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: '亲途',
        debugShowCheckedModeBanner: false,
        // 浅色主题
        theme: _buildLightTheme(),
        // 深色主题
        darkTheme: _buildDarkTheme(),
        // 跟随系统主题设置
        themeMode: ThemeMode.system,
        home: const AppInitializer(),
      ),
    );
  }

  /// 构建浅色主题
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandGreen,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      cardColor: AppColors.cardBackground,
      dialogBackgroundColor: AppColors.cardBackground,
      dividerColor: AppColors.dividerColor,
      textTheme: _buildLightTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundColor,
        foregroundColor: AppColors.textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: UIConfig.titleFontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
          fontFamily: UIConfig.fontFamily,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConfig.borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.cardBackground,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConfig.borderRadius),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConfig.borderRadius),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConfig.borderRadius),
          borderSide: BorderSide(color: AppColors.focusBorderColor, width: 2),
        ),
        labelStyle: TextStyle(
          color: AppColors.brandGreen,
          fontFamily: UIConfig.fontFamily,
        ),
        hintStyle: TextStyle(
          color: AppColors.lightTextColor,
          fontFamily: UIConfig.fontFamily,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, UIConfig.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConfig.borderRadius),
          ),
          textStyle: TextStyle(
            fontSize: UIConfig.buttonFontSize,
            fontWeight: FontWeight.bold,
            fontFamily: UIConfig.fontFamily,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandGreen,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// 构建深色主题
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandGreen,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      cardColor: AppColors.darkCardBackground,
      dialogBackgroundColor: AppColors.darkCardBackground,
      dividerColor: AppColors.darkDividerColor,
      textTheme: _buildDarkTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackgroundColor,
        foregroundColor: AppColors.darkTextColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: UIConfig.titleFontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextColor,
          fontFamily: UIConfig.fontFamily,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConfig.borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.darkInputBackground,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConfig.borderRadius),
          borderSide: BorderSide(color: AppColors.darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConfig.borderRadius),
          borderSide: BorderSide(color: AppColors.darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConfig.borderRadius),
          borderSide: BorderSide(color: AppColors.focusBorderColor, width: 2),
        ),
        labelStyle: TextStyle(
          color: AppColors.brandGreen,
          fontFamily: UIConfig.fontFamily,
        ),
        hintStyle: TextStyle(
          color: AppColors.darkInputHintColor,
          fontFamily: UIConfig.fontFamily,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, UIConfig.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConfig.borderRadius),
          ),
          textStyle: TextStyle(
            fontSize: UIConfig.buttonFontSize,
            fontWeight: FontWeight.bold,
            fontFamily: UIConfig.fontFamily,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandGreen,
        foregroundColor: AppColors.darkOnPrimaryColor,
      ),
    );
  }

  /// 构建浅色主题文本样式
  TextTheme _buildLightTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
        fontFamily: UIConfig.fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
        fontFamily: UIConfig.fontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: UIConfig.titleFontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
        fontFamily: UIConfig.fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: UIConfig.subtitleFontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
        fontFamily: UIConfig.fontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: UIConfig.subtitleFontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textColor,
        fontFamily: UIConfig.fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: UIConfig.bodyFontSize,
        color: AppColors.textColor,
        fontFamily: UIConfig.fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: UIConfig.bodyFontSize - 2,
        color: AppColors.textColor,
        fontFamily: UIConfig.fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: UIConfig.bodyFontSize - 4,
        color: AppColors.lightTextColor,
        fontFamily: UIConfig.fontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: UIConfig.buttonFontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
        fontFamily: UIConfig.fontFamily,
      ),
    );
  }

  /// 构建深色主题文本样式
  TextTheme _buildDarkTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextColor,
        fontFamily: UIConfig.fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextColor,
        fontFamily: UIConfig.fontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: UIConfig.titleFontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextColor,
        fontFamily: UIConfig.fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: UIConfig.subtitleFontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextColor,
        fontFamily: UIConfig.fontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: UIConfig.subtitleFontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextColor,
        fontFamily: UIConfig.fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: UIConfig.bodyFontSize,
        color: AppColors.darkTextColor,
        fontFamily: UIConfig.fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: UIConfig.bodyFontSize - 2,
        color: AppColors.darkTextColor,
        fontFamily: UIConfig.fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: UIConfig.bodyFontSize - 4,
        color: AppColors.darkLightTextColor,
        fontFamily: UIConfig.fontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: UIConfig.buttonFontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextColor,
        fontFamily: UIConfig.fontFamily,
      ),
    );
  }
}

/// 应用初始化器
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isChecking = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    Logs.app.info('🔍 检查登录状态...');
    
    try {
      // 检查本地是否有保存的 Token
      final isLoggedIn = await SecureStorage.isLoggedIn();
      
      Logs.app.info('🔍 登录状态: ${isLoggedIn ? "已登录" : "未登录"}');

      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isChecking = false;
        });
      }
    } catch (e) {
      Logs.app.warning('🔍 检查登录状态失败: $e');
      if (mounted) {
        setState(() {
          _isChecking = false;
          _isLoggedIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.navigation,
                size: 80,
                color: AppColors.brandGreen,
              ),
              SizedBox(height: 24),
              Text(
                '亲途',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandGreen,
                ),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    // 根据登录状态决定显示登录页还是主页
    if (_isLoggedIn) {
      Logs.app.info('✅ 已登录，进入主页');
      return const SenderMainScreen();
    } else {
      Logs.app.info('🔓 未登录，进入登录页');
      return const AuthPage();
    }
  }
}
