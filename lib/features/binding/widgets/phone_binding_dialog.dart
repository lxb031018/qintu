import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/binding_provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/app_snackbar.dart';
import '../../../utils/validators.dart';

/// 手机号绑定对话框
class PhoneBindingDialog extends StatefulWidget {
  final BuildContext parentContext;

  const PhoneBindingDialog({super.key, required this.parentContext});

  @override
  State<PhoneBindingDialog> createState() => _PhoneBindingDialogState();
}

class _PhoneBindingDialogState extends State<PhoneBindingDialog> {
  final _partnerNameController = TextEditingController(); // 您对对方的称呼
  final _nameController = TextEditingController();        // 对方对您的称呼
  final _phoneController = TextEditingController();       // 对方手机号
  bool _isLoading = false;
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

  void _handleSubmit() async {
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

    // 校验手机号（使用 Validators 工具类）
    final phoneError = Validators.validatePhone(_phoneController.text);
    if (phoneError != null) {
      setState(() => _phoneError = phoneError);
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    // 调用 BindingProvider 发送绑定请求
    final provider = context.read<BindingProvider>();
    final receiverPhone = '+86 ${_phoneController.text}';
    final senderName = _nameController.text;          // 对方对您的称呼
    final receiverName = _partnerNameController.text; // 您对对方的称呼

    final success = await provider.requestPhoneBinding(
      receiverPhone: receiverPhone,
      senderName: senderName,
      receiverName: receiverName,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);
    _showTimer?.cancel();

    final parentCtx = widget.parentContext;
    // 先弹出提示，再关闭对话框
    if (parentCtx.mounted) {
      if (success) {
        AppSnackbar.showPrimary(parentCtx, AppStrings.bindingRequestSent);
      } else {
        final errorMessage = provider.lastErrorMessage ?? AppStrings.revokeBindingFailed;
        AppSnackbar.showErrorTheme(parentCtx, errorMessage);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  void _togglePhoneVisibility() {
    if (_obscurePhone) {
      setState(() => _obscurePhone = false);
      _showTimer?.cancel();
      _showTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _obscurePhone = true);
      });
    } else {
      _showTimer?.cancel();
      setState(() => _obscurePhone = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: null, // 无标题
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 320,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 您对对方的称呼（最上方）
              TextField(
                controller: _partnerNameController,
                enabled: !_isLoading,
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
                enabled: !_isLoading,
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
                enabled: !_isLoading,
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
              if (_isLoading)
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _handleCancel,
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: const Text(AppStrings.sendRequest),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
    );
  }

  void _handleCancel() {
    _showTimer?.cancel();
    Navigator.pop(context);
  }
}
