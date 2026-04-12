import 'package:flutter/material.dart';
import '../../../theme/app_text_styles.dart';
import '../../../constants/app_colors.dart';

/// 认证按钮组件
///
/// 带渐变背景和加载状态的按钮
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
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: primaryColor, // 改为纯色，与其他页面按钮一致
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                  color: AppColors.whiteText,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: AppTextStyles.emojiIcon.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteText,
                ),
              ),
      ),
    );
  }
}
