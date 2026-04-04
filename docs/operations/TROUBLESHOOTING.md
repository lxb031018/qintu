# 亲途云函数部署诊断指南

## ❌ 当前问题

测试结果显示：
- 健康检查返回 404 (INVALID_PATH)
- 所有接口返回 500 (FUNCTION_EXECUTE_FAIL)

---

## 🔍 排查步骤

### 1️⃣ 检查云函数是否创建成功

**操作**：
1. 登录 [CloudBase 控制台](https://tcb.cloud.tencent.com/)
2. 选择环境：`qintu-cloudebase-5f5bpuj13bc6467`
3. 点击 **云函数**
4. 查看是否有 `qintu-api` 函数
5. 查看函数状态是否为"已部署"

**如果函数不存在**：
→ 需要重新创建并上传代码

**如果函数存在但状态异常**：
→ 查看函数日志，看具体错误

---

### 2️⃣ 检查 HTTP 访问路径

**操作**：
1. 点击 `qintu-api` 函数进入详情
2. 点击 **触发管理** 或 **HTTP 访问**
3. 查看是否有 HTTP 触发器
4. 查看访问路径是否为 `/qintu-api`

**如果没有 HTTP 访问**：
1. 点击 **创建 HTTP 访问**
2. 填写：
   - 访问路径：`/qintu-api`
   - 请求方法：`ALL`
3. 点击确定

**正确的访问地址格式**：
```
https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api
```

---

### 3️⃣ 检查环境变量配置

**操作**：
1. 云函数详情 → **函数配置**
2. 查看 **环境变量** 区域

**必须配置以下变量**：

| 变量名 | 值 | 必须？ |
|--------|-----|--------|
| `ENV_ID` | `qintu-cloudebase-5f5bpuj13bc6467` | ✅ |
| `DB_HOST` | `<MySQL 主机地址>` | ✅ |
| `DB_PORT` | `3306` | ✅ |
| `DB_USER` | `<数据库用户名>` | ✅ |
| `DB_PASSWORD` | `<数据库密码>` | ✅ |
| `DB_NAME` | `qintu` | ✅ |
| `NODE_ENV` | `production` | ✅ |

**如果未配置**：
→ 点击"编辑"添加所有环境变量

---

### 4️⃣ 查看云函数日志

**操作**：
1. 云函数详情 → **日志查询**
2. 查看最近的错误日志
3. 复制错误信息

**常见错误**：

**错误 1：模块未找到**
```
Error: Cannot find module 'express'
```
→ 原因：依赖未安装
→ 解决：重新打包上传，确保 `node_modules` 存在

**错误 2：数据库连接失败**
```
Error: connect ECONNREFUSED
```
→ 原因：DB_HOST 等配置错误，或者 DB_NAME 不对。
→ 解决：检查 MySQL 连接信息。注意：CloudBase MySQL 默认的数据库名（Schema）通常是 **`default`**，而不是 `qintu`。

**错误 3：端口错误**
```
Error: listen EADDRINUSE: address already in use :::9000
```
→ 原因：端口配置错误
→ 解决：确保代码监听 9000 端口

---

### 5️⃣ 重新上传代码

**如果上述检查都正常，尝试重新上传**：

1. 在本地重新打包：
   ```bash
   cd D:\AllCodes\qintu\functions\qintu-api
   # 确保依赖已安装
   npm install
   # 打包
   Compress-Archive -Path * -DestinationPath ..\qintu-api.zip -Force
   ```

2. 上传到控制台：
   - 删除旧函数（或创建新版本）
   - 上传新的 zip 文件

---

### 6️⃣ 测试健康检查

上传完成后，测试：

```bash
# 使用 curl 测试
curl https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/health

# 或直接在浏览器访问
# https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/health
```

**预期响应**：
```json
{
  "status": "ok",
  "timestamp": "2026-04-04T10:00:00.000Z",
  "service": "qintu-api"
}
```

---

## 🛠️ 快速修复步骤

### 方案 A：使用 CloudBase CLI 部署

```bash
# 1. 安装 CLI
npm install -g @cloudbase/cli

# 2. 登录
tcb login

# 3. 部署
cd D:\AllCodes\qintu\functions\qintu-api
tcb fn deploy qintu-api --force
```

### 方案 B：手动上传

1. 确认 `node_modules` 存在
2. 重新打包 zip
3. 在控制台删除旧函数
4. 重新创建函数并上传
5. 配置环境变量
6. 创建 HTTP 访问

---

## 📋 检查清单

完成后确认：

- [ ] 云函数状态为"已部署"
- [ ] 函数日志无错误
- [ ] 环境变量全部配置
- [ ] HTTP 访问路径已创建（/qintu-api）
- [ ] 健康检查返回 `{"status": "ok"}`

---

## 💡 需要您做的

请按照以下步骤操作：

1. **登录控制台**，检查云函数是否存在
2. **查看函数日志**，复制错误信息发给我
3. **检查 HTTP 访问** 是否已创建
4. **检查环境变量** 是否配置

告诉我您看到的具体情况，我会帮您解决！
