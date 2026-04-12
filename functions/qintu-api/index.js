/**
 * 亲途 (qintu) - 后端 API 云函数入口
 * 
 * 架构说明：
 * - index.js 仅负责服务启动、中间件挂载和路由分发
 * - 业务逻辑已拆分至 routes/ 目录下的独立模块
 * - 身份认证逻辑由 middleware/auth.js 统一处理
 */

// 全局未捕获异常处理
process.on('uncaughtException', (err) => {
  console.error('[FATAL] 未捕获异常:', err.message);
  console.error('[FATAL] 堆栈:', err.stack);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('[FATAL] 未处理的 Promise 拒绝:', reason);
});

const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const config = require('./config'); // 🌟 引入全局配置

// 🌟 引入路由模块
const apiRoutes = require('./routes/api');
const mockAuthRoutes = require('./routes/mock_auth');

// 🌟 引入中间件
const { authMiddleware } = require('./middleware/auth');
const { requestIdMiddleware } = require('./middleware/requestId');

const app = express();
const PORT = config.SERVER.PORT; // 🌟 使用配置中的端口

// ==========================================
// 1. 全局中间件配置
// ==========================================

// 🌟 CORS 白名单配置
const corsOptions = {
  origin: function (origin, callback) {
    // 允许无 origin 的请求（如 curl、Postman）
    if (!origin) return callback(null, true);

    if (config.CORS.origins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      console.warn(`[CORS] 拒绝来源: ${origin}`);
      callback(new Error(`来源 ${origin} 不在 CORS 白名单中`));
    }
  },
  credentials: config.CORS.credentials,
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

// 🌟 请求 ID 中间件（必须在最前面，后续日志都可以使用 req.requestId）
app.use(requestIdMiddleware);

// 🌟 请求体大小限制（防止 DoS 攻击）
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// 🌟 全局 Rate Limiting（默认限制）
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 分钟窗口
  max: 200, // 每窗口最多 200 个请求
  standardHeaders: true, // 返回 RateLimit-* 头
  legacyHeaders: false, // 禁用 X-RateLimit-* 头
  message: { code: 'RATE_LIMITED', message: '请求过于频繁，请稍后再试' }
});
app.use(globalLimiter);

// 🌟 认证接口更严格的限流
const authLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 分钟窗口
  max: 10, // 每窗口最多 10 次尝试（防止暴力破解）
  skipSuccessfulRequests: true, // 成功请求不计入限流
  message: { code: 'AUTH_RATE_LIMITED', message: '认证请求过于频繁，请 5 分钟后再试' }
});
app.use('/mock/auth', authLimiter);

// 🌟 身份认证中间件 (解析 OpenID 到 req.user)
app.use(authMiddleware);

// ==========================================
// 2. 路由挂载
// ==========================================

// 🌟 Mock 认证接口 (模拟 CloudBase Auth)
app.use(mockAuthRoutes);

// 🌟 业务 API 接口 (挂载在 /api 前缀下)
app.use('/api', apiRoutes);

// ==========================================
// 3. 系统接口与错误处理
// ==========================================

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'qintu-api'
  });
});

// 数据库连接测试
app.get('/test-db', async (req, res) => {
  try {
    const { query } = require('./lib/database');
    const result = await query('SELECT 1 as test');
    res.json({ status: 'ok', database: 'connected', test: result });
  } catch (error) {
    res.status(500).json({ status: 'error', database: 'disconnected', error: error.message });
  }
});

// 请求超时中间件
app.use((req, res, next) => {
  res.setTimeout(15000, () => {
    console.warn(`⏱️  请求超时: ${req.method} ${req.path}`);
    if (!res.headersSent) {
      res.status(504).json({ code: 'REQUEST_TIMEOUT', message: '请求处理超时' });
    }
  });
  next();
});

// 请求日志中间件
app.use((req, res, next) => {
  const startTime = Date.now();

  // 响应完成后记录日志
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    console.log(
      `[${new Date().toISOString()}] [${req.requestId}] ` +
      `${req.method} ${req.url} -> ${res.statusCode} (${duration}ms)`
    );
  });

  next();
});

// 404 处理
app.use((req, res) => {
  res.status(404).json({ code: 'NOT_FOUND', message: '接口不存在' });
});

// 全局错误处理
app.use((err, req, res, next) => {
  console.error('Server Error:', err);
  res.status(500).json({
    code: 'SYS_ERR',
    message: process.env.NODE_ENV === 'production' ? '服务器内部错误' : err.message
  });
});

// ==========================================
// 4. 服务启动
// ==========================================
// 如果 config 中没有 PORT，使用环境变量或默认 9000
const FINAL_PORT = PORT || process.env.PORT || 9000;

const server = app.listen(FINAL_PORT, '0.0.0.0', () => {
  console.log(`✅ qintu-api 服务已启动，监听端口: ${FINAL_PORT}`);
  console.log(`📍 健康检查: http://localhost:${FINAL_PORT}/health`);
  console.log(`🌐 局域网访问: http://0.0.0.0:${FINAL_PORT}`);
});

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('收到 SIGTERM 信号，正在关闭服务器...');
  server.close(() => console.log('服务器已关闭'));
});

// 导出云函数入口（事件函数使用）
exports.main = app;
