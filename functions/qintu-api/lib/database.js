/**
 * 数据库连接配置
 * 
 * 使用 mysql2 连接 CloudBase MySQL 数据库
 * 支持连接池以提高性能
 */

const mysql = require('mysql2/promise');

// 检查是否配置了数据库
const hasDbConfig = process.env.DB_HOST && process.env.DB_HOST !== 'localhost';

// 数据库配置
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306'),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'qintu',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
  charset: 'utf8mb4'
};

let pool;

// 尝试创建连接池（异步，不阻塞）
if (hasDbConfig) {
  try {
    console.log('🔧 正在创建数据库连接池...', {
      host: dbConfig.host,
      port: dbConfig.port,
      user: dbConfig.user,
      database: dbConfig.database
    });
    
    pool = mysql.createPool(dbConfig);

    // 异步测试连接，不阻塞启动
    setImmediate(() => {
      pool.getConnection()
        .then(connection => {
          console.log('✅ MySQL 数据库连接成功');
          connection.release();
        })
        .catch(err => {
          console.error('❌ MySQL 数据库连接失败:', err.message);
          console.error('错误详情:', err);
          console.log('⚠️  请检查环境变量配置（DB_HOST, DB_USER, DB_PASSWORD）');
        });
    });
  } catch (err) {
    console.error('❌ 创建数据库连接池失败:', err.message);
  }
} else {
  console.log('⚠️  未配置数据库，数据库功能不可用');
  console.log('💡 提示：配置环境变量 DB_HOST、DB_USER、DB_PASSWORD 后可启用数据库');
}

/**
 * 执行查询
 * @param {string} sql - SQL 语句
 * @param {Array} params - 参数
 * @returns {Promise<Array>} 查询结果
 */
async function query(sql, params = []) {
  if (!pool) {
    throw new Error('数据库未配置，无法执行查询');
  }
  
  try {
    const [rows] = await pool.execute(sql, params);
    return rows;
  } catch (error) {
    console.error('数据库查询错误:', error);
    throw error;
  }
}

/**
 * 执行事务
 * @param {Function} callback - 事务回调函数，接收 connection 参数
 * @returns {Promise<any>} 事务结果
 */
async function transaction(callback) {
  if (!pool) {
    throw new Error('数据库未配置，无法执行事务');
  }
  
  const connection = await pool.getConnection();
  await connection.beginTransaction();
  
  try {
    const result = await callback(connection);
    await connection.commit();
    return result;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

module.exports = {
  pool,
  query,
  transaction
};
