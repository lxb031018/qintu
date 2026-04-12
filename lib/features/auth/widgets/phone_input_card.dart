import 'dart:async';
import 'package:flutter/material.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// 手机号输入卡片
///
/// 用于认证页面第一步：输入手机号
/// 支持隐私保护：默认圆点隐藏，点击眼睛显示 2 秒后恢复
/// ============================================

class PhoneInputCard extends StatefulWidget {
  /// 手机号输入控制器
  final TextEditingController controller;

  /// 主色调
  final Color primaryColor;

  /// 文字颜色
  final Color textColor;

  /// 浅色文字
  final Color lightTextColor;

  const PhoneInputCard({
    super.key,
    required this.controller,
    required this.primaryColor,
    required this.textColor,
    required this.lightTextColor,
  });

  @override
  State<PhoneInputCard> createState() => _PhoneInputCardState();
}

class _PhoneInputCardState extends State<PhoneInputCard> {
  bool _obscureText = true;
  Timer? _showTimer;

  @override
  void dispose() {
    _showTimer?.cancel();
    super.dispose();
  }

  /// 切换显示/隐藏手机号
  void _toggleVisibility() {
    if (_obscureText) {
      // 显示真实号码
      setState(() {
        _obscureText = false;
      });
      
      // 2 秒后自动恢复圆点
      _showTimer?.cancel();
      _showTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _obscureText = true;
          });
        }
      });
    } else {
      // 手动隐藏
      _showTimer?.cancel();
      setState(() {
        _obscureText = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final inputTextColor = isDark ? AppColors.darkInputTextColor : AppColors.textColor;

    return Container(
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
        controller: widget.controller,
        keyboardType: TextInputType.phone,
        maxLength: 11,
        obscureText: _obscureText,
        obscuringCharacter: '•',
        style: AppTextStyles.emojiIcon.copyWith(
          color: inputTextColor,
        ),
        decoration: InputDecoration(
          labelText: AppStrings.phoneLabel,
          labelStyle: AppTextStyles.inputLabel.copyWith(
            color: widget.primaryColor,
          ),
          hintText: AppStrings.phoneHint,
          hintStyle: AppTextStyles.inputHint.copyWith(
            color: widget.lightTextColor,
          ),
          prefixText: '+86 ',
          prefixStyle: AppTextStyles.emojiIcon.copyWith(
            color: widget.primaryColor,
            fontWeight: FontWeight.bold,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: widget.primaryColor,
            ),
            onPressed: _toggleVisibility,
            tooltip: _obscureText ? AppStrings.showPhone : AppStrings.hidePhone,
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
    );
  }
}
