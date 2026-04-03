import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../constants/app_strings.dart';

/// 手机号输入卡片
///
/// 用于认证页面第一步：输入手机号
/// ============================================

class PhoneInputCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
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
        keyboardType: TextInputType.phone,
        maxLength: 11,
        style: TextStyle(
          fontSize: 24,
          color: Colors.black87,
          fontFamily: AppConfig.fontFamily,
        ),
        decoration: InputDecoration(
          labelText: AppStrings.phoneLabel,
          labelStyle: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontFamily: AppConfig.fontFamily,
          ),
          hintText: AppStrings.phoneHint,
          hintStyle: TextStyle(
            color: lightTextColor,
            fontSize: 18,
            fontFamily: AppConfig.fontFamily,
          ),
          prefixText: '+86 ',
          prefixStyle: TextStyle(
            color: primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
    );
  }
}