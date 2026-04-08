# 上线前检查清单

> 上线前让 AI 阅读此文件，逐项执行。

## 🔐 安全加固

- [ ] **auth.js**：删除所有 mock 逻辑（`mockVerificationCodes` Map），改用 CloudBase JWT 验证
- [ ] **auth.js**：Token 存储改用 Redis 或数据库（当前用内存 Map，重启即丢失）
- [ ] **middleware/auth.js**：改为验证真实 Access Token，不再信任 `X-User-OpenID` 请求头

## ⚙️ 环境配置

- [ ] 设置环境变量 `NODE_ENV=production`
- [ ] 配置短信服务：设置 `SMS_SIGN_ID` 和 `SMS_TEMPLATE_ID`
- [ ] 删除 `/api/auth/send-code` 接口中 `mock_code` 的返回

## 🧹 代码清理

- [ ] 清理代码中所有 TODO 标记
- [ ] 确认所有接口路径与后端一致（参考 `docs/guides/API_CONTRACT.md`）
