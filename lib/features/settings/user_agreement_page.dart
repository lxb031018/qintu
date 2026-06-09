import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../theme/app_text_styles.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

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
                    '用户协议',
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
                    '欢迎您使用亲途（以下简称"本应用"）。在您使用本应用之前，请仔细阅读以下用户协议（以下简称"本协议"）。',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextColor
                          : AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _section(
                    isDark,
                    '一、协议范围',
                    '1.1 本协议是您与亲途之间关于使用本应用服务所订立的协议。\n\n'
                        '1.2 本协议内容同时包括本应用可能不断发布的关于本服务的相关协议、业务规则等内容。上述内容一经正式发布，即为本协议不可分割的组成部分。',
                  ),
                  _section(
                    isDark,
                    '二、账号注册与使用',
                    '2.1 您在使用本应用的部分功能前需要注册一个账号。您应使用手机号进行注册，并保证注册信息的真实性、准确性。\n\n'
                        '2.2 注册成功后，您将获得一个用户账号。您应妥善保管您的账号信息，因您保管不善导致的账号被盗用或数据丢失，由您自行承担责任。\n\n'
                        '2.3 您不得将账号转让、出借或以任何方式提供给他人使用，否则您应承担由此产生的全部责任。',
                  ),
                  _section(
                    isDark,
                    '三、用户行为规范',
                    '3.1 您在使用本应用时应遵守国家法律法规，不得利用本应用从事任何违法违规活动。\n\n'
                        '3.2 您不得利用本应用发布、传播任何违法违规、淫秽色情、暴力恐怖、诽谤骚扰、侵犯他人合法权益的内容。\n\n'
                        '3.3 您不得通过任何方式干扰或破坏本应用的正常运行，不得对本应用进行反向工程、反编译等操作。',
                  ),
                  _section(
                    isDark,
                    '四、服务内容',
                    '4.1 本应用提供路线规划、导航、位置共享、亲友绑定等功能。\n\n'
                        '4.2 本应用依赖高德地图 SDK 提供地图与导航服务，您在使用相关功能时需授权位置信息权限。\n\n'
                        '4.3 本应用有权根据业务发展需要调整、变更服务内容，或暂停、终止某项服务。',
                  ),
                  _section(
                    isDark,
                    '五、个人信息保护',
                    '5.1 我们重视您的个人信息保护。我们将按照《隐私政策》收集、使用、存储和保护您的个人信息。\n\n'
                        '5.2 您使用本应用即表示您同意我们按照《隐私政策》处理您的个人信息。\n\n'
                        '5.3 我们收集的信息包括但不限于：手机号、位置信息、照片、设备信息等，具体详见《隐私政策》。',
                  ),
                  _section(
                    isDark,
                    '六、免责声明',
                    '6.1 本应用提供的导航和位置服务仅供参考，不构成任何形式的保证。您应自行判断和承担使用这些服务的风险。\n\n'
                        '6.2 因不可抗力、系统故障、网络问题等原因导致的服务中断或数据丢失，本应用不承担责任。\n\n'
                        '6.3 本应用不对第三方通过本应用发布的内容或链接的准确性、完整性、合法性做任何保证。',
                  ),
                  _section(
                    isDark,
                    '七、知识产权',
                    '7.1 本应用的所有内容，包括但不限于文字、图片、图标、界面设计、数据编辑等，均受知识产权法保护。\n\n'
                        '7.2 未经本应用书面许可，任何人不得以任何方式复制、传播、修改、出售或利用本应用的内容。',
                  ),
                  _section(
                    isDark,
                    '八、协议变更与终止',
                    '8.1 本应用有权根据需要修改本协议，修改后的协议将在应用内公布。如您不同意修改内容，应停止使用本应用。\n\n'
                        '8.2 如您违反本协议的任何条款，本应用有权立即终止向您提供服务。\n\n'
                        '8.3 本协议的终止不影响终止前双方已产生的权利和义务。',
                  ),
                  _section(
                    isDark,
                    '九、法律适用与争议解决',
                    '9.1 本协议的订立、执行和解释适用中华人民共和国法律。\n\n'
                        '9.2 因本协议引起的或与本协议有关的任何争议，双方应友好协商解决；协商不成的，提交有管辖权的人民法院诉讼解决。',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '开发者：lxb（lxb031018@163.com）\n'
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
