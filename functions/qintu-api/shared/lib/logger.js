/**
 * 操作日志辅助模块
 *
 * 用于记录关键操作，便于审计和排查问题
 * 注意：内存版不使用数据库，此模块降级为 console.log
 */

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

  // 内存版降级到 console.log
  console.log('[OperationLog]', JSON.stringify({
    userOpenid,
    action,
    targetType,
    targetId,
    details,
    ipAddress,
    userAgent,
    timestamp: new Date().toISOString()
  }));
}

/**
 * 批量记录操作日志
 *
 * @param {Array<Object>} logs - 日志数组
 */
async function logOperations(logs) {
  logs.forEach(log => logOperation(log));
}

module.exports = {
  logOperation,
  logOperations
};
