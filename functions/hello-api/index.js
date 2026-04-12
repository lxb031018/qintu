/**
 * Hello World 测试云函数
 * 用于验证 CloudBase HTTP 云函数的基本工作流程
 */

const express = require('express');
const cors = require('cors');

const app = express();

// 中间件
app.use(cors());
app.use(express.json());

// Hello World 路由
app.get('/hello', (req, res) => {
  res.json({
    message: 'Hello World!',
    timestamp: new Date().toISOString(),
    env: process.env.NODE_ENV || 'development'
  });
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// 监听 9000 端口（CloudBase 要求）
const PORT = process.env.PORT || 9000;
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Hello API 服务已启动，监听地址: 0.0.0.0:${PORT}`);
});

// 导出云函数入口
exports.main = app;
