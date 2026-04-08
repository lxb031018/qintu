# 亲途 (Qintu) 技术文档索引

> 本文档为 AI 辅助开发提供指南，包含项目架构、开发规范和功能说明。

***

## 📖 文档分类

### 🚀 项目概览

| 文档 | 说明 |
|------|------|
| [项目总览](README_PROJECT.md) | 项目简介、功能列表、技术栈 |

### 🏗️ 架构

| 文档 | 说明 |
|------|------|
| [前端开发规范](architecture/FRONTEND_DEVELOPMENT.md) | 前端开发最高指导原则 |
| [项目架构](architecture/PROJECT_ARCHITECTURE.md) | 功能模块结构、角色架构、命名规范 |

### 📝 开发指南

| 文档 | 说明 |
|------|------|
| [CloudBase 认证配置](guides/CLOUDBASE_AUTH_CONFIG.md) | CloudBase 认证配置 |
| [手机号登录设置](guides/AUTH_SETUP.md) | 手机号验证码登录配置 |
| [开发模式](guides/DEV_MODE.md) | 模拟登录、快速查看页面 |
| [日志使用指南](guides/LOGGER_GUIDE.md) | Logger 模块 API 和使用示例 |
| [BindingProvider 使用指南](guides/BINDING_PROVIDER_USAGE.md) | 绑定状态管理 API |
| [资源引用规范](guides/RESOURCE_REFERENCE.md) | 字符串、颜色、常量等资源引用 |
| [模块化组件](guides/MODULAR_COMPONENTS.md) | 工具模块用法 |
| [手机号脱敏](guides/PHONE_MASK_USAGE.md) | 手机号脱敏模块 |

### 🧩 功能说明

| 文档 | 说明 |
|------|------|
| [BindingTab 功能](features/BINDING_TAB_FEATURES.md) | 绑定管理页面功能列表 |
| [绑定人数限制](features/binding_limits.md) | 绑定规则和限制 |

### 🧪 测试

| 文档 | 说明 |
|------|------|
| [测试指南](testing/TEST_GUIDE.md) | 绑定功能测试步骤 + 日志验证 + 检查清单 |

### 📦 部署

| 文档 | 说明 |
|------|------|
| [部署指南](operations/DEPLOY_GUIDE.md) | 云函数部署 + 数据库初始化 + 故障排查 |

### ✅ 上线前

| 文档 | 说明 |
|------|------|
| [检查清单](CHECKLIST.md) | 上线前安全加固和环境配置清单 |

***

## 🗂️ 文档结构

```
docs/
├── README.md                          # 本文档（文档索引）
├── README_PROJECT.md                  # 项目总览
│
├── architecture/                      # 🏗️ 架构
│   ├── FRONTEND_DEVELOPMENT.md        # 前端开发规范
│   └── PROJECT_ARCHITECTURE.md        # 项目架构
│
├── guides/                            # 📝 开发指南
│   ├── CLOUDBASE_AUTH_CONFIG.md
│   ├── AUTH_SETUP.md
│   ├── DEV_MODE.md
│   ├── LOGGER_GUIDE.md
│   ├── BINDING_PROVIDER_USAGE.md
│   ├── RESOURCE_REFERENCE.md
│   ├── MODULAR_COMPONENTS.md
│   └── PHONE_MASK_USAGE.md
│
├── features/                          # 🧩 功能说明
│   ├── BINDING_TAB_FEATURES.md
│   └── binding_limits.md
│
├── testing/                           # 🧪 测试
│   └── TEST_GUIDE.md
│
└── operations/                        # 📦 部署
    └── DEPLOY_GUIDE.md
```

***

**最后更新**: 2026-04-07
