# 架构解耦计划

## ✅ 已完成的工作

### 1. 日志模块统一（完成 ✅）
- 位置：`lib/utils/logger.dart`
- 功能：
  - 统一的日志管理
  - 5 个日志级别（debug/info/warning/error/critical）
  - 预定义日志实例（Logs.auth, Logs.binding 等）
  - 文件日志支持
  - 完整的日志覆盖（BindingProvider 等）

### 2. Repository 层结构创建（完成 ✅）
- 位置：`lib/data/`
- 文件：
  - `repository_manager.dart` - 仓库管理器
  - `repositories/auth_repository.dart` - 认证仓库（占位）
  - `repositories/user_repository.dart` - 用户仓库
  - `repositories/binding_repository.dart` - 绑定仓库
  - `repositories/task_repository.dart` - 任务仓库
  - `repositories/location_repository.dart` - 位置仓库

### 3. 常量和管理规范（完成 ✅）
- 统一颜色常量：`lib/constants/app_colors.dart`
- 统一时间常量：`lib/constants/app_durations.dart`
- 统一角色常量：`lib/constants/app_roles.dart`
- 统一状态常量：`lib/constants/app_statuses.dart`
- 统一存储键：`lib/constants/storage_keys.dart`
- 统一 API 端点：`lib/constants/api_endpoints.dart`

---

## 📊 当前架构状态

### 架构分层（当前）

```
┌─────────────────────────────────────────────┐
│          Presentation Layer                  │
│  (UI + Providers)                            │
│  - screens/                                  │
│  - features/                                 │
│  - providers/ (UserProvider, BindingProvider)│
└────────────────┬────────────────────────────┘
                 │ 直接调用
                 ▼
┌─────────────────────────────────────────────┐
│          Service Layer                       │
│  - services/api_service.dart                 │
│  - services/auth_service.dart                │
│  - services/secure_storage.dart              │
│  - services/location_service.dart            │
└─────────────────────────────────────────────┘
```

### 问题
- ✅ 日志模块已统一管理
- ✅ 常量已规范化
- ⚠️ Provider 仍直接调用 Service
- ⚠️ UI 层仍有直接调用 Service 的情况

---

## 🎯 未来重构计划（阶段 3）

### 目标架构（Clean Architecture）

```
┌─────────────────────────────────────────────┐
│          Presentation Layer                  │
│  (UI + Providers/ViewModels)                 │
│  └── 依赖 → Domain Layer                     │
└────────────────┬────────────────────────────┘
                 │ 依赖
                 ▼
┌─────────────────────────────────────────────┐
│            Domain Layer (新增)                │
│  - entities/ (业务实体)                       │
│  - repositories/ (接口抽象)                   │
│  - usecases/ (业务用例)                       │
│  └── 不依赖任何外层                           │
└────────────────┬────────────────────────────┘
                 │ 依赖
                 ▼
┌─────────────────────────────────────────────┐
│             Data Layer                       │
│  - repositories/ (实现）                      │
│  - datasources/ (数据源）                     │
│  └── 实现 Domain 层的接口                     │
└─────────────────────────────────────────────┘
```

### 重构步骤

#### 步骤 1：统一 HTTP 客户端
- 删除 `api_service.dart`（基于 http）
- 统一使用 `api_client.dart`（基于 Dio）
- 预计时间：1 小时

#### 步骤 2：创建 Domain 层
- 创建 `lib/domain/` 目录
- 定义 Repository 接口
- 创建 Use Case 类
- 预计时间：2 小时

#### 步骤 3：重构 Repository 实现
- 完善 `lib/data/repositories/` 中的实现
- 确保所有 Repository 实现 Domain 层接口
- 预计时间：3 小时

#### 步骤 4：重构 Provider 层
- Provider 改为调用 Use Case
- 移除直接调用 Service 的代码
- 预计时间：2 小时

#### 步骤 5：统一依赖注入
- 使用 GetIt 管理所有依赖
- 配置依赖注入规则
- 预计时间：1 小时

#### 步骤 6：测试验证
- 确保所有功能正常
- 验证日志功能完整
- 预计时间：2 小时

**总预计时间**: 11 小时

---

## 📝 当前测试建议

由于 Repository 层已创建但尚未完全集成，**当前测试阶段建议**：

1. **继续使用现有的 Provider 模式**
   - `BindingProvider` 已有完整的日志覆盖
   - 功能完整，可以正常测试

2. **日志验证**
   - 所有绑定操作都有日志
   - 成功/失败/异常都有明确日志
   - 按照 `docs/TEST_LOG_VERIFICATION.md` 进行测试

3. **后续重构**
   - 功能测试通过后，再进行架构解耦
   - 确保每次重构都有测试覆盖

---

## 📊 架构改进成果

| 项目 | 改进前 | 改进后 |
|------|--------|--------|
| **日志管理** | 分散、不一致 | ✅ 统一管理、完整覆盖 |
| **常量管理** | 硬编码、分散 | ✅ 统一定义、规范使用 |
| **颜色管理** | 魔法数字 | ✅ 统一常量 |
| **时间管理** | 硬编码 | ✅ 统一常量 |
| **角色管理** | 字符串硬编码 | ✅ 统一常量 |
| **状态管理** | 字符串硬编码 | ✅ 统一常量 |
| **存储键** | 字符串硬编码 | ✅ 统一常量 |
| **API 端点** | 分散定义 | ✅ 统一定义 |
| **Repository 层** | 无 | ✅ 结构已创建，待完善 |

---

**更新日期**: 2026-04-04  
**当前状态**: ✅ 日志和常量规范化完成，Repository 层结构已创建  
**下一步**: 功能测试 → 架构解耦重构
