/**
 * 统一消息响应工具
 *
 * 提供标准化的 API 响应格式
 */

/**
 * 成功响应
 * @param {Object} res - Express Response
 * @param {Object} data - 响应数据
 * @param {number} status - HTTP 状态码（默认 200）
 */
function success(res, data = {}, status = 200) {
  return res.status(status).json({
    code: 'SUCCESS',
    message: '操作成功',
    data
  });
}

/**
 * 错误响应
 * @param {Object} res - Express Response
 * @param {string} message - 错误消息
 * @param {string} code - 错误代码
 * @param {number} status - HTTP 状态码
 */
function error(res, message = '操作失败', code = 'OPERATION_FAILED', status = 500) {
  return res.status(status).json({
    code,
    message
  });
}

/**
 * 参数验证错误
 * @param {Object} res - Express Response
 * @param {string} message - 错误消息
 */
function validationError(res, message = '参数验证失败') {
  return error(res, message, 'INVALID_PARAM', 400);
}

/**
 * 未授权错误
 * @param {Object} res - Express Response
 * @param {string} message - 错误消息
 */
function unauthorized(res, message = '未授权访问') {
  return error(res, message, 'UNAUTHORIZED', 401);
}

/**
 * 权限错误
 * @param {Object} res - Express Response
 * @param {string} message - 错误消息
 */
function forbidden(res, message = '权限不足') {
  return error(res, message, 'FORBIDDEN', 403);
}

/**
 * 资源未找到
 * @param {Object} res - Express Response
 * @param {string} message - 错误消息
 */
function notFound(res, message = '资源不存在') {
  return error(res, message, 'RESOURCE_NOT_FOUND', 404);
}

/**
 * 系统错误
 * @param {Object} res - Express Response
 * @param {string} message - 错误消息
 */
function serverError(res, message = '服务器内部错误') {
  return error(res, message, 'SYS_ERR', 500);
}

module.exports = {
  success,
  error,
  validationError,
  unauthorized,
  forbidden,
  notFound,
  serverError
};
