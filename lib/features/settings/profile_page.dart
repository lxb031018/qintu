import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart' show ImageCropper, CropAspectRatioPreset, CropStyle, AndroidUiSettings, ImageCompressFormat;
import 'package:image/image.dart' as img;
import '../../constants/app_colors.dart';
import '../../constants/app_spacings.dart';
import '../../constants/app_radii.dart';
import '../../theme/app_text_styles.dart';
import '../../config/environments/environment_manager.dart';
import 'provider/profile_page_provider.dart';

/// ============================================
/// 个人信息编辑页
///
/// 使用 Riverpod Notifier 管理状态，遵循四层架构
/// ============================================
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nicknameController = TextEditingController();
  bool _isEditingNickname = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 每次进入页面时刷新数据
    Future.microtask(() {
      ref.read(profilePageProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageState = ref.watch(profilePageProvider);
    final profile = pageState.profile;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + AppSpacings.md,
          left: AppSpacings.md,
          right: AppSpacings.md,
          bottom: AppSpacings.md,
        ),
        children: [
          // 返回按钮和标题
          _buildHeader(context, isDark),
          const SizedBox(height: AppSpacings.md),

          // 头像卡片
          _buildAvatarCard(context, isDark, profile?.avatarUrl),
          const SizedBox(height: AppSpacings.md),

          // 基本信息卡片
          _buildInfoCard(context, isDark, profile),
          const SizedBox(height: AppSpacings.md),

          // 保存按钮
          _buildSaveButton(context, isDark, pageState.isSaving),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBackground : AppColors.cardBackground,
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
              color: isDark ? AppColors.darkTextColor : AppColors.textColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '个人信息',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextColor : AppColors.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarCard(BuildContext context, bool isDark, String? avatarUrl) {
    final pageState = ref.watch(profilePageProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacings.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.cardBackground,
        borderRadius: BorderRadius.all(AppRadii.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickAndUploadAvatar(context),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppColors.darkLightTextColor.withValues(alpha: 0.3)
                        : AppColors.lightTextColor.withValues(alpha: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? Image.network(
                            EnvironmentManager.baseUrl + avatarUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 48,
                              color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 48,
                            color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
                          ),
                  ),
                ),
                if (pageState.isSaving)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBackground : AppColors.cardBackground,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击头像更换',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark, profile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacings.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.cardBackground,
        borderRadius: BorderRadius.all(AppRadii.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '基本信息',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
            ),
          ),
          const SizedBox(height: AppSpacings.md),

          // 昵称
          _buildInfoRow(
            context: context,
            isDark: isDark,
            label: '昵称',
            value: profile?.nickname ?? '',
            isEditable: true,
            isEditing: _isEditingNickname,
            controller: _nicknameController,
            onEdit: () {
              setState(() {
                _isEditingNickname = true;
                _nicknameController.text = profile?.nickname ?? '';
              });
            },
            onSave: () => _saveNickname(context),
            onCancel: () => setState(() => _isEditingNickname = false),
          ),

          // 手机号
          _buildInfoRow(
            context: context,
            isDark: isDark,
            label: '手机号',
            value: _maskPhone(profile?.phone ?? ''),
            isEditable: false,
          ),

          // 用户ID（不可编辑）
          _buildInfoRow(
            context: context,
            isDark: isDark,
            label: '用户ID',
            value: profile?.userId ?? '',
            isEditable: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String value,
    bool isEditable = false,
    bool isEditing = false,
    TextEditingController? controller,
    VoidCallback? onEdit,
    VoidCallback? onSave,
    VoidCallback? onCancel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor,
              ),
            ),
          ),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    autofocus: true,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                    ),
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkDividerColor : AppColors.dividerColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.only(bottom: 4),
                    ),
                    onSubmitted: (_) => onSave?.call(),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextColor : AppColors.textColor,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          if (isEditable)
            GestureDetector(
              onTap: isEditing
                  ? () {
                      if (controller?.text.isNotEmpty == true) {
                        onSave?.call();
                      } else {
                        onCancel?.call();
                      }
                    }
                  : onEdit,
              child: Icon(
                isEditing ? Icons.check : Icons.edit,
                size: 18,
                color: AppColors.primaryColor,
              ),
            )
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isDark, bool isSaving) {
    return ElevatedButton(
      onPressed: isSaving ? null : () => _saveAll(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 0,
      ),
      child: isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, size: 20),
                SizedBox(width: 8),
                Text(
                  '保存修改',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }

  String _maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final picker = ImagePicker();

    // 选择图片
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (image == null) return;

    // 裁剪图片
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      maxWidth: 300,
      maxHeight: 300,
      compressQuality: 70,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '裁剪头像',
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          cropStyle: CropStyle.circle,
        ),
      ],
    );

    if (croppedFile == null) return;

    // 转换为圆形 PNG（带透明角）
    final circularBytes = await _createCircularPng(croppedFile.path);
    if (circularBytes == null) return;

    // 上传并保存
    final success = await ref.read(profilePageProvider.notifier).uploadAvatarBytes(circularBytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '头像已更新' : '头像上传失败'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 将裁剪后的正方形图片转换为带透明角的圆形 PNG
  Future<Uint8List?> _createCircularPng(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final size = image.width < image.height ? image.width : image.height;
      final circular = img.Image(width: size, height: size, numChannels: 4);

      // 遍历每个像素，判断是否在圆形区域内
      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          final dx = x - size / 2;
          final dy = y - size / 2;
          final dist = dx * dx + dy * dy;
          final radius = size / 2;

          if (dist <= radius * radius) {
            // 在圆形内 - 复制像素
            final srcX = (x * image.width / size).floor();
            final srcY = (y * image.height / size).floor();
            circular.setPixel(x, y, image.getPixel(srcX, srcY));
          } else {
            // 在圆形外 - 透明
            circular.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
          }
        }
      }

      return Uint8List.fromList(img.encodePng(circular));
    } catch (e) {
      debugPrint('创建圆形头像失败: $e');
      return null;
    }
  }

  Future<void> _saveNickname(BuildContext context) async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('昵称不能为空'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await ref.read(profilePageProvider.notifier).saveNickname(nickname);
    if (success && context.mounted) {
      setState(() => _isEditingNickname = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('昵称已更新'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveAll(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('修改已保存'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}