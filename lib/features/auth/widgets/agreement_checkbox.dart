import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../theme/app_text_styles.dart';
import '../../../router/app_router.dart';

class AgreementCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isDark;

  const AgreementCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.caption.copyWith(
      color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
    );
    final linkStyle = TextStyle(
      color: AppColors.primaryColor,
      fontSize: AppTextStyles.caption.fontSize,
    );

    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryColor,
              side: BorderSide(
                color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: style,
                children: [
                  const TextSpan(text: '我已阅读并同意'),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => context.pushToUserAgreement(),
                      child: Text('《${AppStrings.userAgreement}》', style: linkStyle),
                    ),
                  ),
                  const TextSpan(text: '和'),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => context.pushToPrivacyPolicy(),
                      child: Text('《${AppStrings.privacyPolicy}》', style: linkStyle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
