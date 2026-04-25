/**
 * 亲途 (qintu) - 后端 API 云函数入口
 *
 * 架构说明：
 * - index.js 仅负责服务启动
 * - 业务逻辑已迁移至 src/ 目录
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

const app = require('./app');
const config = require('./config');

const PORT = config.SERVER.PORT || process.env.PORT || 9000;

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ qintu-api 服务已启动，监听端口: ${PORT}`);
  console.log(`📍 健康检查: http://localhost:${PORT}/health`);
  console.log(`🌐 局域网访问: http://0.0.0.0:${PORT}`);
});

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('收到 SIGTERM 信号，正在关闭服务器...');
  server.close(() => console.log('服务器已关闭'));
});

// 导出云函数入口
exports.main = app;
