import 'package:flutter/material.dart';
import '../../../../constants/app_spacings.dart';
import '../../../../widgets/common/qintu_pill_chip.dart';

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

          return QintuPillChip(
            label: option.label,
            isSelected: isSelected,
            onTap: () => onStrategyChanged(option.value),
            height: 32,
            minWidth: 56,
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
