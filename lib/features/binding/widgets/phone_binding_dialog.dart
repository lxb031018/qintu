import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/binding_provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../theme/app_text_styles.dart';

/// 手机号绑定对话框
class PhoneBindingDialog extends StatefulWidget {
  const PhoneBindingDialog({super.key});

  @override
  State<PhoneBindingDialog> createState() => _PhoneBindingDialogState();
}

class _PhoneBindingDialogState extends State<PhoneBindingDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePhone = true;
  Timer? _showTimer;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _showTimer?.cancel();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.pleaseFillName)),
      );
      return;
    }
    if (_phoneController.text.isEmpty || _phoneController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.invalidPhone)),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 调用 BindingProvider 发送绑定请求
    final provider = context.read<BindingProvider>();
    final receiverPhone = '+86 ${_phoneController.text}';
    final senderName = _nameController.text;
    
    final success = await provider.requestPhoneBinding(
      receiverPhone: receiverPhone,
      senderName: senderName,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);
    _showTimer?.cancel();
    Navigator.pop(context);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.bindingRequestSent),
          backgroundColor: AppColors.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? AppStrings.revokeBindingFailed),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
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
      title: const Text(AppStrings.sendBindingRequest),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: AppStrings.yourName,
              hintText: AppStrings.yourName,
              border: OutlineInputBorder(),
            ),
            maxLength: 20,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            enabled: !_isLoading,
            obscureText: _obscurePhone,
            obscuringCharacter: '●',
            decoration: InputDecoration(
              labelText: AppStrings.partnerPhone,
              hintText: AppStrings.partnerPhone,
              border: const OutlineInputBorder(),
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
          const SizedBox(height: 16),
          Text(
            AppStrings.bindingHintText,
            style: AppTextStyles.statusTag,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '对方将在收到请求后确认，确认后即可建立绑定关系',
            style: AppTextStyles.statusTag.copyWith(
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text(AppStrings.loadingText),
                ],
              ),
            ),
        ],
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
    );
  }

  void _handleCancel() {
    _showTimer?.cancel();
    Navigator.pop(context);
  }
}
