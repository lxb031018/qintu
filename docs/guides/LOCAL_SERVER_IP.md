# 本地服务器 WiFi IP 配置指南

> WiFi IP 变化导致 App 无法连接后端？一篇文档解决所有问题。

---

## 问题现象

Flutter App 报错：
```
HTTP 客户端异常: DioException [connection timeout]
请求超时，请检查网络连接
```

服务器日志正常（`curl localhost:9000` 秒回），但手机/平板无法访问。

**根本原因**：PC 的 WiFi IP 与 App 配置的 IP 不一致。

---

## 快速修复（3 步）

### Step 1：获取 PC 当前 WiFi IP

打开**命令提示符**（Win+R → 输入 `cmd` → 回车）：

```cmd
netsh wlan show interfaces
```

找到 `IPv4 地址`，例如：

```
IPv4 地址 . . . . . . . . . . . . : 192.168.126.106
```

### Step 2：更新 Flutter 配置

编辑 `.env.local`（**不会提交到 git，本地专用**）：

```
D:\AllCodes\qintu\.env.local
```

```env
LOCAL_SERVER_IP=192.168.126.106
LOCAL_SERVER_PORT=9000
```

> 如果 `.env.local` 不存在，创建它并写入上述内容。
>
> **注意**：`.env.local` 已在 `.gitignore` 中，不会被 git 跟踪，不会意外提交到仓库。

### Step 3：重启 Flutter App

```bash
flutter clean && flutter run
```

---

## 根本解决：设置固定 WiFi IP

WiFi IP 每次变化的原因是路由器使用 DHCP 动态分配。以下两种方法可以彻底解决这个问题。

### 方法 A：PC 网卡设置静态 IP（推荐）

**步骤 1**：查看当前网关

```cmd
ipconfig | findstr "默认网关"
```

例如：`192.168.126.1`

**步骤 2**：设置静态 IP

1. 设置 → 网络 → WiFi → **管理已知网络**
2. 点击你的 WiFi → **属性**
3. 改为**手动**
4. 填写：
   - IP 地址：`192.168.126.100`（同网段任意未占用地址）
   - 子网前缀长度：`24`（即 `255.255.255.0`）
   - 默认网关：填 Step 1 查到的网关
   - 首选 DNS：`8.8.8.8`

**步骤 3**：更新 `.env.local`

```env
LOCAL_SERVER_IP=192.168.126.100
```

---

### 方法 B：路由器 DHCP 静态绑定

在路由器后台（通常 `192.168.126.1`）：

1. 找到 **DHCP 静态分配 / IP 绑定** 功能
2. 找到 PC 的 MAC 地址（`netsh wlan show interfaces` 中的 `物理地址`）
3. 绑定到一个固定 IP（如 `192.168.126.100`）

不同路由器界面不同，具体请搜索你的路由器型号 + "DHCP 静态绑定"。

---

## 手机无法访问？排查清单

| 检查项 | 操作 |
|---|---|
| PC 和手机在同一 WiFi | 确认两台设备连的是同一个 WiFi |
| PC 的 WiFi IP 变了 | 重新运行 `netsh wlan show interfaces` 确认 |
| `.env.local` 配置正确 | 确认 `LOCAL_SERVER_IP` 是 Step 1 查到的 IP |
| PC 防火墙阻止 | 允许 `node.exe` 通过防火墙，或临时关闭防火墙 |
| 手机能否访问 PC | 手机浏览器打开 `http://<PC_IP>:9000/health` |
| 后端服务在运行 | PC 浏览器打开 `http://localhost:9000/health` |

### 手机浏览器测试

```
http://192.168.126.106:9000/health
```

预期响应：
```json
{"status":"ok","timestamp":"2026-...","service":"qintu-api"}
```

如果手机浏览器打不开，但 PC 浏览器正常 → **防火墙或 IP 问题**。

---

## 常见问题

**Q：为什么 `.env.local` 不会被 git 提交？**

A：因为 `.gitignore` 里已经排除了它。配置写在 `.env.local`，团队成员各自维护自己的本地 IP，互不影响。

**Q：能否直接改 `.env`？**

A：可以，但不推荐。`.env` 会被 git 跟踪，提交后可能覆盖队友的配置。

**Q：端口 9000 被占用怎么办？**

A：修改后端 `functions/qintu-api/index.js` 中的端口，同时更新 `.env.local` 中的 `LOCAL_SERVER_PORT`。

**Q：热点能否替代 WiFi？**

A：可以，但热点本身也会分配 IP，同样需要确认两台设备在同一网段。用热点时也需要遵循本文的 IP 排查步骤。
