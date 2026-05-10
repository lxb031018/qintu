import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/location_Input/location_input_provider.dart';
import 'location_input_row.dart';

/// 可滑动交换的输入行
///
/// 包装 LocationInputRow，添加拖拽检测逻辑
/// 当用户上下拖拽超过 50px 时触发 onSwapRequested
class SwappableLocationRow extends ConsumerStatefulWidget {
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
  final VoidCallback? onSwapRequested;

  const SwappableLocationRow({
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
    this.onSwapRequested,
  });

  @override
  ConsumerState<SwappableLocationRow> createState() => _SwappableLocationRowState();
}

class _SwappableLocationRowState extends ConsumerState<SwappableLocationRow> {
  double? _dragStartY;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _dragStartY = event.position.dy;
      },
      onPointerUp: (event) {
        if (_dragStartY == null) return;
        final dragEndY = event.position.dy;
        final deltaY = dragEndY - _dragStartY!;
        _dragStartY = null;

        if (deltaY.abs() > 50) {
          widget.onSwapRequested?.call();
        }
      },
      child: LocationInputRow(
        icon: widget.icon,
        placeholder: widget.placeholder,
        isOrigin: widget.isOrigin,
        controller: widget.controller,
        focusNode: widget.focusNode,
        state: widget.state,
        onFocusChange: widget.onFocusChange,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        onClear: widget.onClear,
      ),
    );
  }
}