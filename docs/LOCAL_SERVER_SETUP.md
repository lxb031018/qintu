# 本地开发服务器配置指南

> 本指南介绍如何在本地启动后端服务器，避免消耗 CloudBase 免费额度

---

## 🚀 快速启动

### 步骤 1: 启动本地服务器

**Windows:**
```bash
cd D:\AllCodes\qintu\functions\qintu-api
start-local.bat
```

或者直接运行：
```bash
cd D:\AllCodes\qintu\functions\qintu-api
npm install  # 首次运行需要
node index.js
```

**服务器将在 `http://localhost:9000` 启动**

---

### 步骤 2: 获取电脑局域网 IP

**Windows:**
```bash
ipconfig
```

找到 `IPv4 地址`，例如：`192.168.1.100`

---

### 步骤 3: 修改 Flutter 配置

编辑文件：`lib/utils/constants.dart`

```dart
// 云函数 URL（部署后替换为实际地址）
static const String cloudFunctionBaseUrl =
    'https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api-test';

// 本地开发时使用 localhost
static const String localhostBaseUrl = 'http://192.168.1.100:9000';  // 替换为你的 IP

// 是否使用本地开发服务器
static const bool useLocalServer = true;  // 改为 true 启用本地服务器
```

**重要：**
- `useLocalServer = true` 时使用本地服务器
- `useLocalServer = false` 时使用 CloudBase 云函数

---

### 步骤 4: 重新运行 Flutter 应用

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📱 手机测试

### 确保设备在同一 WiFi 网络

1. 手机和电脑必须连接同一个 WiFi
2. 手机浏览器访问 `http://192.168.1.100:9000/health` 测试是否可达

### 测试本地服务器

**电脑浏览器：**
```
http://localhost:9000/health
```

**手机浏览器：**
```
http://192.168.1.100:9000/health
```

**预期响应：**
```json
{
  "status": "ok",
  "timestamp": "2026-04-09T...",
  "service": "qintu-api"
}
```

---

## 🔧 故障排除

### 问题 1: 手机无法连接本地服务器

**检查项：**
1. ✅ 确认手机和电脑在同一 WiFi 网络
2. ✅ 确认 Windows 防火墙允许 Node.js 访问网络
3. ✅ 确认 IP 地址正确（`ipconfig` 查看）
4. ✅ 确认服务器正在运行（`node index.js` 未关闭）

**Windows 防火墙设置：**
- 首次运行 `node.exe` 时，Windows 会弹出防火墙提示
- 选择 **允许访问**（专用网络和公用网络都勾选）

### 问题 2: 依赖安装失败

```bash
cd D:\AllCodes\qintu\functions\qintu-api
npm install
```

如果速度慢，可以使用淘宝镜像：
```bash
npm install --registry=https://registry.npmmirror.com
```

### 问题 3: 端口 9000 被占用

修改 `index.js` 中的端口：
```javascript
const PORT = process.env.PORT || 9001;  // 改为其他端口
```

同时更新 Flutter 配置：
```dart
static const String localhostBaseUrl = 'http://192.168.1.100:9001';
```

---

## 💡 开发技巧

### 自动重启（可选）

安装 nodemon 实现代码修改后自动重启：

```bash
npm install -g nodemon
nodemon index.js
```

### 查看请求日志

服务器启动后，所有请求都会打印到控制台：

```
[2026-04-09T...] GET /api/bindings/my
[2026-04-09T...] POST /api/auth/send-code
...
```

### 切换云/本地服务器

只需修改一个常量即可切换：

```dart
// lib/utils/constants.dart

// 使用本地服务器（开发测试）
static const bool useLocalServer = true;

// 使用 CloudBase 云函数（生产环境）
static const bool useLocalServer = false;
```

---

## 📊 本地 vs 云端对比

| 特性 | 本地服务器 | CloudBase 云函数 |
|------|-----------|-----------------|
| **成本** | 免费 | 消耗免费额度 |
| **速度** | 快（局域网） | 取决于网络 |
| **调试** | 方便（实时日志） | 需要查日志 |
| **数据持久** | ❌ 重启丢失 | ✅ 云端存储 |
| **手机测试** | ✅ 同一 WiFi 即可 | ✅ 任何网络 |
| **多设备** | ✅ 支持 | ✅ 支持 |

---

## ✅ 检查清单

启动前确认：

- [ ] Node.js 已安装（`node -v` 检查）
- [ ] 依赖已安装（`node_modules` 目录存在）
- [ ] 服务器已启动（看到 `✅ qintu-api 服务已启动`）
- [ ] 防火墙已允许 Node.js 访问网络
- [ ] Flutter 配置已更新（`useLocalServer = true`）
- [ ] IP 地址正确（`ipconfig` 查看）

---

## 🎯 双设备测试流程

1. **启动本地服务器** - 在电脑上运行 `start-local.bat`
2. **更新 Flutter 配置** - 修改 `constants.dart` 启用本地服务器
3. **设备 A 安装运行** - 输入设备 B 的手机号发送绑定请求
4. **设备 B 安装运行** - 查看待确认请求并确认
5. **验证绑定成功** - 双方都能看到绑定关系

**注意：** 本地服务器的数据存储在内存中，重启服务器后数据会丢失。但这对于开发测试完全够用！
