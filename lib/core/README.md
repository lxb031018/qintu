# Core 目录

跨模块共享的基础设施目录。

## 目录结构

```
core/
├── http/
│   ├── api_client.dart        # 统一 HTTP 客户端（基于 Dio，单例）
│   └── api_response.dart       # API 响应包装类
```

## 文件说明

| 文件 | 作用 |
|------|------|
| `http/api_client.dart` | **统一 HTTP 客户端**，基于 Dio 的单例实现。所有网络请求通过此客户端发送，已集成日志、错误处理、Token 刷新拦截器 |
| `http/api_response.dart` | API 响应包装类，统一处理成功/失败响应格式 |

## 架构规则

1. **统一 HTTP 客户端**：所有网络请求必须使用 `ApiClient`，不要引入 `http` 包
2. **单例模式**：`ApiClient` 使用私有构造函数实现单例
3. **服务职责单一**：每个服务只负责一个业务领域
4. **错误处理**：服务层抛出异常，由 Provider 或 UI 层处理

## Feature 模块 Service 层迁移

以下服务已迁移到对应 Feature 模块的 `service/` 目录：

| 原路径 | 新路径 |
|--------|--------|
| `core/location/amap_service.dart` | `features/map_navigation/service/` |
| `core/location/location_cache_service.dart` | `features/map_navigation/service/` |
| `core/navigation/amap_navigation_bridge.dart` | `features/map_navigation/service/` |
| `core/navigation/navigation_task_service.dart` | `features/map_navigation/service/` |
| `core/poi/amap_poi_service.dart` | `features/map_navigation/service/` |
| `core/poi/amap_poi_overlay.dart` | `features/map_navigation/widgets/` |
| `core/routing/amap_routing_models.dart` | `features/map_navigation/models/` |
| `core/routing/amap_routing_service.dart` | `features/map_navigation/service/` |
| `core/routing/amap_walking_service.dart` | `features/map_navigation/service/` |
| `core/routing/amap_riding_service.dart` | `features/map_navigation/service/` |
| `core/routing/amap_transit_service.dart` | `features/map_navigation/service/` |
| `core/routing/amap_route_overlay.dart` | `features/map_navigation/widgets/` |

## 依赖关系

```
ApiClient (Dio)
├── TokenRefreshInterceptor (自动刷新 Token)
└── ApiResponse (统一响应格式)
```
