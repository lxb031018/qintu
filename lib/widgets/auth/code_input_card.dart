import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../constants/app_strings.dart';

/// ============================================
/// 验证码输入卡片
///
/// 用于认证页面第二步：输入验证码
/// ============================================

class CodeInputCard extends StatelessWidget {
  /// 验证码输入控制器
  final TextEditingController controller;

  /// 手机号（用于显示）
  final String phoneNumber;

  /// 主色调
  final Color primaryColor;

  /// 文字颜色
  final Color textColor;

  /// 浅色文字
  final Color lightTextColor;

  /// 倒计时（秒），0 表示可重新发送
  final int countdown;

  /// 重新发送回调
  final VoidCallback onResend;

  const CodeInputCard({
    super.key,
    required this.controller,
    required this.phoneNumber,
    required this.primaryColor,
    required this.textColor,
    required this.lightTextColor,
    required this.countdown,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 手机号显示
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.phone_android,
                color: primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '${AppStrings.codeSent} $phoneNumber',
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  fontFamily: AppConfig.fontFamily,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 验证码输入框
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: TextStyle(
              fontSize: 32,
              color: Colors.black87,
              fontFamily: AppConfig.fontFamily,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              labelText: AppStrings.codeLabel,
              labelStyle: TextStyle(
                color: primaryColor,
                fontSize: 20,
                fontFamily: AppConfig.fontFamily,
              ),
              hintText: AppStrings.codeHint,
              hintStyle: TextStyle(
                color: lightTextColor,
                fontSize: 18,
                fontFamily: AppConfig.fontFamily,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 重新发送按钮
        Row(
          children: [
            TextButton.icon(
              onPressed: countdown > 0 ? null : onResend,
              icon: Icon(
                Icons.refresh,
                size: 20,
                color: countdown > 0 ? lightTextColor : primaryColor,
              ),
              label: Text(
                countdown > 0 ? AppStrings.resendCodeCountdown(countdown) : AppStrings.resendCode,
                style: TextStyle(
                  color: countdown > 0 ? lightTextColor : primaryColor,
                  fontSize: 16,
                  fontFamily: AppConfig.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}