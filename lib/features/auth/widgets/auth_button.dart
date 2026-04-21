import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../../widgets/common/app_button.dart';
import '../../../constants/colors/app_colors.dart';
import '../../../constants/strings/app_strings.dart';

/// 认证按钮组件
///
/// 使用统一的 AppButton 组件，支持加载状态
/// ============================================

class AuthButton extends StatelessWidget {
  /// 按钮文本（非加载状态）
  final String text;

  /// 主色调
  final Color primaryColor;

  /// 是否正在加载
  final bool isLoading;

  /// 点击回调
  final VoidCallback onPressed;

  const AuthButton({
    super.key,
    required this.text,
    required this.primaryColor,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      isLoading: isLoading,
      onPressed: onPressed,
      backgroundColor: primaryColor,
      foregroundColor: TextColors.white,
      height: 60,
    );
  }
}

@Preview(name: '认证按钮-正常', group: 'auth')
Widget previewAuthButtonNormal() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: AuthButton(
          text: AuthStrings.login,
          primaryColor: ButtonColors.primaryBg,
          isLoading: false,
          onPressed: () {},
        ),
      ),
    ),
  );
}

@Preview(name: '认证按钮-加载', group: 'auth')
Widget previewAuthButtonLoading() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: AuthButton(
          text: AuthStrings.login,
          primaryColor: ButtonColors.primaryBg,
          isLoading: true,
          onPressed: () {},
        ),
      ),
    ),
  );
}
