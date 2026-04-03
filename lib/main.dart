import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'pages/auth_page.dart';
import 'pages/role_selection_page.dart';
import 'services/token_storage.dart';
import 'theme/app_theme.dart';

/// ============================================
/// 亲途应用入口
/// ============================================

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
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
    final isLoggedIn = await TokenStorage.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // 已登录，获取登录信息
      final loginInfo = await TokenStorage.getLoginInfo();
      final accessToken = loginInfo?['access_token'] ?? '';
      final phoneNumber = loginInfo?['phone_number'] ?? '';

      // 跳转到角色选择页面
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => RoleSelectionPage(
            userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
            accessToken: accessToken,
          ),
        ),
      );
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.15),
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
                fontFamily: 'PingFang SC',
              ),
            ),
            const SizedBox(height: 16),
            // 加载指示器
            CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}