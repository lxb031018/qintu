import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qintu/constants/app_colors.dart';
import 'package:qintu/constants/app_strings.dart';
import 'package:qintu/constants/app_spacings.dart';
import 'package:qintu/constants/binding_limits.dart';
import 'package:qintu/providers/binding_provider.dart';
import 'package:qintu/widgets/common/app_button.dart';

/// ============================================
/// 添加绑定按钮
///
/// 使用统一的 AppButton 组件
/// ============================================

class AddBindingButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const AddBindingButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bindingState = ref.watch(bindingProvider);
    final summary = bindingState.bindingSummary;
    final total = (summary?.asSender ?? 0) + (summary?.asReceiver ?? 0);

    if (total >= BindingLimits.maxBindingsPerUser) {
      return Padding(
        padding: EdgeInsets.all(AppSpacings.lg),
        child: Text(
          AppStrings.bindingLimitReached,
          style: TextStyle(color: AppColors.grey500),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(AppSpacings.lg),
      child: AppButton(
        text: AppStrings.addNewBinding,
        icon: Icons.add,
        onPressed: onPressed,
        height: 72,
      ),
    );
  }
}
