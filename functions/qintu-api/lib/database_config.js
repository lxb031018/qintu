/**
 * 数据库配置选择器
 *
 * 根据环境变量 DB_MODE 决定使用哪个数据库实现：
 * - 'local': 使用内存数据库（本地开发测试）
 * - 'cloudbase': 使用 CloudBase MySQL RESTful API（生产环境）
 *
 * 默认使用 local 模式
 */

const dbMode = process.env.DB_MODE || 'local';

let database;

switch (dbMode) {
  case 'cloudbase':
    console.log('📦 使用 CloudBase 数据库');
    database = require('./database');
    break;
  case 'local':
  default:
    console.log('📦 使用本地内存数据库');
    database = require('./database_local');
    break;
}

module.exports = database;
