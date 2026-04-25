/**
 * 请求 ID 中间件
 *
 * 为每个请求生成唯一 UUID，便于日志追踪
 */

const { v4: uuidv4 } = require('uuid');

function requestIdMiddleware(req, res, next) {
  req.requestId = uuidv4();
  res.setHeader('X-Request-ID', req.requestId);
  next();
}

module.exports = {
  requestIdMiddleware
};
