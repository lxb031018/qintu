import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_radii.dart';
import '../../../theme/app_text_styles.dart';
import '../../../router/app_router.dart';
import 'settings_section_card.dart';

class LegalLinksCard extends StatelessWidget {
  const LegalLinksCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsSectionCard(
      title: AppStrings.legalNotices,
      child: Column(
        children: [
          _buildLinkRow(
            context: context,
            isDark: isDark,
            icon: Icons.description_outlined,
            label: AppStrings.userAgreement,
            onTap: () => context.pushToUserAgreement(),
          ),
          Divider(
            height: 1,
            indent: 40,
            color: isDark ? AppColors.darkDividerColor : AppColors.dividerColor,
          ),
          _buildLinkRow(
            context: context,
            isDark: isDark,
            icon: Icons.privacy_tip_outlined,
            label: AppStrings.privacyPolicy,
            onTap: () => context.pushToPrivacyPolicy(),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(AppRadii.small),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDark ? AppColors.darkIconColor : AppColors.lightTextColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 22,
              color: isDark ? AppColors.darkIconColor : AppColors.lightTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
