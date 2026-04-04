import 'package:flutter/material.dart';
import '../../../config/app_config.dart';

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
        gradient: LinearGradient(
          colors: [
            primaryColor,
            const Color(0xFFFF9F7F),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
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
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: AppConfig.fontFamily,
                ),
              ),
      ),
    );
  }
}
