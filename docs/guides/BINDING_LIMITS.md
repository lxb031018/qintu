# 绑定人数限制说明

> 本文档说明绑定关系的人数限制规则。

---

## 📋 核心概念

### 双向对等绑定

```
A 发送绑定请求给 B → B 确认 → A 和 B 互相绑定
```

- 不再区分"发送者"和"接收者"角色
- 每个人都能看到所有功能
- 绑定关系是双向对等的

### 绑定状态

| 状态 | 说明 | 显示位置 |
|------|------|---------|
| pending | 等待对方确认 | 发出请求Tab |
| active | 已生效 | 绑定列表 |
| revoked | 已取消/被拒绝 | 被拒绝请求Tab |
| expired | 已过期 | 发出请求Tab |

---

## 🔒 限制规则

### 永久绑定限制

**每个用户最多绑定 5 人**

- 限制文件：`lib/constants/binding_limits.dart`
```dart
class BindingLimits {
  static const int maxBindingsPerUser = 5;
}
```

### 设计理由

- ✅ 覆盖典型家庭场景（1 个用户管理多个家庭成员）
- ✅ 避免资源过度占用（导航任务、位置上传等）
- ✅ 保证服务质量（过多绑定会导致管理混乱）

---

## 🔧 限制验证

### Flutter 端判断

```dart
// 获取 BindingProvider
final bindingProvider = context.read<BindingProvider>();

// 检查是否达到上限
if (bindingProvider.isBindingLimitReached) {
  // 禁用绑定按钮
}

// 获取当前绑定数量
final count = bindingProvider.totalBindings;
final limit = BindingLimits.maxBindingsPerUser;
```

### 达到上限时的 UI

```dart
// 绑定统计卡片显示
Text('${count}/${limit}');

// 达到上限时禁用按钮
AddBindingButton(
  provider: provider,
  onPressed: provider.isBindingLimitReached
      ? null
      : () => _controller.showPhoneBindingDialog(),
);
```

---

## 📝 待实现功能

### 限时绑定（有效期内）

- **用途**：临时绑定（如旅游团导游带团 7 天）
- **限制**：不限人数
- **状态**：待实现

### 二维码分享路线

- **用途**：一次性分享路线，无需绑定关系
- **限制**：无限制，任何人都可以扫码接受导航
- **状态**：待实现

---

## 📊 变更记录

| 日期 | 变更 |
|------|------|
| 2026-04-17 | 简化为统一限制 5 人，删除发送者/接收者区分 |

---

**最后更新**：2026-04-17
