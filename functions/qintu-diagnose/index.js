/**
 * 数据库连接诊断云函数
 * 用于诊断数据库连接问题
 */

const express = require('express');
const mysql = require('mysql2/promise');
const dns = require('dns').promises;

const app = express();
app.use(express.json());

// 测试 DNS 解析
async function testDNS(hostname) {
  try {
    const addresses = await dns.resolve(hostname);
    return { success: true, addresses };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

// 测试数据库连接
async function testDBConnection(config) {
  let connection;
  try {
    connection = await mysql.createConnection({
      ...config,
      connectTimeout: 5000
    });
    
    const [rows] = await connection.query('SELECT 1 as test');
    return { success: true, test: rows[0] };
  } catch (error) {
    return { success: false, error: error.message, code: error.code };
  } finally {
    if (connection) {
      await connection.end().catch(() => {});
    }
  }
}

// 诊断路由
app.get('/diagnose', async (req, res) => {
  const results = {
    timestamp: new Date().toISOString(),
    environment: {
      DB_HOST: process.env.DB_HOST || '未设置',
      DB_PORT: process.env.DB_PORT || '未设置',
      DB_USER: process.env.DB_USER || '未设置',
      DB_NAME: process.env.DB_NAME || '未设置',
      NODE_ENV: process.env.NODE_ENV || '未设置'
    },
    tests: {}
  };

  // 测试 1: DNS 解析
  if (process.env.DB_HOST) {
    results.tests.dns = await testDNS(process.env.DB_HOST);
    
    // 测试 2: 数据库连接（仅当 DNS 解析成功时）
    if (results.tests.dns.success) {
      results.tests.database = await testDBConnection({
        host: process.env.DB_HOST,
        port: parseInt(process.env.DB_PORT || '3306'),
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
      });
    } else {
      results.tests.database = {
        success: false,
        error: 'DNS 解析失败，跳过数据库连接测试',
        suggestion: '请检查数据库地址是否正确，或数据库实例是否存在'
      };
    }
  } else {
    results.tests.dns = { success: false, error: 'DB_HOST 未配置' };
    results.tests.database = { success: false, error: 'DB_HOST 未配置' };
  }

  // 建议
  results.suggestions = [];
  if (!results.tests.dns.success) {
    results.suggestions.push('1. 登录腾讯云控制台检查数据库实例是否存在');
    results.suggestions.push('2. 获取正确的数据库内网连接地址');
    results.suggestions.push('3. 确认云函数和数据库在同一 VPC 网络');
    results.suggestions.push('4. 更新 cloudbaserc.json 中的 DB_HOST 环境变量');
  }

  res.json(results);
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'qintu-diagnose'
  });
});

// 导出
exports.main = app;

// 本地测试端口
if (require.main === module) {
  app.listen(9001, () => {
    console.log('诊断服务已启动，端口: 9001');
    console.log('访问: http://localhost:9001/diagnose');
  });
}
