/**
 * 亲途 (qintu) - 后端 API 云函数
 * 
 * 功能：
 * 1. 用户管理（注册、登录、信息查询）
 * 2. 绑定关系管理（生成绑定码、确认绑定、解绑）
 * 3. 导航任务管理（创建任务、接受任务、完成任务、取消任务）
 * 4. 实时位置共享（上传位置、查询位置）
 * 
 * 运行环境：CloudBase HTTP Function
 * 监听端口：9000
 */

const express = require('express');
const cors = require('cors');
const apiRoutes = require('./routes/api');

const app = express();

// 中间件配置
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 请求日志中间件
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// API 路由
app.use('/api', apiRoutes);

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'qintu-api'
  });
});

// 404 处理
app.use((req, res) => {
  res.status(404).json({
    code: 'NOT_FOUND',
    message: '接口不存在'
  });
});

// 全局错误处理
app.use((err, req, res, next) => {
  console.error('Server Error:', err);
  res.status(500).json({
    code: 'SYS_ERR',
    message: process.env.NODE_ENV === 'production' 
      ? '服务器内部错误' 
      : err.message
  });
});

// CloudBase HTTP Function 必须监听 9000 端口
const PORT = process.env.PORT || 9000;

// 快速启动，不等待数据库连接
const server = app.listen(PORT, () => {
  console.log(`✅ qintu-api 服务已启动，监听端口: ${PORT}`);
  console.log(`📍 健康检查: http://localhost:${PORT}/health`);
});

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('收到 SIGTERM 信号，正在关闭服务器...');
  server.close(() => {
    console.log('服务器已关闭');
  });
});

// 导出云函数入口（事件函数使用）
exports.main = app;
