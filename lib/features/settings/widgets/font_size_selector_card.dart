import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/font_size_options.dart';
import '../../../managers/settings_manager.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/logger.dart';

/// 字体大小选择卡片组件

class FontSizeSelectorCard extends StatefulWidget {
  const FontSizeSelectorCard({super.key});

  @override
  State<FontSizeSelectorCard> createState() => _FontSizeSelectorCardState();
}

class _FontSizeSelectorCardState extends State<FontSizeSelectorCard> {
  late SettingsManager _settingsManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsManager = Provider.of<SettingsManager>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.textColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(Icons.text_fields, color: textColor, size: 24),
              const SizedBox(width: 12),
              Text(
                '字体大小',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 选项网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: FontSizeOption.values.length,
            itemBuilder: (context, index) {
              final option = FontSizeOption.values[index];
              final isSelected = option.scale == _settingsManager.fontSizeScale;
              return _FontSizeOptionButton(
                option: option,
                isSelected: isSelected,
                onTap: () => _selectFontSize(option.scale),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectFontSize(double scale) async {
    await _settingsManager.setFontSizeScale(scale);
    Logs.ui.info('字体大小已调整为 ${scale}x');
    
    // 触发全局刷新
    if (mounted) {
      setState(() {});
    }
  }
}

/// 字体大小选项按钮
class _FontSizeOptionButton extends StatelessWidget {
  final FontSizeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontSizeOptionButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : isDark
                  ? AppColors.darkBackgroundColor
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : isDark
                    ? AppColors.darkBorderColor
                    : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              color: isSelected ? Colors.white : AppColors.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              option.label,
              style: AppTextStyles.locationTitle.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
