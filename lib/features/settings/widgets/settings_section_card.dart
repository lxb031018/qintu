import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_spacings.dart';
import '../../../constants/app_radii.dart';
import '../../../theme/app_text_styles.dart';

/// ============================================
/// 设置分区卡片组件
///
/// 通用的设置项容器，提供统一的卡片样式
/// ============================================

class SettingsSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacings.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.cardBackground,
        borderRadius: BorderRadius.all(AppRadii.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackOpacity5,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkLightTextColor
                  : AppColors.lightTextColor,
            ),
          ),
          SizedBox(height: AppSpacings.lg),
          child,
        ],
      ),
    );
  }
}

@Preview(name: '设置分区卡片', group: 'settings')
Widget previewSettingsSectionCard() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: Center(
        child: SettingsSectionCard(
          title: '示例设置',
          child: const ListTile(
            leading: Icon(Icons.settings),
            title: Text('示例设置项'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      ),
    ),
  );
}
