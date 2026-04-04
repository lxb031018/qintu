import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../config/app_config.dart';
import '../../constants/app_strings.dart';
import '../../services/location_service.dart';
import '../../utils/logger.dart';
import '../settings/settings_page.dart';

/// 接收者端主页 - 等待接收导航指引

class ReceiverHomePage extends StatefulWidget {
  final String userId;
  final String phone;
  final String accessToken;

  const ReceiverHomePage({
    super.key,
    required this.userId,
    required this.phone,
    required this.accessToken,
  });

  @override
  State<ReceiverHomePage> createState() => _ReceiverHomePageState();
}

class _ReceiverHomePageState extends State<ReceiverHomePage> with WidgetsBindingObserver {
  bool _isLocationEnabled = false;
  bool _isCheckingLocation = false; // 防止重复检查
  
  // 绑定请求相关（TODO: 后续从 Provider 获取）
  final List<Map<String, dynamic>> _pendingBindingRequests = [];

  @override
  void initState() {
    super.initState();
    // 注册生命周期观察者
    WidgetsBinding.instance.addObserver(this);
    _checkLocationStatus();
    // TODO: 加载待确认的绑定请求
    // _loadPendingBindingRequests();
  }

  @override
  void dispose() {
    // 移除生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 监听应用生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 当应用从后台恢复时（用户从设置返回），重新检查定位状态
    if (state == AppLifecycleState.resumed) {
      Logs.ui.info('应用恢复前台，重新检查定位状态');
      _checkLocationStatus();
    }
  }

  /// 检查定位状态
  Future<void> _checkLocationStatus() async {
    // 防止重复检查
    if (_isCheckingLocation) return;

    setState(() => _isCheckingLocation = true);

    try {
      final isEnabled = await LocationService.checkPermission();
      if (mounted) {
        setState(() => _isLocationEnabled = isEnabled);
        Logs.ui.info('定位状态更新: ${isEnabled ? "已开启" : "未开启"}');
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingLocation = false);
      }
    }
  }

  /// 打开定位设置
  Future<void> _openLocationSettings() async {
    final opened = await LocationService.openLocationSettings();
    if (opened) {
      Logs.ui.info('已打开定位设置页面，等待用户操作...');
      // 不在这里延迟检查，而是等用户返回时由生命周期触发
    } else {
      Logs.app.warning('打开定位设置失败');
    }
  }

  /// 处理绑定请求
  Future<void> _handleBindingRequest(Map<String, dynamic> request) async {
    // 脱敏显示手机号
    final phone = request['phone'] ?? '未知';
    final maskedPhone = _maskPhone(phone);
    final name = request['name'] ?? '未提供姓名';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('绑定请求'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('您收到一个绑定请求'),
              const SizedBox(height: 16),
              Text(
                '手机号：$maskedPhone',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('姓名：$name'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('拒绝'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确认绑定'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // TODO: 调用 API 确认绑定
      Logs.binding.info('确认绑定: $maskedPhone');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('绑定成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (result == false) {
      // TODO: 调用 API 拒绝绑定
      Logs.binding.info('拒绝绑定: $maskedPhone');
    }
  }

  /// 显示绑定请求列表
  void _showPendingBindingRequests() {
    if (_pendingBindingRequests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无待确认的绑定请求')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pendingBindingRequests.length,
          itemBuilder: (context, index) {
            final request = _pendingBindingRequests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(request['phone'] ?? '未知'),
                subtitle: Text(request['name'] ?? '未提供姓名'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleBindingRequest(request);
                      },
                      child: const Text('拒绝'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleBindingRequest(request);
                      },
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 手机号脱敏处理
  String _maskPhone(String phone) {
    if (phone.length == 11) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.textColor;
    final lightTextColor = isDark ? AppColors.darkLightTextColor : AppColors.lightTextColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 72,
        actions: [
          // 绑定请求按钮（如果有新请求显示红点）
          if (_pendingBindingRequests.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: _showPendingBindingRequests,
                  tooltip: '绑定请求',
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_pendingBindingRequests.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          // 定位开关按钮（右上角）
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: GestureDetector(
              onTap: _isCheckingLocation ? null : _openLocationSettings,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _isCheckingLocation
                      ? lightTextColor.withAlpha(77)
                      : _isLocationEnabled
                          ? AppColors.successColor.withAlpha(38)
                          : AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isCheckingLocation)
                      const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      Icon(
                        _isLocationEnabled ? Icons.location_on : Icons.location_off,
                        size: 26,
                        color: _isLocationEnabled
                            ? AppColors.successColor
                            : Colors.white,
                      ),
                    if (!_isCheckingLocation) const SizedBox(width: 10),
                    if (!_isCheckingLocation)
                      Text(
                        _isLocationEnabled
                            ? AppStrings.locationEnabled
                            : AppStrings.openLocation,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.2,
                          color: _isLocationEnabled
                              ? AppColors.successColor
                              : Colors.white,
                          fontFamily: AppConfig.fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 状态图标
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.navigation_outlined,
                  size: 80,
                  color: AppColors.primaryColor,
                ),
              ),

              const SizedBox(height: 32),

              // 提示文字
              Text(
                AppStrings.waitingForNavigation,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: AppConfig.fontFamily,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                AppStrings.noNavigationTask,
                style: TextStyle(
                  fontSize: 18,
                  color: lightTextColor,
                  fontFamily: AppConfig.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
      // 右下角设置按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            ),
          );
        },
        backgroundColor: AppColors.primaryColor.withAlpha(38),
        elevation: 2,
        icon: Icon(
          Icons.settings_outlined,
          color: AppColors.primaryColor,
          size: 24,
        ),
        label: Text(
          AppStrings.settings,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
            fontFamily: AppConfig.fontFamily,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
