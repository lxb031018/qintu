/**
 * 统一身份认证中间件
 *
 * 职责：
 * 1. 从请求头 x-user-openid 获取身份。
 * 2. 如果没有，则从 Authorization Token (mock_token_oid_xxx) 中智能提取。
 * 3. 将解析后的用户信息挂载到 req.user 上，供后续路由使用。
 * 4. 校验 Token 是否已被后登录的设备废弃（会话有效性检查）。
 */

const config = require('../../config');

function extractOpenid(req) {
  // 1. 优先读取标准 Header
  const headerOpenid = req.headers['x-user-openid'];
  if (headerOpenid) return headerOpenid;

  // 2. 兼容模式：从 Mock Token 中提取 (格式: mock_access_oid_xxx_xxx 或 mock_token_oid_xxx_xxx)
  const authHeader = req.headers['authorization'];
  if (authHeader && authHeader.includes(config.PREFIX.OPENID)) {
    const parts = authHeader.split(config.PREFIX.OPENID);
    if (parts.length > 1) {
      return config.PREFIX.OPENID + parts[1].split(/[\s"_]/)[0];
    }
  }

  return null;
}

/**
 * 认证中间件 (可选模式)
 * 即使没有身份验证通过，也会向下执行，但在 req.user 中标记
 */
function authMiddleware(req, res, next) {
  const openid = extractOpenid(req);

  if (openid) {
    req.user = { openid, isAuthenticated: true };
  } else {
    req.user = { openid: null, isAuthenticated: false };
  }

  next();
}

/**
 * 强制认证中间件 (保护敏感路由)
 * 如果没获取到身份，直接返回 401 错误
 * 同时检查 Token 是否仍有效（未被后登录的设备废弃）
 */
function requireAuth(req, res, next) {
  const authHeader = req.headers['authorization'];
  const openid = extractOpenid(req);

  if (!openid) {
    return res.status(401).json({
      code: 'UNAUTHORIZED',
      message: '缺少有效的用户身份信息'
    });
  }

  // 会话有效性检查：Token 必须在 userSessions 中存在且未过期
  const authService = global._authService;
  if (authService) {
    const accessToken = authHeader ? authHeader.replace(/^Bearer\s+/i, '').trim() : null;
    if (accessToken && !authService.isTokenValidForSession(openid, accessToken)) {
      return res.status(401).json({
        code: 'SESSION_REVOKED',
        message: '您的账号已在另一设备登录，请重新登录'
      });
    }
  }

  req.user = { openid, isAuthenticated: true };
  next();
}

module.exports = {
  authMiddleware,
  requireAuth
};
