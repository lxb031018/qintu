import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'constants/app_colors.dart';
import 'config/app_config.dart';
import 'constants/app_strings.dart';
import 'pages/auth_page.dart';
import 'pages/role_selection_page.dart';
import 'pages/receiver_home_page.dart';
import 'pages/sender_home_page.dart';
import 'services/secure_storage.dart';
import 'theme/app_theme.dart';

/// 亲途应用入口

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundColor,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  // .env 文件可选加载，如不存在则使用默认值
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // .env 文件不存在时使用默认配置
    // 提示用户：请复制 .env.example 为 .env 并填入配置
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}

/// ============================================
/// 启动页面 - 检查登录状态
/// ============================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// 检查登录状态
  Future<void> _checkLoginStatus() async {
    // 等待一小段时间显示启动页
    await Future.delayed(const Duration(milliseconds: 800));

    // 检查是否已登录
    final isLoggedIn = await SecureStorage.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // 已登录，获取登录信息
      final loginInfo = await SecureStorage.getLoginInfo();
      final accessToken = loginInfo?['access_token'] ?? '';
      final userId = loginInfo?['user_id'] ?? '';
      final userRole = loginInfo?['user_role'] as String?;

      // 检查 widget 是否还在树中
      if (!mounted) return;

      // 根据角色跳转到对应主页
      if (userRole == 'receiver') {
        // 接收者：直接进入接收者主页
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ReceiverHomePage(
              userId: userId,
              accessToken: accessToken,
            ),
          ),
        );
      } else if (userRole == 'sender') {
        // 发送者：直接进入发送者主页
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SenderHomePage(
              userId: userId,
              accessToken: accessToken,
            ),
          ),
        );
      } else {
        // 未选择角色：进入角色选择页面
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RoleSelectionPage(
              userId: userId,
              accessToken: accessToken,
            ),
          ),
        );
      }
    } else {
      // 未登录，跳转到认证页面
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.family_restroom,
                size: 80,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            // 应用名称
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                fontFamily: AppConfig.fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            // 启动文案
            Text(
              AppStrings.appSubtitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
                fontFamily: AppConfig.fontFamily,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
