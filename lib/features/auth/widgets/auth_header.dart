import 'package:flutter/material.dart';
import '../../../constants/app_strings.dart';
import '../../../theme/app_text_styles.dart';

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
          style: AppTextStyles.emojiLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),

        const SizedBox(height: 12),

        // 副标题
        Text(
          AppStrings.loginSubtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: lightTextColor,
          ),
        ),
      ],
    );
  }
}
