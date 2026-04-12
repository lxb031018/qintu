/**
 * 请求 ID 中间件
 *
 * 为每个请求生成唯一的 requestId，便于日志追踪和排查问题
 */

const { v4: uuidv4 } = require('uuid');

/**
 * 请求 ID 中间件
 *
 * 优先使用客户端传入的 X-Request-ID（如果存在），否则生成新的 UUID
 */
function requestIdMiddleware(req, res, next) {
  const requestId = req.headers['x-request-id'] || uuidv4();
  req.requestId = requestId;

  // 在响应头中返回 requestId，方便客户端追踪
  res.setHeader('X-Request-ID', requestId);

  next();
}

module.exports = { requestIdMiddleware };
