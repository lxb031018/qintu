# 亲途 (Qintu) 技术文档索引

> 本目录包含亲途项目的所有技术文档，按照开发阶段和用途分类管理。

***

## 📖 文档分类

### 🚀 项目概览

| 文档                                          | 说明            | 适用人员 |
| ------------------------------------------- | ------------- | ---- |
| [项目总览](README_PROJECT.md)                | 项目简介、功能列表、技术栈 | 所有人员 |

***

### 🏗️ 架构与设计

| 文档                                                     | 说明                                | 适用人员        |
| ------------------------------------------------------ | --------------------------------- | ----------- |
| [前端开发规范](architecture/FRONTEND_DEVELOPMENT.md)      | 前端开发最高指导原则（合并版） | 所有开发人员 |
| [项目架构](architecture/PROJECT_ARCHITECTURE.md)          | 项目架构、角色设计、命名规范、重构记录 | 开发人员 |
| [架构优化总结](architecture/ARCHITECTURE_OPTIMIZATION.md)   | Provider 状态管理、架构优化过程              | 架构师、开发      |
| [架构解耦计划](architecture/ARCHITECTURE_DECOUPLING_PLAN.md) | 当前架构分析、重构计划、Clean Architecture 设计 | 架构师、开发 Lead |
| [绑定人数限制](features/binding_limits.md)                   | 绑定规则、API 说明、测试方法                  | 开发、测试       |

***

### 📝 开发指南

#### 资源引用

| 文档                                                  | 说明              | 适用人员    |
| --------------------------------------------------- | --------------- | ------- |
| [资源引用规范](guides/RESOURCE_REFERENCE.md)           | 字符串、颜色、常量等资源引用说明 | 所有开发人员 |

#### 认证与登录

| 文档                                                  | 说明              | 适用人员    |
| --------------------------------------------------- | --------------- | ------- |
| [CloudBase 认证配置](guides/CLOUDBASE_AUTH_CONFIG.md) | CloudBase 认证配置说明 | 开发、运维   |
| [手机号登录设置](guides/AUTH_SETUP.md)                  | 手机号验证码登录配置指南   | 开发、测试   |
| [开发模式](guides/DEV_MODE.md)                         | 模拟登录、快速查看页面指南 | 开发人员 |

#### 日志系统

| 文档                                        | 说明                 | 适用人员   |
| ----------------------------------------- | ------------------ | ------ |
| [日志使用指南](guides/LOGGER_GUIDE.md)          | Logger 模块 API、使用示例 | 所有开发人员 |
| [日志重构总结](summaries/LOGGER_REFACTORING.md) | 日志模块重构过程、新增功能      | 开发人员   |

#### 状态管理

| 文档                                                       | 说明              | 适用人员 |
| -------------------------------------------------------- | --------------- | ---- |
| [BindingProvider 使用指南](guides/BINDING_PROVIDER_USAGE.md) | 绑定状态管理 API、示例代码 | 前端开发 |

#### 功能模块

| 文档                                                  | 说明              | 适用人员    |
| --------------------------------------------------- | --------------- | ------- |
| [BindingTab 功能说明](features/BINDING_TAB_FEATURES.md) | 绑定管理页面功能列表、界面结构 | 前端开发、测试 |

***

### 🧪 测试文档

| 文档                                           | 说明                    | 适用人员 |
| -------------------------------------------- | --------------------- | ---- |
| [测试日志验证指南](testing/TEST_LOG_VERIFICATION.md) | 9 个测试场景、预期日志输出、验证检查清单 | 测试人员 |
| [前端测试记录](testing/FRONTEND_TEST_RECORD.md)    | 测试清单、问题记录、测试报告模板      | 测试人员 |
| [绑定功能测试指南](testing/BINDING_TEST_GUIDE.md)    | 绑定流程测试步骤、测试数据示例       | 测试人员 |

***

### 📦 部署文档

| 文档                                      | 说明                | 适用人员  |
| --------------------------------------- | ----------------- | ----- |
| [部署指南](guides/DEPLOYMENT_GUIDE.md)      | 云函数部署、数据库初始化、环境配置 | 运维、开发 |
| [快速部署步骤](operations/DEPLOY_STEPS.md)    | 精简版部署清单、验证步骤      | 运维、开发 |
| [故障排查指南](operations/TROUBLESHOOTING.md) | 常见问题诊断、解决步骤       | 运维、开发 |

***

### 📊 阶段总结

| 文档                                                  | 说明            | 阶段   |
| --------------------------------------------------- | ------------- | ---- |
| [实现总结](summaries/IMPLEMENTATION_SUMMARY.md)      | 完成度总结、待实现模块   | 阶段 1 |
| [阶段 2 总结](summaries/PHASE2_SUMMARY.md)              | 业务字符串解耦       | 阶段 2 |
| [绑定功能完成总结](summaries/BINDING_COMPLETION_SUMMARY.md) | 绑定功能开发完成总结    | 功能开发 |
| [编译错误修复总结](summaries/FIX_SUMMARY.md)                | 132 个编译错误修复过程 | 代码质量 |
| [重构与修复总结 2026-04-05](summaries/REFACTORING_AND_FIXES_20260405.md) | 项目重构、问题修复、主题适配 | 开发人员 |

***

## 🗂️ 文档结构

```
docs/
├── README.md                          # 本文档（文档索引）
├── README_PROJECT.md                  # 项目总览
│
├── architecture/                      # 🏗️ 架构与设计
│   ├── FRONTEND_DEVELOPMENT.md        # 前端开发规范（合并版，最高指导原则）
│   ├── PROJECT_ARCHITECTURE.md        # 项目架构（角色设计、命名规范）
│   ├── ARCHITECTURE_OPTIMIZATION.md   # 架构优化总结
│   ├── ARCHITECTURE_DECOUPLING_PLAN.md# 架构解耦计划
│   └── flutter_implementation.md      # Flutter 实现文档（待合并）
│
├── guides/                            # 📝 开发指南
│   ├── CLOUDBASE_AUTH_CONFIG.md       # CloudBase 认证配置
│   ├── AUTH_SETUP.md                  # 手机号登录设置指南
│   ├── DEV_MODE.md                    # 开发模式使用指南
│   ├── LOGGER_GUIDE.md                # 日志使用指南
│   └── BINDING_PROVIDER_USAGE.md      # BindingProvider 使用指南
│
├── features/                          # 🧩 功能模块
│   ├── BINDING_TAB_FEATURES.md        # BindingTab 功能说明
│   └── binding_limits.md              # 绑定人数限制
│
├── testing/                           # 🧪 测试文档
│   ├── TEST_LOG_VERIFICATION.md       # 测试日志验证指南
│   ├── FRONTEND_TEST_RECORD.md        # 前端测试记录
│   └── BINDING_TEST_GUIDE.md          # 绑定功能测试指南
│
├── operations/                        # 📦 运维部署
│   ├── DEPLOY_STEPS.md                # 快速部署步骤
│   └── TROUBLESHOOTING.md             # 故障排查指南
│
├── summaries/                         # 📊 阶段总结
│   ├── IMPLEMENTATION_SUMMARY.md      # 实现总结
│   ├── PHASE2_SUMMARY.md              # 阶段 2 总结
│   ├── BINDING_COMPLETION_SUMMARY.md  # 绑定功能完成总结
│   ├── FIX_SUMMARY.md                 # 编译错误修复总结
│   ├── LOGGER_REFACTORING.md          # 日志重构总结
│   └── REFACTORING_AND_FIXES_20260405.md # 重构与修复总结（合并版）
│
└── archive/                           # 📁 历史归档
    ├── DOCUMENT_ORGANIZATION_PLAN.md  # 文档整理计划（已完成）
    ├── DEPLOY_GUIDE.md                # 旧版部署指南
    ├── INTERACTION_FLOWS.md           # 交互流程
    ├── REQUIREMENTS_AND_DESIGN.md     # 需求与设计
    └── WIREFRAMES.md                  # 线框图
```

***

## 📝 文档规范

### 命名规范

| 类型       | 格式                          | 示例                                |
| -------- | --------------------------- | --------------------------------- |
| **指南类**  | `*_GUIDE.md`                | `LOGGER_GUIDE.md`                 |
| **总结类**  | `*_SUMMARY.md`              | `BINDING_COMPLETION_SUMMARY.md`   |
| **计划类**  | `*_PLAN.md`                 | `ARCHITECTURE_DECOUPLING_PLAN.md` |
| **测试类**  | `TEST_*.md` 或 `*_TEST_*.md` | `TEST_LOG_VERIFICATION.md`        |
| **功能说明** | `*_FEATURES.md`             | `BINDING_TAB_FEATURES.md`         |

### 文档模板

新建文档时应包含以下基本信息：

```markdown
# 文档标题

> 简要说明文档用途和适用范围。

## 📋 目录

- [概述](#概述)
- [详细说明](#详细说明)
- [使用示例](#使用示例)
- [注意事项](#注意事项)

## 概述

简要说明文档目的、适用人员、前置知识。

## 详细说明

详细内容说明，使用表格、代码块等提高可读性。

## 使用示例

提供完整的代码示例或使用流程。

## 注意事项

列出使用时需要注意的关键点。
```

***

## 🔄 文档维护

### 更新频率

| 文档类型     | 更新时机     |
| -------- | -------- |
| **架构文档** | 架构变更时    |
| **开发指南** | 新功能开发完成后 |
| **测试文档** | 每次测试后    |
| **部署文档** | 环境/配置变更时 |
| **阶段总结** | 每个阶段完成后  |

### 文档负责人

- **架构文档**: 架构师 / 开发 Lead
- **开发指南**: 功能开发者
- **测试文档**: 测试人员 / 功能开发者
- **部署文档**: 运维 / 开发 Lead

***

## 📚 外部文档

以下文档位于项目其他位置：

| 文档             | 位置                                        | 说明          |
| -------------- | ----------------------------------------- | ----------- |
| **云函数 API 文档** | `functions/qintu-api/README.md`           | 后端 API 接口文档 |
| **数据库文档**      | `database/README.md`                      | 数据库表结构、部署指南 |
| **快速部署步骤**     | `docs/operations/DEPLOY_STEPS.md`         | 精简版部署清单     |
| **项目总览**       | `README_PROJECT.md` (根目录)                 | 项目简介、功能列表   |
| **项目需求与设计**    | `docs/archive/REQUIREMENTS_AND_DESIGN.md` | 完整项目需求与技术设计 |

***

**最后更新**: 2026-04-04
**文档版本**: v2.0.0
**维护人员**: 开发团队
