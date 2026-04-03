import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../constants/app_strings.dart';

/// 认证页标题组件
///
/// 显示 Logo 和欢迎语
/// ============================================

class AuthHeader extends StatelessWidget {
  /// 主色调
  final Color primaryColor;

  /// 文字颜色
  final Color textColor;

  /// 浅色文字
  final Color lightTextColor;

  const AuthHeader({
    super.key,
    required this.primaryColor,
    required this.textColor,
    required this.lightTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo 图标
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.family_restroom,
            size: 60,
            color: primaryColor,
          ),
        ),

        const SizedBox(height: 24),

        // 标题
        Text(
          AppStrings.welcomeTitle,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: AppConfig.fontFamily,
          ),
        ),

        const SizedBox(height: 12),

        // 副标题
        Text(
          AppStrings.loginSubtitle,
          style: TextStyle(
            fontSize: 18,
            color: lightTextColor,
            fontFamily: AppConfig.fontFamily,
          ),
        ),
      ],
    );
  }
}