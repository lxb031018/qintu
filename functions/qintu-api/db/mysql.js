/**
 * MySQL 连接池模块
 *
 * 使用 mysql2/promise 提供异步 MySQL 连接池
 */

const mysql = require('mysql2/promise');
const config = require('../config');

let pool = null;

/**
 * 获取连接池单例
 * @returns {mysql.Pool}
 */
function getPool() {
  if (!pool) {
    pool = mysql.createPool({
      host: config.DB.HOST,
      port: config.DB.PORT,
      user: config.DB.USER,
      password: config.DB.PASSWORD,
      database: config.DB.NAME,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      enableKeepAlive: true,
      keepAliveInitialDelay: 0
    });
  }
  return pool;
}

/**
 * 执行查询
 * @param {string} sql - SQL 语句
 * @param {Array} params - 参数数组
 * @returns {Promise<Array>} 查询结果
 */
async function query(sql, params = []) {
  const p = getPool();
  const [rows] = await p.execute(sql, params);
  return rows;
}

/**
 * 执行带事务的查询
 * @param {Function} callback - 事务回调，接收 connection 参数
 * @returns {Promise<any>} 事务结果
 */
async function transaction(callback) {
  const p = getPool();
  const connection = await p.getConnection();
  try {
    await connection.beginTransaction();
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

/**
 * 关闭连接池
 */
async function closePool() {
  if (pool) {
    await pool.end();
    pool = null;
  }
}

module.exports = {
  getPool,
  query,
  transaction,
  closePool
};