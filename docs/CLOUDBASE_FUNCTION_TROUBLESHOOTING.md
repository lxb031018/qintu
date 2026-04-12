# CloudBase 云函数部署踩坑记录

> 更新日期：2026-04-09
> 适用范围：CloudBase HTTP 云函数部署与调试

---

## 1. 云函数类型与网关配置

### 问题：FUNCTION_PARAM_INVALID 错误

**现象**：
- 云函数部署成功后，通过网关访问返回 400 错误
- 错误信息：`{"code":"FUNCTION_PARAM_INVALID","message":"FunctionType parameter is invalid..."}`

**原因**：
- 网关访问路径配置不正确
- 使用 `cloudbase service:create` 创建的网关配置可能有问题

**解决方案**：
1. 删除旧的网关访问服务：
   ```bash
   cloudbase service:delete --name <函数名>
   ```

2. 通过 CloudBase API 创建正确的网关访问：
   ```javascript
   // 使用 MCP 工具 callCloudApi
   {
     "service": "tcb",
     "action": "CreateCloudBaseGWAPI",
     "params": {
       "EnableUnion": true,
       "Path": "/qintu-api-test",
       "ServiceId": "<环境ID>",
       "Type": 6,          // 云函数类型
       "Name": "<函数名>",
       "AuthSwitch": 2,    // 2=无需鉴权
       "PathTransmission": 2,
       "EnableRegion": true,
       "Domain": "*"
     }
   }
   ```

3. 等待 30-90 秒让配置生效

**访问地址格式**：
```
https://<环境ID>.service.tcloudbase.com/<网关路径>/health
```

---

## 2. 云函数部署命令

### 正确的 CLI 命令

```bash
# 查看云函数列表
cloudbase functions:list

# 部署云函数
cloudbase functions:deploy <函数名>

# 强制重新部署（即使代码无变化）
cloudbase functions:deploy <函数名> --force

# 删除云函数
cloudbase functions:delete <函数名>

# 查看云函数详情
cloudbase functions:detail <函数名>
```

### 注意事项

- `functions:delete` 不支持 `--force` 参数
- 部署时如果检测到代码无变化，会提示是否覆盖，输入 `Yes` 即可
- 使用 `--force` 可以跳过确认直接部署

---

## 3. HTTP 云函数结构要求

### 必须的文件

1. **index.js** - 主入口文件
   ```javascript
   const express = require('express');
   const app = express();
   
   // 路由定义
   app.get('/health', (req, res) => {
     res.json({ status: 'ok' });
   });
   
   // 监听 9000 端口
   const PORT = process.env.PORT || 9000;
   const server = app.listen(PORT, () => {
     console.log(`服务已启动，监听端口: ${PORT}`);
   });
   
   // 导出 express app
   exports.main = app;
   ```

2. **scf_bootstrap** - 启动脚本（必须是这个文件名）
   ```bash
   #!/bin/bash
   exec node index.js
   ```

3. **package.json** - 依赖配置

### 关键配置

- **端口**：必须监听 `process.env.PORT` 或 `9000`
- **导出**：`exports.main = app`（导出 express app，不是函数）
- **Handler**：在 `cloudbaserc.json` 中配置为 `index.main`

---

## 4. 路由模块加载问题排查

### 问题：FUNCTION_EXECUTE_FAIL

**现象**：
- 健康检查路由正常
- 但访问业务路由时返回 500 错误

**排查步骤**：

1. **创建最小化测试路由**
   ```javascript
   // routes/api-test.js
   const express = require('express');
   const router = express.Router();
   
   router.get('/test', (req, res) => {
     res.json({ status: 'ok', message: 'API router works' });
   });
   
   module.exports = router;
   ```

2. **逐步添加模块导入**
   ```javascript
   // 在 api.js 中逐个放开路由模块
   const authRoutes = require('../routes/auth');
   // const userRoutes = require('../routes/users');  // 暂时注释
   ```

3. **添加调试日志**
   ```javascript
   // 在路由文件中添加 console.log
   console.log('[Auth] 开始加载 auth 模块...');
   
   try {
     const cloudbase = require('@cloudbase/node-sdk');
     console.log('[Auth] SDK 导入成功');
   } catch (err) {
     console.error('[Auth] SDK 导入失败:', err.message);
   }
   ```

4. **简化问题模块**
   - 如果某个模块导致问题，创建简化版本
   - 只保留核心功能，逐步添加代码定位问题

### 常见原因

- 模块导入时有同步执行的耗时操作
- SDK 初始化失败但未捕获异常
- 依赖的环境变量未配置
- 文件过大导致加载超时

---

## 5. 环境变量配置

### 必需的环境变量

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `ENV_ID` | CloudBase 环境 ID | `qintu-cloudebase-5f5bpuj13bc6467` |
| `NODE_ENV` | 运行环境 | `production` |
| `DB_HOST` | 数据库主机（如使用） | `xxx.tdsql.db.tencentcs.com` |
| `DB_PORT` | 数据库端口 | `3306` |
| `DB_USER` | 数据库用户名 | `root` |
| `DB_PASSWORD` | 数据库密码 | `***` |
| `DB_NAME` | 数据库名称 | `qintu` |

### 注意事项

- 环境变量在 CloudBase 控制台 → 云函数 → 配置中设置
- 修改环境变量后需要重新部署函数
- 敏感信息（如密码）不要提交到代码仓库

---

## 6. 调试技巧

### 本地测试

```bash
# 进入云函数目录
cd functions/qintu-api

# 安装依赖
npm install

# 本地运行
node index.js

# 测试
curl http://localhost:9000/health
```

### 云端调试

1. **查看函数日志**
   - 通过 CloudBase 控制台 → 云函数 → 日志
   - 或使用 MCP 工具 `queryFunctions` → `listFunctionLogs`

2. **添加全局错误捕获**
   ```javascript
   // 在 index.js 最开头添加
   process.on('uncaughtException', (err) => {
     console.error('[FATAL] 未捕获异常:', err.message);
     console.error('[FATAL] 堆栈:', err.stack);
     process.exit(1);
   });
   
   process.on('unhandledRejection', (reason, promise) => {
     console.error('[FATAL] 未处理的 Promise 拒绝:', reason);
   });
   ```

3. **使用测试路由逐步验证**
   - 先部署最小化版本确认基础功能正常
   - 逐步添加功能并测试

---

## 7. 部署检查清单

部署前检查：

- [ ] `scf_bootstrap` 文件存在且内容正确
- [ ] `index.js` 导出 `exports.main = app`
- [ ] 监听 `process.env.PORT` 或 `9000` 端口
- [ ] `package.json` 包含所有依赖
- [ ] 环境变量已配置
- [ ] 网关访问路径已创建
- [ ] 已等待 30-90 秒让配置生效

测试检查：

- [ ] 健康检查端点返回 200
- [ ] API 测试端点返回 200
- [ ] 业务路由可以正常访问
- [ ] 错误返回格式正确

---

## 8. 常见问题速查

| 错误代码 | 原因 | 解决方案 |
|---------|------|---------|
| `FUNCTION_PARAM_INVALID` | 网关配置错误 | 使用 `CreateCloudBaseGWAPI` 重新创建 |
| `FUNCTION_EXECUTE_FAIL` | 函数执行异常 | 检查日志，简化路由模块 |
| `FUNCTION_NOT_FOUND` | 函数不存在 | 确认函数名和环境 ID |
| `MISSING_CREDENTIALS` | 缺少认证 | 访问公开路由不需要认证 |
| `SYS_ERR` | 系统错误 | 检查代码逻辑和依赖 |

---

## 9. 重要经验总结

### DO ✅

1. **使用 CLI 部署**：`cloudbase functions:deploy` 可以正常创建和更新函数
2. **通过 API 创建网关**：使用 `CreateCloudBaseGWAPI` 而非 `service:create`
3. **保持路由模块简洁**：避免在模块加载时执行耗时操作
4. **添加调试日志**：在关键位置添加 `console.log`
5. **逐步验证**：从最小化版本开始，逐步添加功能

### DON'T ❌

1. **不要在模块顶层执行异步操作**：如数据库连接、SDK 初始化等
2. **不要忽略错误处理**：所有异步操作都应该有 try-catch
3. **不要假设环境变量存在**：提供默认值或检查
4. **不要一次部署大量变更**：小步快跑，逐步验证

---

## 10. 参考资源

- [CloudBase 云函数文档](https://docs.cloudbase.net/cloud-function/introduce)
- [CloudBase API 概览](https://cloud.tencent.com/document/product/876/34809)
- [错误码参考](https://docs.cloudbase.net/error-code/service)
- 项目文档：`docs/guides/API_CONTRACT.md`
