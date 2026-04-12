# MCP 工具使用技巧

> 本文档记录使用 CloudBase MCP 工具过程中的实用技巧和踩坑经验。

---

## 🔑 获取云函数环境变量（含密钥）

### 场景
需要获取云函数中配置的环境变量（如 `PUBLISHABLE_KEY`、`DB_PASSWORD` 等敏感信息），但 CloudBase CLI 没有直接查询的命令。

### 方法
使用 `queryFunctions` 工具的 `getFunctionDetail` action：

```
MCP 工具：queryFunctions
action：getFunctionDetail
functionName：目标云函数名称
```

### 示例

**请求：**
```json
{
  "tool": "queryFunctions",
  "action": "getFunctionDetail",
  "functionName": "qintu-api"
}
```

**返回结果：**
在 `functionDetail.Environment.Variables` 数组中可以找到所有环境变量：

```json
{
  "Environment": {
    "Variables": [
      { "Key": "PUBLISHABLE_KEY", "Value": "eyJhbGci..." },
      { "Key": "DB_PASSWORD", "Value": "Qintu@2026!DB" },
      { "Key": "DB_HOST", "Value": "xxx.tdsql.db.tencentcs.com" },
      { "Key": "DB_NAME", "Value": "qintu" },
      ...
    ]
  }
}
```

### ⚠️ 安全提醒

- 环境变量中包含敏感信息（数据库密码、密钥等）
- 不要将这些信息硬编码到代码中
- 使用 `.env` 文件管理，并确保 `.env` 已被 `.gitignore` 忽略
- 部署时通过安全方式注入环境变量（如 CloudBase 控制台的安全变量设置）

---

## 📋 其他常用 MCP 工具

| 工具 | 常用 action | 用途 |
|------|------------|------|
| `queryFunctions` | `listFunctions` | 获取云函数列表 |
| `queryFunctions` | `getFunctionDetail` | 获取函数详情（含环境变量） |
| `queryFunctions` | `listFunctionLogs` | 查看函数日志 |
| `manageFunctions` | `updateFunctionConfig` | 更新函数配置 |
| `queryAppAuth` | `listProviders` | 查询认证提供商列表 |
| `queryAppAuth` | `getLoginConfig` | 查询登录配置 |
| `queryGateway` | `getAccess` | 查询网关访问入口 |
| `envQuery` | `list` | 查询环境列表 |
| `callCloudApi` | 自定义 | 调用任意云 API |

---

## ❌ CLI 工具限制

| 需求 | CLI 支持 | 替代方案 |
|------|---------|---------|
| 获取 Publishable Key | ❌ 不支持 | 使用 `queryFunctions` 读取云函数环境变量 |
| 查询认证配置 | ❌ `auth` 不是有效命令 | 使用 `queryAppAuth` |
| 创建 HTTP 云函数 | ❌ 无法正确创建 | 使用 CloudBase 控制台或 `manageFunctions` |

---

## 📝 更新记录

| 日期 | 内容 |
|------|------|
| 2026-04-09 | 初始版本：添加获取云函数环境变量的方法 |
