import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCardBackground
                            : AppColors.cardBackground,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color:
                            isDark ? AppColors.darkTextColor : AppColors.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '隐私政策',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? AppColors.darkTextColor : AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(
                    '亲途（以下简称"本应用"）尊重并保护您的隐私。本隐私政策（以下简称"本政策"）将向您说明我们如何收集、使用、存储和保护您的个人信息。',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextColor
                          : AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _section(
                    isDark,
                    '一、我们收集的信息',
                    '在您使用本应用的过程中，我们可能会收集以下类型的信息：\n\n'
                        '1. 手机号：在您注册账号时，我们需要收集您的手机号码用于身份验证和账号管理。\n\n'
                        '2. 位置信息：在您使用地图导航、路线规划、位置共享等功能时，我们需要收集您的实时位置信息。这是本应用核心功能所必需的信息。\n\n'
                        '3. 照片：在您设置个人头像时，我们需要访问您的相册以选择照片。我们不会主动收集您的照片内容。\n\n'
                        '4. 设备信息：为保障账号安全和系统稳定运行，我们可能会收集您的设备型号、操作系统版本、设备标识符等信息。',
                  ),
                  _section(
                    isDark,
                    '二、信息的使用目的',
                    '我们收集的信息将用于以下目的：\n\n'
                        '1. 手机号：用于账号注册、登录验证、密码重置以及必要的服务通知。\n\n'
                        '2. 位置信息：用于提供地图展示、路线规划、实时导航、位置共享等核心功能。\n\n'
                        '3. 照片：仅用于为您提供个人头像设置功能。\n\n'
                        '4. 设备信息：用于设备识别、账号安全保护、系统兼容性适配和故障排查。',
                  ),
                  _section(
                    isDark,
                    '三、信息的存储与保护',
                    '3.1 您的个人信息将存储在中华人民共和国境内的服务器上。我们采取业界通用的安全技术措施保护您的信息安全。\n\n'
                        '3.2 我们仅在实现服务目的所必需的时间内保留您的个人信息，除非法律另有规定。\n\n'
                        '3.3 我们采取加密传输、访问控制、数据备份等技术手段防止信息泄露、篡改或丢失。',
                  ),
                  _section(
                    isDark,
                    '四、信息共享与披露',
                    '4.1 我们不会将您的个人信息出售给第三方。\n\n'
                        '4.2 我们可能会在以下情况下共享您的信息：\n'
                        '   (a) 获得您的明确同意；\n'
                        '   (b) 根据法律法规要求或政府机关的强制规定；\n'
                        '   (c) 为维护本应用的合法权益，如处理欺诈或安全漏洞。\n\n'
                        '4.3 本应用使用高德地图 SDK，位置信息将按照高德地图的隐私政策进行处理。',
                  ),
                  _section(
                    isDark,
                    '五、您的权利',
                    '您对您的个人信息享有以下权利：\n\n'
                        '1. 查阅权：您可以在应用内查看您的个人信息。\n\n'
                        '2. 更正权：如您的个人信息有误，您可以在应用内编辑修改。\n\n'
                        '3. 删除权：在特定情况下，您可以要求我们删除您的个人信息。\n\n'
                        '4. 撤回同意权：您可以通过系统设置撤回对位置信息、相册等权限的授权。撤回不影响撤回前基于授权已进行的信息处理。',
                  ),
                  _section(
                    isDark,
                    '六、权限说明',
                    '本应用可能申请以下系统权限：\n\n'
                        '1. 位置权限：用于地图导航和位置共享功能，如不授权将无法使用核心功能。\n\n'
                        '2. 相册权限：用于设置个人头像，如不授权将无法更换头像。\n\n'
                        '3. 存储权限：用于缓存地图数据和保存导航信息。\n\n'
                        '您可以在系统设置中随时关闭以上权限。',
                  ),
                  _section(
                    isDark,
                    '七、未成年人保护',
                    '7.1 本应用不建议未成年人独立使用。如您是未成年人，请在监护人的指导下使用本应用。\n\n'
                        '7.2 我们不会故意收集未成年人的个人信息。如发现我们无意中收集了未成年人的信息，我们将及时删除。',
                  ),
                  _section(
                    isDark,
                    '八、政策更新',
                    '8.1 我们可能会根据法律法规的变化或业务调整更新本政策。更新后的政策将在应用内公布。\n\n'
                        '8.2 如本政策发生重大变更，我们将通过应用内通知或其他方式提醒您。',
                  ),
                  _section(
                    isDark,
                    '九、联系我们',
                    '如您对本政策有任何疑问或建议，或需要行使您的个人信息权利，请通过以下方式联系我们：\n\n'
                        '• 应用内反馈渠道\n'
                        '• 开发者邮箱：lxb031018@163.com\n\n'
                        '我们将尽快审核您的问题，并在合理期限内予以回复。',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '最后更新日期：2026年6月',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkLightTextColor
                          : AppColors.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(bool isDark, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextColor : AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.darkLightTextColor
                  : AppColors.lightTextColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
