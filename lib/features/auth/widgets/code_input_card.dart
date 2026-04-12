import 'package:flutter/material.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/phone_utils.dart';

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

  /// 修改手机号回调
  final VoidCallback? onChangePhone;

  const CodeInputCard({
    super.key,
    required this.controller,
    required this.phoneNumber,
    required this.primaryColor,
    required this.textColor,
    required this.lightTextColor,
    required this.countdown,
    required this.onResend,
    this.onChangePhone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final inputTextColor = isDark ? AppColors.darkInputTextColor : AppColors.textColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 手机号显示
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBackground,
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
              Expanded(
                child: Text(
                  '${AppStrings.codeSent} ${PhoneUtils.maskPhone(phoneNumber)}',
                  style: AppTextStyles.caption.copyWith(
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onChangePhone != null)
                TextButton(
                  onPressed: onChangePhone,
                  child: Text(
                    AppStrings.modify,
                    style: AppTextStyles.locationTitle.copyWith(
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 验证码输入框
        Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.blackOpacity15 : AppColors.blackOpacity5, // 改为标准阴影
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: AppTextStyles.number.copyWith(
              color: inputTextColor,
            ),
            decoration: InputDecoration(
              labelText: AppStrings.codeLabel,
              labelStyle: AppTextStyles.inputLabel.copyWith(
                color: primaryColor,
              ),
              hintText: AppStrings.codeHint,
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: lightTextColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: cardBackground,
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
                style: AppTextStyles.buttonSmall.copyWith(
                  color: countdown > 0 ? lightTextColor : primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
