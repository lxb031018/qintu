/**
 * 统一身份认证中间件
 * 
 * 职责：
 * 1. 从请求头 x-user-openid 获取身份。
 * 2. 如果没有，则从 Authorization Token (mock_token_oid_xxx) 中智能提取。
 * 3. 将解析后的用户信息挂载到 req.user 上，供后续路由使用。
 */

const config = require('../config'); // 🌟 引入配置

function extractOpenid(req) {
    // 1. 优先读取标准 Header
    const headerOpenid = req.headers['x-user-openid'];
    if (headerOpenid) return headerOpenid;

    // 2. 兼容模式：从 Mock Token 中提取 (格式: mock_access_oid_xxx 或 mock_token_oid_xxx)
    const authHeader = req.headers['authorization'];
    if (authHeader && authHeader.includes(config.PREFIX.OPENID)) {
        const parts = authHeader.split(config.PREFIX.OPENID);
        if (parts.length > 1) {
            return config.PREFIX.OPENID + parts[1].split(/[\s"]/)[0];
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
 */
function requireAuth(req, res, next) {
    const openid = extractOpenid(req);
    
    if (!openid) {
        return res.status(401).json({
            code: 'UNAUTHORIZED',
            message: '缺少有效的用户身份信息'
        });
    }
    
    req.user = { openid, isAuthenticated: true };
    next();
}

module.exports = {
    authMiddleware,
    requireAuth
};
