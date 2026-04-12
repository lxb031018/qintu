/**
 * 操作日志辅助模块
 *
 * 用于记录关键操作，便于审计和排查问题
 * 使用 RESTful API 写入 operation_logs 表
 */

const { insertTable } = require('./database');

/**
 * 记录操作日志
 *
 * @param {Object} options - 日志选项
 * @param {string} options.userOpenid - 操作用户的 openid
 * @param {string} options.action - 操作类型（如：CREATE_BINDING, CONFIRM_BINDING 等）
 * @param {string} [options.targetType] - 目标类型（如：'binding', 'task', 'location'）
 * @param {string} [options.targetId] - 目标 ID
 * @param {Object} [options.details] - 操作详情
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
    const logData = {
      user_openid: userOpenid,
      action: action,
      target_type: targetType,
      target_id: targetId ? String(targetId) : null,
      details: details ? JSON.stringify(details) : null,
      ip_address: ipAddress,
      user_agent: userAgent,
      created_at: new Date().toISOString().slice(0, 19).replace('T', ' ')
    };

    await insertTable('operation_logs', logData);
  } catch (err) {
    // 日志记录失败不应影响主流程，降级到 console.log
    console.error('[OperationLog] 写入数据库失败，降级到 console.log:', err.message);
    console.log('[OperationLog]', JSON.stringify({
      userOpenid, action, targetType, targetId, details, ipAddress, userAgent,
      timestamp: new Date().toISOString()
    }));
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
