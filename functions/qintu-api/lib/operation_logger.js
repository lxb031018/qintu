/**
 * 操作日志辅助模块
 *
 * 用于记录关键操作，便于审计和排查问题
 */

const { query } = require('./database');

/**
 * 记录操作日志
 *
 * @param {Object} options - 日志选项
 * @param {string} options.userOpenid - 操作用户的 openid
 * @param {string} options.action - 操作类型（如：CREATE_BINDING, CONFIRM_BINDING 等）
 * @param {string} [options.targetType] - 目标类型（如：'binding', 'task', 'location'）
 * @param {string} [options.targetId] - 目标 ID
 * @param {Object} [options.details] - 操作详情（会被 JSON.stringify）
 * @param {string} [options.ipAddress] - 客户端 IP 地址
 * @param {string} [options.userAgent] - 客户端 User-Agent
 */
async function logOperation(options) {
  const {
    userOpenid,
    action,
    targetType = null,
    targetId = null,
    details = null,
    ipAddress = null,
    userAgent = null
  } = options;

  if (!userOpenid || !action) {
    console.error('[OperationLog] userOpenid 和 action 是必填参数');
    return;
  }

  try {
    const detailsJson = details ? JSON.stringify(details) : null;

    await query(
      `INSERT INTO operation_logs 
       (user_openid, action, target_type, target_id, details, ip_address, user_agent, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
      [userOpenid, action, targetType, targetId, detailsJson, ipAddress, userAgent]
    );
  } catch (err) {
    // 日志记录失败不应影响主流程
    console.error('[OperationLog] 记录日志失败:', err.message);
  }
}

/**
 * 批量记录操作日志
 *
 * @param {Array<Object>} logs - 日志数组
 */
async function logOperations(logs) {
  try {
    const promises = logs.map(log => logOperation(log));
    await Promise.all(promises);
  } catch (err) {
    console.error('[OperationLog] 批量记录日志失败:', err.message);
  }
}

module.exports = {
  logOperation,
  logOperations
};
