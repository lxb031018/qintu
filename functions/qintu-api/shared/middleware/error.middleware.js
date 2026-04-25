/**
 * 全局错误处理中间件
 */

/**
 * 全局错误处理
 */
function errorHandler(err, req, res, next) {
  console.error('[Error]', err.message);
  console.error('[Stack]', err.stack);

  // 处理特定错误类型
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      code: 'VALIDATION_ERROR',
      message: err.message
    });
  }

  // 默认返回 500
  res.status(500).json({
    code: 'SYS_ERR',
    message: process.env.NODE_ENV === 'production'
      ? '服务器内部错误'
      : err.message
  });
}

/**
 * 404 处理中间件
 */
function notFoundHandler(req, res) {
  res.status(404).json({
    code: 'NOT_FOUND',
    message: '接口不存在'
  });
}

module.exports = {
  errorHandler,
  notFoundHandler
};
