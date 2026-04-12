# Router 目录

路由配置，使用 GoRouter 进行声明式路由管理。

## 目录结构

```
router/
└── app_router.dart    # GoRouter 路由配置（路由守卫、redirect 逻辑）
```

## 文件说明

| 文件 | 作用 |
|------|------|
| `app_router.dart` | GoRouter 路由配置，定义所有页面路由、路由守卫、自动重定向逻辑 |

## 路由配置

```dart
// 路由定义示例
final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    // 未登录重定向到登录页
    if (!auth.isLoggedIn) {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => AuthPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
  ],
);
```

## 路由守卫

- **认证守卫**：未登录用户访问受保护页面时重定向到登录页
- **角色守卫**：根据用户角色（Sender/Receiver）限制访问
- **初始化守卫**：应用初始化完成前显示启动页

## 使用方式

```dart
// 命名路由跳转
context.go('/settings');
context.push('/binding/${binding.id}');

// 传递参数
context.push('/user', extra: userData);

// 在 Provider 中跳转
GoRouter.of(context).go('/home');
```

## 规范

- 所有路由定义集中在 `app_router.dart`，避免分散
- 使用路径参数（如 `/user/:id`）传递简单数据
- 使用 `extra` 参数传递复杂对象
- 路由守卫逻辑保持在 `redirect` 中，避免在页面内重复检查
