import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_text_styles.dart';

/// 启动页 - 应用初始化期间显示的加载页面
///
/// 此页面在用户状态初始化期间短暂显示，
/// 然后根据登录状态自动重定向到相应页面。
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.textColor;
    final primaryColor = AppColors.primaryColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 珊瑚橙色圆形背景
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.navigation_rounded,
                size: 64,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: AppTextStyles.splashLogo.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.appSubtitle,
              style: AppTextStyles.splashSubtitle.copyWith(
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: '启动页', group: 'app_shell')
Widget previewSplashScreen() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const SplashScreen(),
  );
}
