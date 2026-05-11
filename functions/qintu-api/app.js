/**
 * 应用入口
 *
 * 职责：
 * 1. 中间件配置
 * 2. 路由挂载
 * 3. 错误处理
 */

const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const config = require('./config');
const { authMiddleware } = require('./shared/middleware/auth.middleware');
const { requestIdMiddleware } = require('./shared/middleware/requestId.middleware');
const { errorHandler, notFoundHandler } = require('./shared/middleware/error.middleware');
const { getMemoryRepositories } = require('./repositories');
const routes = require('./shared/routes');

// 创建 Service 实例
const { userRepo, bindingRepo, locationRepo, taskRepo } = getMemoryRepositories();

// 导入 Service 类
const AuthService = require('./auth/services/auth.service');
const BindingService = require('./binding/services/binding.service');
const TaskService = require('./task/services/task.service');
const LocationService = require('./location/services/location.service');
const UserService = require('./user/services/user.service');

// 创建 Service 实例
const authService = new AuthService(userRepo);
const bindingService = new BindingService(bindingRepo, userRepo);
const taskService = new TaskService(bindingRepo, taskRepo);
const locationService = new LocationService(bindingRepo, locationRepo, userRepo);
const userService = new UserService(userRepo);

// 导入 RouteShare 相关模块
const RouteShareRepository = require('./route-share/repositories/route_share.memory.repository');
const RouteShareService = require('./route-share/services/route_share.service');

// 创建 RouteShare Service 实例
const routeShareRepo = new RouteShareRepository();
const routeShareService = new RouteShareService(routeShareRepo, bindingService);

// 挂载到全局供中间件访问（避免循环依赖）
global._authService = authService;

// 导出 services 供路由使用
const services = {
  authService,
  bindingService,
  taskService,
  locationService,
  userService,
  routeShareService
};

const app = express();

// ==========================================
// 1. 全局中间件配置
// ==========================================

// CORS 白名单配置
const corsOptions = {
  origin: function (origin, callback) {
    // 允许无 origin 的请求（如 curl、Postman）
    if (!origin) return callback(null, true);

    if (config.CORS.origins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      console.warn(`[CORS] 拒绝来源: ${origin}`);
      // 返回 false 而不是抛出异常，由 CORS 中间件返回标准 403 响应
      callback(null, false);
    }
  },
  credentials: config.CORS.credentials,
  optionsSuccessStatus: 200,
  // 自定义 CORS 拒绝处理
  notAllowedHandler: (req, res) => {
    if (!res.headersSent) {
      res.status(403).json({
        code: 'CORS_NOT_ALLOWED',
        message: '请求来源不在白名单中'
      });
    }
  }
};
app.use(cors(corsOptions));

// 请求 ID 中间件
app.use(requestIdMiddleware);

// 请求体大小限制
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// 全局 Rate Limiting
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  message: { code: 'RATE_LIMITED', message: '请求过于频繁，请稍后再试' }
});
app.use(globalLimiter);

// 认证接口更严格的限流
const authLimiter = rateLimit({
  windowMs: 5 * 60 * 1000,
  max: 10,
  skipSuccessfulRequests: true,
  message: { code: 'AUTH_RATE_LIMITED', message: '认证请求过于频繁，请 5 分钟后再试' }
});
app.use('/auth', authLimiter);

// 身份认证中间件
app.use(authMiddleware);

// 请求超时中间件
app.use((req, res, next) => {
  res.setTimeout(15000, () => {
    console.warn(`请求超时: ${req.method} ${req.path}`);
    if (!res.headersSent) {
      res.status(504).json({ code: 'REQUEST_TIMEOUT', message: '请求处理超时' });
    }
  });
  next();
});

// 请求日志中间件
app.use((req, res, next) => {
  const startTime = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - startTime;
    console.log(
      `[${new Date().toISOString()}] [${req.requestId}] ` +
      `${req.method} ${req.url} -> ${res.statusCode} (${duration}ms)`
    );
  });

  next();
});

// ==========================================
// 2. 路由挂载
// ==========================================

app.use(routes(services));

// ==========================================
// 3. 系统接口
// ==========================================

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'qintu-api'
  });
});

// ==========================================
// 4. 错误处理
// ==========================================

app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
