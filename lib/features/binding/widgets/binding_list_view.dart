import 'package:flutter/material.dart';
import '../../../models/binding.dart';
import 'binding_card.dart';

/// 绑定列表视图
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bindings.length,
      itemBuilder: (context, index) {
        final binding = bindings[index];
        return BindingCard(
          binding: binding,
          onRevoke: () => onRevoke(binding.id),
        );
      },
    );
  }
}
