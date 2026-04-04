/**
 * 认证中间件
 * 
 * 验证用户身份（从 CloudBase Auth 获取的 Access Token）
 * 并将用户信息注入到 req.user
 */

const { query } = require('../lib/database');
const { unauthorized } = require('../lib/response');

/**
 * 认证中间件
 * 
 * 从请求头获取 Access Token，验证用户身份
 * 
 * 请求头格式：
 * Authorization: Bearer <access_token>
 * X-User-OpenID: <openid>（可选，用于开发调试）
 */
async function authMiddleware(req, res, next) {
  try {
    // 从请求头获取用户 openid
    // 注意：在生产环境中，应该验证 CloudBase Access Token
    // 这里简化处理，直接从自定义头获取（需要配合 API 网关验证）
    const openid = req.headers['x-user-openid'];
    
    if (!openid) {
      return unauthorized(res, '缺少用户认证信息');
    }

    // 查询用户信息
    const users = await query(
      'SELECT openid, phone, nickname, user_type, status FROM users WHERE openid = ?',
      [openid]
    );

    if (users.length === 0) {
      return unauthorized(res, '用户不存在或未注册');
    }

    const user = users[0];

    // 检查用户状态
    if (user.status === 'disabled') {
      return unauthorized(res, '用户账号已被禁用');
    }

    // 将用户信息注入请求对象
    req.user = {
      openid: user.openid,
      phone: user.phone,
      nickname: user.nickname,
      user_type: user.user_type
    };

    next();
  } catch (error) {
    console.error('认证中间件错误:', error);
    return unauthorized(res, '认证失败');
  }
}

/**
 * 可选认证中间件
 * 
 * 如果提供认证信息则验证，否则跳过
 * 用于某些公开但登录后可见更多内容的接口
 */
async function optionalAuth(req, res, next) {
  try {
    const openid = req.headers['x-user-openid'];
    
    if (openid) {
      const users = await query(
        'SELECT openid, phone, nickname, user_type, status FROM users WHERE openid = ?',
        [openid]
      );

      if (users.length > 0 && users[0].status === 'active') {
        req.user = {
          openid: users[0].openid,
          phone: users[0].phone,
          nickname: users[0].nickname,
          user_type: users[0].user_type
        };
      }
    }

    next();
  } catch (error) {
    // 可选认证失败不影响后续
    console.error('可选认证中间件错误:', error);
    next();
  }
}

module.exports = {
  authMiddleware,
  optionalAuth
};
