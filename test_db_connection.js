/**
 * 数据库连接测试脚本
 * 用于在本地测试数据库连接
 */

const mysql = require('mysql2/promise');

// 数据库配置（从 cloudbaserc.json 读取）
const dbConfig = {
  host: 'qintu-cloudebase-5f5bpuj13bc6467.ap-shanghai.tdsql.db.tencentcs.com',
  port: 3306,
  user: 'root',
  password: 'Qintu@2026!DB',
  database: 'qintu',
  connectTimeout: 10000
};

async function testConnection() {
  console.log('========== 数据库连接测试 ==========\n');
  console.log('正在连接数据库...');
  console.log(`主机: ${dbConfig.host}`);
  console.log(`端口: ${dbConfig.port}`);
  console.log(`用户: ${dbConfig.user}`);
  console.log(`数据库: ${dbConfig.database}\n`);

  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ 数据库连接成功！\n');

    // 测试查询
    const [rows] = await connection.query('SELECT 1 as test');
    console.log('测试查询结果:', rows);

    // 查询 users 表记录数
    const [countRows] = await connection.query('SELECT COUNT(*) as count FROM users');
    console.log('\nusers 表记录数:', countRows[0].count);

    // 查询 user_bindings 表记录数
    const [bindingRows] = await connection.query('SELECT COUNT(*) as count FROM user_bindings');
    console.log('user_bindings 表记录数:', bindingRows[0].count);

    console.log('\n✅ 数据库测试完成');
  } catch (error) {
    console.error('❌ 数据库连接失败!');
    console.error('错误代码:', error.code);
    console.error('错误信息:', error.message);
    console.error('错误详情:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n数据库连接已关闭');
    }
  }
}

testConnection();
