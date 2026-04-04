/**
 * 用户管理路由
 * 
 * 路由列表：
 * POST   /api/users/register      - 用户注册（首次登录自动创建）
 * GET    /api/users/me            - 获取当前用户信息
 * PUT    /api/users/me            - 更新用户信息
 * GET    /api/users/:openid       - 获取指定用户信息（需要权限）
 */

const express = require('express');
const router = express.Router();
const { query, transaction } = require('../lib/database');
const { success, validationError, error, notFound } = require('../lib/response');
const { authMiddleware } = require('../middleware/auth');

/**
 * POST /api/users/register
 * 用户注册（首次登录）
 * 
 * 请求体：
 * {
 *   "openid": "cloudbase_auth_openid",  // 必需
 *   "phone": "+86 13800138000",         // 可选
 *   "nickname": "张三",                  // 可选
 *   "user_type": "both"                 // 可选，默认 both
 * }
 */
router.post('/register', async (req, res) => {
  try {
    const { openid, phone, nickname, user_type } = req.body;

    // 参数验证
    if (!openid) {
      return validationError(res, 'openid 是必填参数');
    }

    // 验证 user_type
    const validTypes = ['sender', 'receiver', 'both'];
    const finalUserType = user_type || 'both';
    if (!validTypes.includes(finalUserType)) {
      return validationError(res, 'user_type 必须是 sender、receiver 或 both');
    }

    // 检查用户是否已存在
    const existingUsers = await query(
      'SELECT openid FROM users WHERE openid = ?',
      [openid]
    );

    if (existingUsers.length > 0) {
      return error(res, '用户已存在，请使用登录接口', 'USER_EXISTS', 409);
    }

    // 创建用户
    await query(
      `INSERT INTO users (openid, phone, nickname, user_type, last_login_at) 
       VALUES (?, ?, ?, ?, NOW())`,
      [openid, phone || null, nickname || null, finalUserType]
    );

    // 获取创建的用户信息
    const users = await query(
      'SELECT openid, phone, nickname, user_type, created_at FROM users WHERE openid = ?',
      [openid]
    );

    return success(res, users[0], 201);
  } catch (err) {
    console.error('用户注册失败:', err);
    
    // 处理唯一约束冲突
    if (err.code === 'ER_DUP_ENTRY') {
      return error(res, '手机号已被注册', 'DUPLICATE_PHONE', 409);
    }
    
    return error(res, '注册失败，请稍后重试', 'REGISTER_FAILED', 500);
  }
});

/**
 * GET /api/users/me
 * 获取当前用户信息
 * 
 * 需要认证
 */
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const { openid } = req.user;

    const users = await query(
      `SELECT openid, phone, nickname, user_type, status, last_login_at, created_at 
       FROM users WHERE openid = ?`,
      [openid]
    );

    if (users.length === 0) {
      return notFound(res, '用户不存在');
    }

    return success(res, users[0]);
  } catch (err) {
    console.error('获取用户信息失败:', err);
    return error(res, '获取用户信息失败', 'GET_USER_FAILED', 500);
  }
});

/**
 * PUT /api/users/me
 * 更新当前用户信息
 * 
 * 需要认证
 * 请求体（所有字段可选）：
 * {
 *   "nickname": "新昵称",
 *   "user_type": "sender"  // 只能是 sender、receiver、both
 * }
 */
router.put('/me', authMiddleware, async (req, res) => {
  try {
    const { openid } = req.user;
    const { nickname, user_type } = req.body;

    // 验证 user_type
    if (user_type) {
      const validTypes = ['sender', 'receiver', 'both'];
      if (!validTypes.includes(user_type)) {
        return validationError(res, 'user_type 必须是 sender、receiver 或 both');
      }
    }

    // 构建更新语句
    const updates = [];
    const params = [];

    if (nickname !== undefined) {
      updates.push('nickname = ?');
      params.push(nickname);
    }

    if (user_type !== undefined) {
      updates.push('user_type = ?');
      params.push(user_type);
    }

    if (updates.length === 0) {
      return validationError(res, '至少需要提供一个要更新的字段');
    }

    params.push(openid);

    await query(
      `UPDATE users SET ${updates.join(', ')} WHERE openid = ?`,
      params
    );

    // 返回更新后的用户信息
    const users = await query(
      'SELECT openid, phone, nickname, user_type, status FROM users WHERE openid = ?',
      [openid]
    );

    return success(res, users[0]);
  } catch (err) {
    console.error('更新用户信息失败:', err);
    return error(res, '更新用户信息失败', 'UPDATE_USER_FAILED', 500);
  }
});

/**
 * POST /api/users/sync
 * 用户信息同步（登录时调用，确保 MySQL 中存在记录）
 *
 * 请求体：
 * {
 *   "openid": "cloudbase_auth_openid",  // 必需
 *   "phone": "+86 13800138000",         // 可选
 *   "nickname": "张三"                  // 可选
 * }
 */
router.post('/sync', async (req, res) => {
  try {
    const { openid, phone, nickname } = req.body;

    if (!openid) {
      return validationError(res, 'openid 是必填参数');
    }

    // 检查用户是否存在
    const existingUsers = await query(
      'SELECT openid FROM users WHERE openid = ?',
      [openid]
    );

    if (existingUsers.length === 0) {
      // 不存在则创建
      await query(
        `INSERT INTO users (openid, phone, nickname, user_type, last_login_at)
         VALUES (?, ?, ?, 'both', NOW())`,
        [openid, phone || null, nickname || null]
      );
      console.log(`[User Sync] 创建新用户: ${openid}`);
    } else {
      // 存在则更新登录时间
      await query(
        'UPDATE users SET last_login_at = NOW() WHERE openid = ?',
        [openid]
      );
    }

    // 获取用户信息返回
    const users = await query(
      `SELECT openid, phone, nickname, user_type, status, last_login_at, created_at
       FROM users WHERE openid = ?`,
      [openid]
    );

    return success(res, users[0]);
  } catch (err) {
    console.error('用户同步失败:', err);

    if (err.code === 'ER_DUP_ENTRY') {
      return error(res, '手机号已被注册', 'DUPLICATE_PHONE', 409);
    }

    return error(res, '同步失败，请稍后重试', 'SYNC_FAILED', 500);
  }
});

/**
 * GET /api/users/:openid
 * 获取指定用户信息（公开信息）
 * 
 * 需要认证
 * 注意：只能获取已绑定用户的公开信息
 */
router.get('/:openid', authMiddleware, async (req, res) => {
  try {
    const targetOpenid = req.params.openid;
    const currentOpenid = req.user.openid;

    // 检查是否有绑定关系
    const bindings = await query(
      `SELECT id FROM user_bindings 
       WHERE status = 'active' 
       AND (
         (sender_openid = ? AND receiver_openid = ?) 
         OR (sender_openid = ? AND receiver_openid = ?)
       )`,
      [currentOpenid, targetOpenid, targetOpenid, currentOpenid]
    );

    if (bindings.length === 0) {
      return error(res, '只能查看已绑定用户的信息', 'NO_BINDING', 403);
    }

    // 查询公开用户信息
    const users = await query(
      `SELECT openid, nickname, user_type 
       FROM users WHERE openid = ? AND status = 'active'`,
      [targetOpenid]
    );

    if (users.length === 0) {
      return notFound(res, '用户不存在或已禁用');
    }

    return success(res, users[0]);
  } catch (err) {
    console.error('获取用户信息失败:', err);
    return error(res, '获取用户信息失败', 'GET_USER_FAILED', 500);
  }
});

module.exports = router;
