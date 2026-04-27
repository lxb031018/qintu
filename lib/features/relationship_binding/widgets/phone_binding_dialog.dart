import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/validation/validators.dart';
import '../../../utils/ui/app_snackbar.dart';
import '../provider/binding_page_provider.dart';

/// ============================================
/// 手机号绑定对话框
///
/// UI 层：只负责输入和显示
/// 调用 bindingPageProvider.requestBinding() 发起请求
/// ============================================

class PhoneBindingDialog extends ConsumerStatefulWidget {
  final BuildContext parentContext;

  const PhoneBindingDialog({super.key, required this.parentContext});

  @override
  ConsumerState<PhoneBindingDialog> createState() => _PhoneBindingDialogState();
}

class _PhoneBindingDialogState extends ConsumerState<PhoneBindingDialog> {
  final _partnerNameController = TextEditingController(); // 您对对方的称呼
  final _nameController = TextEditingController();        // 对方对您的称呼
  final _phoneController = TextEditingController();       // 对方手机号
  bool _obscurePhone = true;
  Timer? _showTimer;
  String? _partnerNameError;
  String? _nameError;
  String? _phoneError;

  @override
  void dispose() {
    _partnerNameController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _showTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // 清除旧错误
    setState(() {
      _partnerNameError = null;
      _nameError = null;
      _phoneError = null;
    });

    bool hasError = false;

    // 校验"您对对方的称呼"
    if (_partnerNameController.text.isEmpty) {
      setState(() => _partnerNameError = AppStrings.pleaseFillNameForPartner);
      hasError = true;
    }

    // 校验"对方对您的称呼"
    if (_nameController.text.isEmpty) {
      setState(() => _nameError = AppStrings.pleaseFillName);
      hasError = true;
    }

    // 校验手机号
    final phoneError = Validators.validatePhone(_phoneController.text);
    if (phoneError != null) {
      setState(() => _phoneError = phoneError);
      hasError = true;
    }

    if (hasError) return;

    // 显示加载状态（通过 provider）
    final notifier = ref.read(bindingPageProvider.notifier);
    final receiverPhone = '+86 ${_phoneController.text}';
    final senderName = _nameController.text;
    final receiverName = _partnerNameController.text;

    final success = await notifier.requestBinding(
      receiverPhone: receiverPhone,
      senderName: senderName,
      receiverName: receiverName,
    );

    if (!mounted) return;

    if (success && widget.parentContext.mounted) {
      AppSnackbar.showPrimary(widget.parentContext, AppStrings.bindingRequestSent);
      Navigator.pop(widget.parentContext);
    }
  }

  void _togglePhoneVisibility() {
    _showTimer?.cancel();
    if (_obscurePhone) {
      setState(() => _obscurePhone = false);
      _showTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _obscurePhone = true);
      });
    } else {
      setState(() => _obscurePhone = true);
    }
  }

  void _handleCancel() {
    _showTimer?.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pageState = ref.watch(bindingPageProvider);
    final isLoading = pageState.isLoading;
    final errorMessage = pageState.errorMessage;

    return AlertDialog(
      title: null,
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 您对对方的称呼
              TextField(
                controller: _partnerNameController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: AppStrings.yourNameForPartner,
                  hintText: AppStrings.yourNameForPartner,
                  border: const OutlineInputBorder(),
                  counterText: '',
                  errorText: _partnerNameError,
                ),
                maxLength: 20,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                  return Text(
                    '$currentLength/$maxLength',
                    style: TextStyle(
                      color: currentLength > maxLength!
                          ? AppColors.errorColor
                          : Theme.of(context).hintColor,
                      fontSize: 12,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // 2. 对方对您的称呼
              TextField(
                controller: _nameController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: AppStrings.yourName,
                  hintText: AppStrings.yourName,
                  border: const OutlineInputBorder(),
                  counterText: '',
                  errorText: _nameError,
                ),
                maxLength: 20,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                  return Text(
                    '$currentLength/$maxLength',
                    style: TextStyle(
                      color: currentLength > maxLength!
                          ? AppColors.errorColor
                          : Theme.of(context).hintColor,
                      fontSize: 12,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // 3. 对方手机号
              TextField(
                controller: _phoneController,
                enabled: !isLoading,
                obscureText: _obscurePhone,
                obscuringCharacter: '●',
                decoration: InputDecoration(
                  labelText: AppStrings.partnerPhone,
                  hintText: AppStrings.partnerPhone,
                  border: const OutlineInputBorder(),
                  errorText: _phoneError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePhone ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: _togglePhoneVisibility,
                  ),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
              ),
              // 底部提示
              const SizedBox(height: 16),
              Text(
                AppStrings.bindingHintText,
                style: AppTextStyles.statusTag,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.bindingRequestConfirmHint,
                style: AppTextStyles.statusTag.copyWith(
                  color: AppColors.blue700,
                ),
                textAlign: TextAlign.center,
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(AppStrings.loadingText),
                    ],
                  ),
                ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: AppColors.errorColor),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : _handleCancel,
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _handleSubmit,
          child: const Text(AppStrings.sendRequest),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
    );
  }
}
