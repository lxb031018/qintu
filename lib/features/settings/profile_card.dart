import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/auth_state_manager.dart';
import '../../../theme/app_text_styles.dart';
import '../../../router/app_router.dart';
import '../../../config/environments/environment_manager.dart';
import 'widgets/settings_section_card.dart';

/// 个人信息卡片
class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userState = ref.watch(authStateProvider);

    return SettingsSectionCard(
      title: '个人信息',
      child: InkWell(
        onTap: () => context.pushToProfile(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // 头像
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkLightTextColor.withValues(alpha: 0.3) : AppColors.lightTextColor.withValues(alpha: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: userState.avatarUrl != null && userState.avatarUrl!.isNotEmpty
                      ? Image.network(
                          EnvironmentManager.baseUrl + userState.avatarUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            size: 28,
                            color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 28,
                          color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // 昵称和ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userState.userId?.isNotEmpty == true
                          ? _maskUserId(userState.userId!)
                          : '未登录',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID: ${userState.userId ?? '--------'}',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              // 箭头
              Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _maskUserId(String userId) {
    if (userId.length <= 4) return userId;
    return userId;
  }
}