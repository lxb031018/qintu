import 'package:flutter/material.dart';
import '../../../models/binding.dart';
import 'binding_card.dart';

/// 绑定列表视图（使用 Column 而非 ListView，避免与外层 SingleChildScrollView 冲突）
class BindingListView extends StatelessWidget {
  final List<Binding> bindings;
  final Function(int) onRevoke;

  const BindingListView({
    super.key,
    required this.bindings,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: bindings.map((binding) {
          return BindingCard(
            binding: binding,
            onRevoke: () => onRevoke(binding.id),
          );
        }).toList(),
      ),
    );
  }
}
