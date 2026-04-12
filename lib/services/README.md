# Services 目录

服务层，封装业务逻辑、API 调用、第三方服务等。

## 目录结构

```
services/
├── api_client.dart                 # 统一 HTTP 客户端（基于 Dio，单例）
├── api_response.dart               # API 响应包装类
├── amap_service.dart               # 高德地图服务（定位、逆地理编码）
├── auth_api_service.dart           # 认证 API 封装
├── auth_service.dart               # 认证业务逻辑服务
├── location_cache_service.dart     # 位置缓存服务（本地存储）
├── location_service.dart           # 定位服务封装
├── secure_storage.dart             # 安全存储（FlutterSecureStorage 封装）
└── token_refresh_interceptor.dart  # Token 自动刷新拦截器（处理 401）
```

## 文件说明

| 文件 | 作用 |
|------|------|
| `api_client.dart` | **统一 HTTP 客户端**，基于 Dio 的单例实现。所有网络请求通过此客户端发送，已集成日志、错误处理、Token 刷新拦截器 |
| `api_response.dart` | API 响应包装类，统一处理成功/失败响应格式 |
| `amap_service.dart` | 高德地图服务封装，提供定位、逆地理编码、地址解析等功能 |
| `auth_api_service.dart` | 认证相关 API 调用封装（登录、注册、刷新 Token 等） |
| `auth_service.dart` | 认证业务逻辑服务，协调 API 调用和状态更新 |
| `location_cache_service.dart` | 位置缓存服务，使用本地存储缓存最近位置数据 |
| `location_service.dart` | 定位服务封装，整合系统定位和高德定位 |
| `secure_storage.dart` | 安全存储封装，使用 FlutterSecureStorage 存储 Token 等敏感数据 |
| `token_refresh_interceptor.dart` | Token 自动刷新拦截器，拦截 401 响应并自动刷新 Token |

## 架构规则

1. **统一 HTTP 客户端**：所有网络请求必须使用 `ApiClient`，不要引入 `http` 包
2. **单例模式**：`ApiClient` 使用私有构造函数实现单例
3. **服务职责单一**：每个服务只负责一个业务领域
4. **错误处理**：服务层抛出异常，由 Provider 或 UI 层处理

## 使用方式

```dart
// API 调用
final client = ApiClient.instance;
final response = await client.get('/api/users');

// 认证服务
final authApi = AuthApiService();
final result = await authApi.login(phone: '13800138000', code: '123456');

// 安全存储
await SecureStorage.instance.write(key: 'token', value: 'xxx');
final token = await SecureStorage.instance.read('token');

// 高德地图服务
final location = await AMapService().getCurrentLocation();
```

## 依赖关系

```
ApiClient (Dio)
├── TokenRefreshInterceptor (自动刷新 Token)
└── ApiResponse (统一响应格式)

AuthApiService
└── ApiClient

AuthService
├── AuthApiService
└── AuthStateManager

AMapService
└── 高德地图 SDK

LocationService
├── 系统定位
└── AMapService

SecureStorage
└── FlutterSecureStorage
```
