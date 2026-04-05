import 'package:flutter/material.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_strings.dart';

/// 认证页标题组件
///
/// 显示 Logo 和欢迎语
/// ============================================

class AuthHeader extends StatelessWidget {
  /// 文字颜色
  final Color textColor;

  /// 浅色文字
  final Color lightTextColor;

  const AuthHeader({
    super.key,
    required this.textColor,
    required this.lightTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
