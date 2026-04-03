import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../config/app_config.dart';

/// ============================================
/// 错误提示卡片
///
/// 显示用户友好的错误信息
/// ============================================

class ErrorCard extends StatelessWidget {
  /// 错误信息
  final String message;

  /// 错误颜色
  final Color errorColor;

  const ErrorCard({
    super.key,
    required this.message,
    this.errorColor = AppColors.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: errorColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: errorColor,
                fontSize: 18,
                fontFamily: AppConfig.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}