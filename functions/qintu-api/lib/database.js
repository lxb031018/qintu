/**
 * 数据库访问层
 *
 * 使用 CloudBase MySQL RESTful API 访问数据库
 * 适用于体验版（无 VPC 网络访问）
 *
 * API 文档: https://docs.cloudbase.net/http-api/mysqldb/mysql-restful-api
 */

const axios = require('axios');

// CloudBase MySQL RESTful API 配置
const ENV_ID = process.env.ENV_ID || process.env.CLOUDBASE_ENV_ID || '';
const BASE_URL = `https://${ENV_ID}.api.tcloudbasegateway.com`;
const PUBLISHABLE_KEY = process.env.PUBLISHABLE_KEY || '';

if (!PUBLISHABLE_KEY) {
  console.warn('⚠️  PUBLISHABLE_KEY 未配置，RESTful API 调用将失败');
}

if (!ENV_ID) {
  console.warn('⚠️  ENV_ID 未配置，RESTful API 调用将失败');
}

// 创建 axios 实例
const apiClient = axios.create({
  baseURL: BASE_URL,
  timeout: 10000,
  headers: {
    'Authorization': `Bearer ${PUBLISHABLE_KEY}`,
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
  }
});

// ==========================================
// 兼容旧版 query()/transaction() 接口
// ==========================================

/**
 * 执行原生 SQL 查询（兼容接口）
 *
 * ⚠️ 注意：RESTful API 不直接支持原生 SQL
 * 此接口已废弃，请直接使用 getTable/insertTable/updateTable/deleteTable
 *
 * @deprecated 使用 RESTful API 方法代替
 */
async function query(sql, params = []) {
  console.warn('⚠️  query() 已废弃，请使用 RESTful API 方法 (getTable/insertTable/updateTable/deleteTable)');
  throw new Error(
    'query() 已废弃。RESTful API 不直接支持原生 SQL，请使用:\n' +
    '- getTable(table, options) 查询\n' +
    '- insertTable(table, data) 插入\n' +
    '- updateTable(table, conditions, data) 更新\n' +
    '- deleteTable(table, conditions) 删除'
  );
}

/**
 * 执行事务（兼容接口）
 *
 * ⚠️ 注意：RESTful API 不直接支持事务
 * 此接口仅为兼容旧代码，实际直接执行回调
 *
 * @deprecated RESTful API 不支持事务
 */
async function transaction(callback) {
  console.warn('⚠️  RESTful API 不支持事务，transaction() 将直接执行回调');
  // 简化实现：直接执行回调
  return await callback({
    execute: async (sql, params = []) => {
      return await query(sql, params);
    }
  });
}

// ==========================================
// RESTful API 方法
// ==========================================

/**
 * GET - 查询表数据
 * @param {string} table - 表名
 * @param {Object} options - 查询选项
 * @param {string} options.select - 选择字段（逗号分隔）
 * @param {number} options.limit - 返回数量限制
 * @param {string} options.order - 排序（如 "id:asc"）
 * @param {Object} options.filters - 过滤条件 {fieldName: value}
 * @param {string} options.offset - 偏移量
 * @returns {Promise<Object>} 查询结果
 */
async function getTable(table, options = {}) {
  const params = {};
  if (options.select) params.select = options.select;
  if (options.limit) params.limit = String(options.limit);
  if (options.order) params.order = options.order;
  if (options.offset) params.offset = options.offset;

  // 添加过滤条件
  if (options.filters) {
    Object.entries(options.filters).forEach(([key, value]) => {
      params[key] = `eq.${value}`;
    });
  }

  try {
    const response = await apiClient.get(`/v1/rdb/rest/${table}`, { params });
    return response.data;
  } catch (err) {
    console.error(`❌ getTable 失败: ${table}`, err.response?.data || err.message);
    throw err;
  }
}

/**
 * POST - 插入数据
 * @param {string} table - 表名
 * @param {Object|Array} data - 插入的数据
 * @returns {Promise<Object>} 插入结果
 */
async function insertTable(table, data) {
  try {
    const response = await apiClient.post(`/v1/rdb/rest/${table}`, data);
    return response.data;
  } catch (err) {
    console.error(`❌ insertTable 失败: ${table}`, err.response?.data || err.message);
    throw err;
  }
}

/**
 * PATCH - 更新数据
 * @param {string} table - 表名
 * @param {Object} conditions - 过滤条件 {fieldName: value}
 * @param {Object} data - 更新的数据
 * @returns {Promise<Object>} 更新结果
 */
async function updateTable(table, conditions, data) {
  const params = {};
  Object.entries(conditions).forEach(([key, value]) => {
    params[key] = `eq.${value}`;
  });

  try {
    const response = await apiClient.patch(`/v1/rdb/rest/${table}`, data, { params });
    return response.data;
  } catch (err) {
    console.error(`❌ updateTable 失败: ${table}`, err.response?.data || err.message);
    throw err;
  }
}

/**
 * DELETE - 删除数据
 * @param {string} table - 表名
 * @param {Object} conditions - 过滤条件 {fieldName: value}
 * @returns {Promise<Object>} 删除结果
 */
async function deleteTable(table, conditions) {
  const params = {};
  Object.entries(conditions).forEach(([key, value]) => {
    params[key] = `eq.${value}`;
  });

  try {
    const response = await apiClient.delete(`/v1/rdb/rest/${table}`, { params });
    return response.data;
  } catch (err) {
    console.error(`❌ deleteTable 失败: ${table}`, err.response?.data || err.message);
    throw err;
  }
}

module.exports = {
  pool: null, // 兼容旧代码
  query,
  transaction,
  // RESTful API 方法
  getTable,
  insertTable,
  updateTable,
  deleteTable,
  apiClient,
  BASE_URL,
  ENV_ID
};
