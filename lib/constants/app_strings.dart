/// ============================================
/// 应用字符串常量
///
/// 统一定义应用中使用的所有文字
/// 便于国际化和管理
/// ============================================
class AppStrings {
  // ==================== 应用名称 ====================

  /// 应用名称
  static const String appName = '亲途';

  /// 应用副标题
  static const String appSubtitle = '指尖即是爱的方向';

  // ==================== 启动页 ====================
  // （无独立字符串，使用 loadingText）

  // ==================== 认证页面 ====================

  /// 欢迎标题
  static const String welcomeTitle = '欢迎来到亲途';

  /// 登录副标题
  static const String loginSubtitle = '使用手机号验证码登录';

  /// 手机号输入提示
  static const String phoneHint = '请输入 11 位手机号';

  /// 手机号标签
  static const String phoneLabel = '手机号';

  /// 验证码输入提示
  static const String codeHint = '请输入 6 位验证码';

  /// 验证码标签
  static const String codeLabel = '验证码';

  /// 获取验证码按钮
  static const String getVerificationCode = '获取验证码';

  /// 登录按钮
  static const String login = '登录';

  /// 进入应用按钮
  static const String enterApp = '进入应用';

  /// 重新登录
  static const String relogin = '重新登录';

  /// 验证码已发送
  static const String codeSent = '验证码已发送至';

  /// 重新发送验证码
  static const String resendCode = '重新发送验证码';

  /// 重新发送（倒计时）
  static String resendCodeCountdown(int seconds) => '重新发送 ($seconds 秒)';

  /// 登录成功
  static const String loginSuccess = '登录成功！';

  /// 用户信息
  static const String userInfo = '用户信息';

  // ==================== 角色选择页面 ====================

  /// 角色选择标题
  static const String roleSelectionTitle = '欢迎使用亲途';

  /// 我是接收者
  static const String iAmReceiver = '我是接收者';

  /// 我是发送者
  static const String iAmSender = '我是发送者';

  /// 接收者角色描述
  static const String receiverRoleDescription = '接收导航指引，轻松出行';

  /// 发送者角色描述
  static const String senderRoleDescription = '发送导航指引，帮助他人';

  /// 角色设置提示
  static String roleSetSuccessMessage(String role) => '您已选择$role，即将进入主页';

  // ==================== 位置权限 ====================

  /// 位置权限标题
  static const String locationPermissionTitle = '需要位置权限';

  /// 位置权限说明
  static const String locationPermissionMessage = '亲途需要获取您的位置信息以提供导航服务，请授权位置权限';

  /// 位置服务未开启
  static const String locationServiceDisabled = '位置服务未开启，请在设置中开启';

  /// 开启定位
  static const String openLocation = '点击开启定位';

  /// 定位已开启
  static const String locationEnabled = '定位已开启';

  /// 定位未开启
  static const String locationDisabled = '定位未开启';

  /// 当前位置按钮
  static const String currentLocation = '当前位置';

  /// 等待导航
  static const String waitingForNavigation = '等待接收导航指引...';

  /// 暂无导航任务
  static const String noNavigationTask = '暂无导航任务';

  // ==================== 发送者端 ====================

  /// 发送者主页标题
  static const String senderHomeTitle = '发送导航指引';

  /// 输入起点
  static const String inputStartPoint = '输入起点';

  /// 输入终点
  static const String inputEndPoint = '输入终点';

  /// 起点标签
  static const String startPointLabel = '起点';

  /// 终点标签
  static const String endPointLabel = '终点';

  /// 规划路线
  static const String planRoute = '路线规划';

  // ==================== 底部导航 ====================

  /// 地图导航（顶部导航Tab）
  static const String tabRoutePlanning = '地图导航';

  /// 关系绑定（顶部导航Tab）
  static const String tabBindingRelation = '关系绑定';

  /// 设置（顶部导航Tab）
  static const String tabSettingsPage = '设置';

  /// 主页（底部导航Tab）
  static const String tabHome = '主页';

  /// 绑定（底部导航Tab）
  static const String tabBinding = '绑定';

  /// 设置（底部导航Tab）
  static const String tabSettings = '设置';

  // ==================== 主题设置 ====================

  /// 浅色主题
  static const String themeLight = '浅色';

  /// 深色主题
  static const String themeDark = '深色';

  /// 跟随系统
  static const String themeSystem = '跟随系统';

  // ==================== 设置 ====================

  /// 设置
  static const String settings = '设置';

  // ==================== 退出登录 ====================

  /// 退出
  static const String logout = '退出';

  /// 正在退出
  static const String loggingOut = '正在退出...';

  /// 退出确认标题
  static const String logoutConfirmTitle = '您确定退出嘛？>_<';

  // ==================== 错误提示 ====================

  /// 手机号格式错误
  static const String invalidPhoneNumber = '请输入正确的 11 位手机号';

  /// 验证码格式错误
  static const String invalidVerificationCode = '请输入 6 位验证码';

  /// 请先获取验证码
  static const String pleaseGetCodeFirst = '请先获取验证码';

  // ==================== 通用 ====================

  /// 确定
  static const String confirm = '确定';

  /// 取消
  static const String cancel = '取消';

  /// 加载中
  static const String loadingText = '加载中...';

  /// 下拉刷新提示
  static const String pullToRefresh = '下拉刷新';

  /// 正在获取位置
  static const String fetchingLocation = '正在获取位置...';

  /// 路线规划开发中
  static const String routePlanningInDevelopment = '路线规划功能开发中...';

  /// 路线规划标题
  static const String routePlanningTitle = '路线规划';

  /// 选择接收者
  static const String selectReceiver = '选择接收者';

  /// 选择规划对象
  static const String selectPlanningTarget = '选择规划对象';

  /// 暂无已绑定的接收者
  static const String noBoundReceivers = '暂无已绑定的接收者，请先建立绑定关系';

  /// 暂无已绑定的对象
  static const String noBoundTargets = '暂无已绑定的对象，请先建立绑定关系';

  /// 字体大小
  static const String fontSize = '字体大小';

  /// 主题设置
  static const String themeSettings = '主题设置';

  /// 浅色模式
  static const String lightMode = '浅色模式';

  /// 深色模式
  static const String darkMode = '深色模式';

  /// 跟随系统
  static const String followSystem = '跟随系统';

  /// 主题切换失败
  static const String themeSwitchFailed = '主题切换失败';

  /// 账号
  static const String account = '账号';

  /// 退出登录失败
  static const String logoutFailed = '退出登录失败';

  /// 我的绑定者
  static const String myBindings = '我的绑定者';

  /// 通知中心（按钮 tooltip）
  static const String notificationCenterTooltip = '通知中心';

  /// 显示手机号
  static const String showPhone = '显示手机号';

  /// 隐藏手机号
  static const String hidePhone = '隐藏手机号';

  /// 修改
  static const String modify = '修改';

  /// 取消请求（按钮）
  static const String cancelRequestButton = '取消请求';

  /// 请求即将过期
  static const String requestExpiringSoon = '请求即将过期';

  /// 发送于（相对时间显示，不依赖时区）
  static String sentAtText(DateTime dt) {
    // 确保使用本地时间
    final localDt = dt.isUtc ? dt.toLocal() : dt;
    return '${localDt.year}-${localDt.month.toString().padLeft(2, '0')}-${localDt.day.toString().padLeft(2, '0')} ${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
  }

  /// 发送时间（简短相对时间，适合辅助显示）
  static String sentAtShort(DateTime dt) {
    final now = DateTime.now();
    final localDt = dt.isUtc ? dt.toLocal() : dt;
    final diff = now.difference(localDt);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${localDt.month}月${localDt.day}日';
  }

  /// 设置失败
  static const String settingFailed = '设置失败';

  /// 保存角色信息失败
  static const String saveRoleFailed = '保存角色信息失败，请重试';

  /// 角色（接收者端）
  static const String roleReceiver = '接收者端';

  /// 角色（发送者端）
  static const String roleSender = '发送者端';

  // ==================== 绑定管理 ====================

  /// 刷新成功
  static const String refreshSuccess = '刷新成功';

  /// 刷新
  static const String refresh = '刷新';

  /// 解除绑定
  static const String revokeBinding = '解除绑定';

  /// 解除绑定确认
  static const String revokeBindingConfirm = '确定要解除这个绑定关系吗？';

  /// 解除绑定成功
  static const String revokeBindingSuccess = '解除绑定成功';

  /// 解除绑定失败
  static const String revokeBindingFailed = '解除绑定失败';

  /// 当前绑定
  static const String currentBinding = '当前绑定';

  /// 作为发送者
  static const String asSender = '作为发送者';

  /// 作为接收者
  static const String asReceiver = '作为接收者';

  /// 已达上限
  static const String limitReached = '已达上限';

  /// 暂无绑定关系
  static const String noBinding = '暂无绑定关系';

  /// 绑定新用户
  static const String addNewBinding = '绑定新用户';

  /// 绑定人数已达上限
  static const String bindingLimitReached = '绑定人数已达上限';

  /// 发送绑定请求
  static const String sendBindingRequest = '发送绑定请求';

  /// 对方对您的称呼
  static const String yourName = '对方对您的称呼';

  /// 对方手机号
  static const String partnerPhone = '对方手机号';

  /// 发送请求
  static const String sendRequest = '发送请求';

  /// 已与该用户建立绑定关系
  static const String bindingAlreadyExists = '已与该用户建立绑定关系';

  /// 绑定请求已发送，请等待对方确认
  static const String bindingAlreadyPending = '绑定请求已发送，请等待对方确认';

  /// 绑定请求已发送
  static const String bindingRequestSent = '绑定请求已发送，等待对方确认';

  /// 请填写对方对您的称呼
  static const String pleaseFillName = '请填写对方对您的称呼';

  /// 请填写您对对方的称呼
  static const String pleaseFillNameForPartner = '请填写您对对方的称呼';

  /// 请输入正确的手机号
  static const String invalidPhone = '请输入正确的手机号';

  /// 加载失败
  static const String loadFailed = '加载失败';

  /// 重试
  static const String retry = '重试';

  /// 切换角色
  static const String switchRole = '切换角色';

  /// 切换
  static const String switchText = '切换';

  /// 点击右侧按钮切换角色
  static const String switchRoleHint = '点击右侧按钮切换角色';

  /// 接收者
  static const String receiver = '接收者';

  /// 发送者
  static const String sender = '发送者';

  /// 备注
  static const String remark = '备注';

  /// 未知用户
  static const String unknownUser = '未知用户';

  /// 生效中
  static const String active = '生效中';

  /// 待确认
  static const String pending = '待确认';

  /// 已过期
  static const String expired = '已过期';

  /// 已解除
  static const String revoked = '已解除';

  /// 当前角色
  static const String currentRole = '当前角色';

  /// 确认切换角色提示
  static String confirmSwitchRole(String role) => '确定要切换到$role吗？';

  /// 角色未设置
  static const String roleNotSet = '未设置';

  /// 切换角色失败
  static String switchRoleFailed(String error) => '切换角色失败: $error';

  // ==================== 绑定对话框 ====================

  /// 绑定提示文本
  static const String bindingHintText = '对方将看到您填写的称呼和手机号，请确认信息准确';

  /// 您对对方的称呼（标签）
  static const String yourNameForPartner = '您对对方的称呼';

  /// 绑定请求确认提示
  static const String bindingRequestConfirmHint = '对方将在收到请求后确认，确认后即可建立绑定关系';

  // ==================== 通知和绑定请求 ====================

  /// 绑定请求通知
  static const String bindingRequests = '绑定请求';

  /// 待确认的绑定请求
  static const String pendingBindingRequests = '待确认的绑定请求';

  /// 暂无待确认请求
  static const String noPendingRequests = '暂无待确认请求';

  /// 接受绑定请求
  static const String acceptBindingRequest = '接受';

  /// 拒绝绑定请求
  static const String rejectBindingRequest = '拒绝';

  /// 接受确认对话框
  static const String acceptBindingRequestConfirm = '确定要接受这个绑定请求吗？接受后双方将建立绑定关系。';

  /// 拒绝确认对话框
  static const String rejectBindingRequestConfirm = '确定要拒绝这个绑定请求吗？';

  /// 接受成功
  static const String acceptBindingRequestSuccess = '已接受绑定请求，绑定关系已生效';

  /// 拒绝成功
  static const String rejectBindingRequestSuccess = '已拒绝绑定请求';

  /// 接受失败
  static const String acceptBindingRequestFailed = '接受失败，请重试';

  /// 拒绝失败
  static const String rejectBindingRequestFailed = '拒绝失败，请重试';

  /// 请求时间格式
  static String requestTimeAgo(String time) => '⏰ $time';

  /// 绑定请求详情提示
  static const String bindingRequestDetailHint = '对方希望通过此绑定关系与您建立连接，接受后对方将能够与您共享位置信息';

  // ==================== 通知中心 ====================

  /// 通知中心
  static const String notificationCenter = '通知中心';

  /// 收到的请求
  static const String receivedRequests = '收到请求';

  /// 发出的请求
  static const String sentRequests = '发出请求';

  /// 被拒绝
  static const String rejectedRequests = '被拒绝';

  /// 暂无收到的请求
  static const String noReceivedRequests = '暂无收到请求';

  /// 暂无发出的请求
  static const String noSentRequests = '暂无发出请求';

  /// 暂无被拒绝的请求
  static const String noRejectedRequests = '暂无被拒绝的请求';

  /// 取消请求
  static const String cancelRequest = '取消请求';

  /// 确认取消请求
  static const String confirmCancelRequest = '确定要取消这个绑定请求吗？';

  /// 不取消
  static const String notCancel = '不取消';

  /// 确认取消
  static const String confirmCancel = '确认取消';

  /// 已取消请求
  static const String requestCancelled = '已取消请求';

  /// 取消失败
  static const String cancelRequestFailed = '取消失败';

  /// 等待对方确认
  static const String waitingForConfirmation = '等待对方确认';

  /// 对方已拒绝
  static const String requestRejected = '对方已拒绝';

  /// 已过期
  static const String requestExpired = '已过期';

  /// 已绑定
  static const String requestActive = '已绑定';

  /// 未知状态
  static const String unknownStatus = '未知状态';

  /// 不足 1 小时
  static const String lessThanOneHour = '不足 1 小时';

  /// 小时后过期
  static String hoursUntilExpire(int hours) => '$hours小时后过期';

  /// 天后过期
  static String daysUntilExpire(int days) => '$days天后过期';

  /// 发送于
  static String sentAt(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ==================== 环境切换 ====================

  /// 环境切换（页面标题）
  static const String environmentSwitch = '环境切换';

  /// 选择环境
  static const String selectEnvironment = '选择环境';

  /// 切换环境（按钮）
  static const String switchEnvironment = '切换环境';

  /// 当前环境
  static const String currentEnvironment = '当前环境';

  /// 使用说明
  static const String usageInstructions = '使用说明';

  /// 确认切换环境
  static const String confirmSwitchEnv = '确认切换环境';

  /// 切换后需要重启 App 才能生效
  static const String switchEnvRestartHint = '切换后需要重启 App 才能生效';

  /// 环境已切换，请重启 App 生效
  static const String envSwitchRestartHint = '环境已切换，请重启 App 生效';

  /// 本地环境需要电脑和手机在同一 WiFi
  static const String envSwitchWifiHint = '本地环境需要电脑和手机在同一 WiFi';

  /// 生产环境上线前应移除本页面
  static const String envSwitchProdHint = '生产环境上线前应移除本页面';

  /// 开启
  static const String enabled = '开启';

  /// 关闭
  static const String disabled = '关闭';

  /// 请输入起点和终点
  static const String pleaseFillRoute = '请输入起点和终点';

  /// 取消失败（日志用）
  static const String cancelFailedLog = '取消失败';

  // ==================== 首页提示 ====================

  /// 双击设置提示
  static const String doubleTapSettingsHint = '💡 若初次使用本APP建议双击"设置"';
}
