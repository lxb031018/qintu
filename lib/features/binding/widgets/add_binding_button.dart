import 'package:flutter/material.dart';
import '../../../providers/binding_provider.dart';
import '../../../constants/app_strings.dart';
import '../../../theme/app_text_styles.dart';

/// 添加绑定按钮
class AddBindingButton extends StatelessWidget {
  final BindingProvider provider;
  final VoidCallback onPressed;

  const AddBindingButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 如果发送者和接收者都达到上限，不显示按钮
    if (provider.isSenderLimitReached && provider.isReceiverLimitReached) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          AppStrings.bindingLimitReached,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add, size: 24),
          label: Text(
            AppStrings.addNewBinding,
            style: AppTextStyles.buttonSmall,
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
