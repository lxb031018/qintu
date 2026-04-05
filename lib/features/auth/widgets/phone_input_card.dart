import 'dart:async';
import 'package:flutter/material.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_strings.dart';

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
    final cardBackground = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final inputTextColor = isDark ? Colors.white : const Color(0xFF212121);

    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.1),
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
        style: TextStyle(
          fontSize: 24,
          color: inputTextColor,
          fontFamily: AppConfig.fontFamily,
        ),
        decoration: InputDecoration(
          labelText: AppStrings.phoneLabel,
          labelStyle: TextStyle(
            color: widget.primaryColor,
            fontSize: 20,
            fontFamily: AppConfig.fontFamily,
          ),
          hintText: AppStrings.phoneHint,
          hintStyle: TextStyle(
            color: widget.lightTextColor,
            fontSize: 18,
            fontFamily: AppConfig.fontFamily,
          ),
          prefixText: '+86 ',
          prefixStyle: TextStyle(
            color: widget.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: AppConfig.fontFamily,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: widget.primaryColor,
            ),
            onPressed: _toggleVisibility,
            tooltip: _obscureText ? '显示手机号' : '隐藏手机号',
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
