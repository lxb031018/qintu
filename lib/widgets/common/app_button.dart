import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

/// 通用按钮组件
///
/// 自动使用应用主题样式，避免硬编码
/// 支持多种按钮类型和加载状态
/// ============================================

enum AppButtonType {
  /// 主要按钮（填充色）
  primary,

  /// 次要按钮（描边）
  outlined,

  /// 文字按钮（无背景）
  text,

  /// 图标按钮
  icon,
}

enum AppButtonSize {
  /// 小按钮（用于行内或小空间）
  small,

  /// 默认按钮
  medium,

  /// 大按钮（用于重要操作）
  large,
}

class AppButton extends StatelessWidget {
  /// 按钮类型
  final AppButtonType type;

  /// 按钮尺寸
  final AppButtonSize size;

  /// 按钮文本
  final String? text;

  /// 图标（可选）
  final IconData? icon;

  /// 图标位置（在文本前或后）
  final IconPosition iconPosition;

  /// 是否正在加载
  final bool isLoading;

  /// 加载时显示的文本（可选，默认使用 text）
  final String? loadingText;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 自定义颜色（可选，覆盖主题）
  final Color? backgroundColor;

  /// 自定义前景色（可选，覆盖主题）
  final Color? foregroundColor;

  /// 是否禁用
  final bool disabled;

  /// 自定义最小宽度（可选）
  final double? minWidth;

  /// 自定义高度（可选）
  final double? height;

  const AppButton({
    super.key,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.text,
    this.icon,
    this.iconPosition = IconPosition.start,
    this.isLoading = false,
    this.loadingText,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.disabled = false,
    this.minWidth,
    this.height,
  });

  /// 便捷构造函数：主要按钮
  const AppButton.primary({
    super.key,
    this.text,
    this.icon,
    this.iconPosition = IconPosition.start,
    this.isLoading = false,
    this.loadingText,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.disabled = false,
    this.minWidth,
    this.height,
    this.size = AppButtonSize.medium,
  }) : type = AppButtonType.primary;

  /// 便捷构造函数：描边按钮
  const AppButton.outlined({
    super.key,
    this.text,
    this.icon,
    this.iconPosition = IconPosition.start,
    this.isLoading = false,
    this.loadingText,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.disabled = false,
    this.minWidth,
    this.height,
    this.size = AppButtonSize.medium,
  }) : type = AppButtonType.outlined;

  /// 便捷构造函数：文字按钮
  const AppButton.text({
    super.key,
    this.text,
    this.icon,
    this.iconPosition = IconPosition.start,
    this.isLoading = false,
    this.loadingText,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.disabled = false,
    this.minWidth,
    this.height,
    this.size = AppButtonSize.medium,
  }) : type = AppButtonType.text;

  /// 便捷构造函数：图标按钮
  const AppButton.iconButton({
    super.key,
    required this.icon,
    this.iconPosition = IconPosition.start,
    this.isLoading = false,
    this.loadingText,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.disabled = false,
    this.minWidth,
    this.height,
    this.size = AppButtonSize.medium,
    this.text,
  }) : type = AppButtonType.icon;

  Size get _sizeDimensions {
    if (height != null) {
      return Size(minWidth ?? double.infinity, height!);
    }

    switch (size) {
      case AppButtonSize.small:
        return Size(minWidth ?? 0, 36);
      case AppButtonSize.medium:
        return Size(minWidth ?? double.infinity, 60);
      case AppButtonSize.large:
        return Size(minWidth ?? double.infinity, 72);
    }
  }

  TextStyle? get _textStyle {
    switch (size) {
      case AppButtonSize.small:
        return AppTextStyles.bodySmall;
      case AppButtonSize.medium:
        return AppTextStyles.button;
      case AppButtonSize.large:
        return AppTextStyles.button.copyWith(fontSize: 18);
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 24;
      case AppButtonSize.large:
        return 28;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = disabled || isLoading ? null : onPressed;

    Widget child = _buildChild();

    switch (type) {
      case AppButtonType.primary:
        return SizedBox(
          width: _sizeDimensions.width,
          height: _sizeDimensions.height,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: child,
          ),
        );

      case AppButtonType.outlined:
        return SizedBox(
          width: _sizeDimensions.width,
          height: _sizeDimensions.height,
          child: OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              side: BorderSide(
                color: foregroundColor ?? Theme.of(context).colorScheme.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: child,
          ),
        );

      case AppButtonType.text:
        return SizedBox(
          width: _sizeDimensions.width,
          height: _sizeDimensions.height,
          child: TextButton(
            onPressed: effectiveOnPressed,
            style: TextButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: child,
          ),
        );

      case AppButtonType.icon:
        return SizedBox(
          width: _sizeDimensions.width != double.infinity
              ? _sizeDimensions.width
              : _sizeDimensions.height,
          height: _sizeDimensions.height,
          child: IconButton(
            onPressed: effectiveOnPressed,
            icon: child,
            style: IconButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
            ),
          ),
        );
    }
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? Colors.white,
          ),
        ),
      );
    }

    if (icon != null && text != null) {
      final iconWidget = Icon(icon, size: _iconSize);
      final textWidget = Text(text!, style: _textStyle);

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconPosition == IconPosition.start
            ? [iconWidget, const SizedBox(width: 8), textWidget]
            : [textWidget, const SizedBox(width: 8), iconWidget],
      );
    }

    if (icon != null) {
      return Icon(icon, size: _iconSize);
    }

    if (text != null) {
      return Text(text!, style: _textStyle);
    }

    return const SizedBox.shrink();
  }
}

enum IconPosition {
  start,
  end,
}
