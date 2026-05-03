import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_radii.dart';
import '../../../constants/app_spacings.dart';

class DrivingStrategySelector extends StatelessWidget {
  final int selectedStrategy;
  final ValueChanged<int> onStrategyChanged;

  const DrivingStrategySelector({
    super.key,
    required this.selectedStrategy,
    required this.onStrategyChanged,
  });

  static const _strategies = [
    _StrategyOption(label: '推荐', value: 10),
    _StrategyOption(label: '最快', value: 11),
    _StrategyOption(label: '最短', value: 14),
    _StrategyOption(label: '避免拥堵', value: 12),
    _StrategyOption(label: '不走高速', value: 13),
    _StrategyOption(label: '高速优先', value: 19),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacings.sm),
        itemCount: _strategies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = _strategies[index];
          final isSelected = option.value == selectedStrategy;

          return GestureDetector(
            onTap: () => onStrategyChanged(option.value),
            child: Container(
              height: 32,
              constraints: const BoxConstraints(minWidth: 56),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? AppColors.darkCardBackground : AppColors.grey100),
                borderRadius: BorderRadius.all(AppRadii.xlarge),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark ? AppColors.darkDividerColor : AppColors.grey300,
                        width: 1,
                      ),
              ),
              alignment: Alignment.center,
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextColor : AppColors.textColor),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StrategyOption {
  final String label;
  final int value;

  const _StrategyOption({required this.label, required this.value});
}
