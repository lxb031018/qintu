import 'package:flutter/material.dart';
import '../../config/environments/index.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../utils/ui/app_snackbar.dart';

/// 环境切换页面
///
/// 用于开发和测试阶段快速切换不同的后端环境
/// 生产环境应移除此页面或添加密码保护
class EnvironmentSwitchPage extends StatefulWidget {
  const EnvironmentSwitchPage({super.key});

  @override
  State<EnvironmentSwitchPage> createState() => _EnvironmentSwitchPageState();
}

class _EnvironmentSwitchPageState extends State<EnvironmentSwitchPage> {
  late EnvironmentType _selectedEnv;

  @override
  void initState() {
    super.initState();
    _selectedEnv = EnvironmentManager.currentType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.environmentSwitch),
        backgroundColor: _getEnvironmentColor(_selectedEnv),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 当前环境信息
          _buildCurrentEnvironmentCard(),

          const SizedBox(height: 24),

          // 环境列表
          const Text(
            AppStrings.selectEnvironment,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...EnvironmentManager.availableEnvironments.map((env) {
            final type = env['type'] as EnvironmentType;
            return _buildEnvironmentTile(type, env);
          }),

          const SizedBox(height: 24),

          // 确认按钮
          ElevatedButton.icon(
            onPressed: _selectedEnv == EnvironmentManager.currentType
                ? null
                : () => _confirmSwitch(),
            icon: const Icon(Icons.swap_horiz),
            label: const Text(AppStrings.switchEnvironment),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _getEnvironmentColor(_selectedEnv),
            ),
          ),

          const SizedBox(height: 16),

          // 提示信息
          _buildInfoCard(),
        ],
      ),
    );
  }

  /// 当前环境信息卡片
  Widget _buildCurrentEnvironmentCard() {
    return Card(
      color: _getEnvironmentColor(_selectedEnv).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                const Text(
                  AppStrings.currentEnvironment,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('环境: ${EnvironmentManager.currentName}'),
            Text('API: ${EnvironmentManager.baseUrl}'),
            Text('调试: ${EnvironmentManager.current.enableDebugLogs ? AppStrings.enabled : AppStrings.disabled}'),
          ],
        ),
      ),
    );
  }

  /// 环境选项卡片
  Widget _buildEnvironmentTile(
    EnvironmentType type,
    Map<String, dynamic> env,
  ) {
    final isSelected = type == _selectedEnv;
    final config = EnvironmentManager.availableEnvironments
        .firstWhere((e) => e['type'] == type)['config'] as EnvironmentConfig;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? _getEnvironmentColor(type).withValues(alpha: 0.1)
          : null,
      child: ListTile(
        leading: Icon(
          _getEnvironmentIcon(type),
          color: _getEnvironmentColor(type),
        ),
        title: Text(config.name),
        subtitle: Text(config.baseUrl),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.successColor)
            : null,
        onTap: () {
          setState(() {
            _selectedEnv = type;
          });
        },
      ),
    );
  }

  /// 提示信息卡片
  Widget _buildInfoCard() {
    return Card(
      color: AppColors.blue50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.blue700),
                const SizedBox(width: 8),
                const Text(
                  AppStrings.usageInstructions,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('• ${AppStrings.envSwitchWifiHint}'),
            const Text('• ${AppStrings.envSwitchRestartHint}'),
            const Text('• ${AppStrings.envSwitchProdHint}'),
          ],
        ),
      ),
    );
  }

  /// 确认切换环境
  void _confirmSwitch() {
    final targetEnv = EnvironmentManager.availableEnvironments
        .firstWhere((e) => e['type'] == _selectedEnv);
    final targetName = targetEnv['name'] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmSwitchEnv),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('从: ${EnvironmentManager.currentName}'),
            Text('到: $targetName'),
            const SizedBox(height: 8),
            const Text(AppStrings.switchEnvRestartHint),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              EnvironmentManager.switchEnvironment(_selectedEnv);
              Navigator.pop(context);
              _showRestartSnackBar();
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  /// 显示重启提示
  void _showRestartSnackBar() {
    AppSnackbar.showInfo(context, AppStrings.envSwitchRestartHint);
  }

  /// 获取环境颜色
  Color _getEnvironmentColor(EnvironmentType type) {
    switch (type) {
      case EnvironmentType.local:
        return AppColors.infoColor;
      case EnvironmentType.cloudbaseTest:
        return AppColors.warningColor;
      case EnvironmentType.cloudbaseProd:
        return AppColors.primaryColor;
      case EnvironmentType.production:
        return AppColors.errorColor;
    }
  }

  /// 获取环境图标
  IconData _getEnvironmentIcon(EnvironmentType type) {
    switch (type) {
      case EnvironmentType.local:
        return Icons.computer;
      case EnvironmentType.cloudbaseTest:
        return Icons.cloud_outlined;
      case EnvironmentType.cloudbaseProd:
        return Icons.cloud;
      case EnvironmentType.production:
        return Icons.public;
    }
  }
}
