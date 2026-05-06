import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_spacings.dart';
import '../../provider/location_input_provider.dart';

/// 输入行组件
///
/// 纯 UI 组件，包含图标、文本输入框和清除按钮
class LocationInputRow extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final bool isOrigin;
  final TextEditingController controller;
  final FocusNode focusNode;
  final InputFieldState state;
  final ValueChanged<bool> onFocusChange;
  final ValueChanged<bool>? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onClear;

  const LocationInputRow({
    super.key,
    required this.icon,
    required this.placeholder,
    required this.isOrigin,
    required this.controller,
    required this.focusNode,
    required this.state,
    required this.onFocusChange,
    this.onTap,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacings.sm),
            child: Icon(
              icon,
              size: 20,
              color: isOrigin ? AppColors.successColor : AppColors.errorColor,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onTap: onTap != null ? () => onTap!(isOrigin) : null,
              onChanged: onChanged != null
                  ? (value) => onChanged!(value)
                  : null,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkLightTextColor
                    : AppColors.lightTextColor,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(
                  color: AppColors.grey400,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(
                  left: AppSpacings.sm,
                  right: AppSpacings.sm,
                  top: AppSpacings.sm,
                  bottom: AppSpacings.sm,
                ),
              ),
            ),
          ),
          if (state.hasText)
            GestureDetector(
              onTap: onClear != null ? () => onClear!(isOrigin) : null,
              child: const Padding(
                padding: EdgeInsets.all(AppSpacings.sm),
                child: Icon(
                  Icons.clear,
                  size: 18,
                  color: AppColors.grey400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}