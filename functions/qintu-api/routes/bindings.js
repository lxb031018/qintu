/**
 * 绑定关系管理路由
 *
 * 路由列表：
 * POST   /api/bindings/request-phone  - 通过手机号请求绑定
 * GET    /api/bindings/pending        - 获取待确认的绑定请求
 * POST   /api/bindings/confirm-request - 接收者确认绑定
 * POST   /api/bindings/reject-request  - 接收者拒绝绑定
 * GET    /api/bindings/my             - 获取我的所有绑定关系
 * DELETE /api/bindings/:id            - 解除绑定关系
 *
 * 已废弃接口（2026-04-09 删除）：
 * - POST   /api/bindings/generate    - 生成绑定码（已废弃）
 * - POST   /api/bindings/confirm     - 确认绑定码（已废弃）
 * - GET    /api/bindings/check/:code - 检查绑定码（已废弃）
 */

const express = require('express');
const router = express.Router();
const { query, transaction } = require('../lib/database');
const { success, validationError, error, notFound } = require('../lib/response');
const { authMiddleware } = require('../middleware/auth');
const { logOperation } = require('../lib/operation_logger');

/**
 * 绑定关系常量
 */
const BINDING_LIMITS = {
  MAX_RECEIVERS_PER_SENDER: 5,   // 一个发送者最多绑定 5 个接收者（家庭场景）
  MAX_SENDERS_PER_RECEIVER: 3    // 一个接收者最多被 3 个发送者绑定（避免过度监护）
};

const PENDING_REQUEST_EXPIRE_HOURS = 7 * 24; // pending 请求 7 天后过期

/**
 * 标准化手机号格式
 * 移除空格、横杠、+86 等前缀，仅保留纯数字
 * @param {string} phone - 原始手机号
 * @returns {string} - 标准化后的手机号
 */
function normalizePhone(phone) {
  if (!phone) return '';
  // 移除所有非数字字符
  return phone.replace(/[^\d]/g, '');
}

/**
 * GET /api/bindings/my
 * 获取我的所有绑定关系
 *
 * 需要认证
 * 返回：作为发送者的绑定 + 作为接收者的绑定
 */
router.get('/my', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;

    // 使用 UNION 一次查询所有绑定关系
    const allBindings = await query(
      `(SELECT b.id, b.status, b.remark, b.created_at, b.updated_at,
              'sender' as my_role,
              r.openid as partner_openid, r.nickname as partner_nickname,
              r.phone as partner_phone, r.user_type as partner_type,
              b.sender_openid, b.receiver_openid
       FROM user_bindings b
       INNER JOIN users r ON b.receiver_openid = r.openid
       WHERE b.sender_openid = ? AND b.status = 'active')
      UNION ALL
      (SELECT b.id, b.status, b.remark, b.created_at, b.updated_at,
              'receiver' as my_role,
              s.openid as partner_openid, s.nickname as partner_nickname,
              s.phone as partner_phone, s.user_type as partner_type,
              b.sender_openid, b.receiver_openid
       FROM user_bindings b
       INNER JOIN users s ON b.sender_openid = s.openid
       WHERE b.receiver_openid = ? AND b.status = 'active')
      ORDER BY created_at DESC`,
      [openid, openid]
    );

    // 统计发送者和接收者数量
    const asSender = allBindings.filter(b => b.my_role === 'sender').length;
    const asReceiver = allBindings.filter(b => b.my_role === 'receiver').length;

    return success(res, {
      total: allBindings.length,
      as_sender: asSender,
      as_receiver: asReceiver,
      bindings: allBindings
    });
  } catch (err) {
    console.error('获取绑定关系失败:', err);
    return error(res, '获取绑定关系失败', 'GET_BINDINGS_FAILED', 500);
  }
});

/**
 * DELETE /api/bindings/:id
 * 解除绑定关系
 * 
 * 需要认证
 */
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const openid = req.user.openid;
    const bindingId = parseInt(req.params.id);

    // 查找绑定关系
    const bindings = await query(
      `SELECT id, sender_openid, receiver_openid, status 
       FROM user_bindings WHERE id = ?`,
      [bindingId]
    );

    if (bindings.length === 0) {
      return notFound(res, '绑定关系不存在');
    }

    const binding = bindings[0];

    // 验证权限（只有绑定双方可以解绑）
    if (binding.sender_openid !== openid && binding.receiver_openid !== openid) {
      return error(res, '无权操作此绑定关系', 'PERMISSION_DENIED', 403);
    }

    // 更新状态为已撤销
    await query(
      `UPDATE user_bindings
       SET status = 'revoked', updated_at = NOW()
       WHERE id = ?`,
      [bindingId]
    );

    // 记录操作日志
    await logOperation({
      userOpenid: openid,
      action: 'REVOKE_BINDING',
      targetType: 'binding',
      targetId: bindingId.toString(),
      details: {
        sender_openid: binding.sender_openid,
        receiver_openid: binding.receiver_openid
      },
      ipAddress: req.ip
    });

    return success(res, { message: '绑定关系已解除' });
  } catch (err) {
    console.error('解除绑定失败:', err);
    return error(res, '解除绑定失败', 'REVOKE_BINDING_FAILED', 500);
  }
});

/**
 * POST /api/bindings/request-phone
 * 发送者通过手机号请求绑定
 *
 * 请求体：
 * {
 *   "receiver_phone": "+86 13800138000",
 *   "sender_name": "张三"
 * }
 */
router.post('/request-phone', authMiddleware, async (req, res) => {
  try {
    const senderOpenid = req.user.openid;
    const { receiver_phone, sender_name } = req.body;

    if (!receiver_phone) {
      return validationError(res, 'receiver_phone 是必填参数');
    }

    // 标准化手机号（移除 +86、空格等）
    const normalizedPhone = normalizePhone(receiver_phone);
    
    if (normalizedPhone.length < 11) {
      return error(res, '手机号格式不正确', 'INVALID_PHONE', 400);
    }

    // 1. 查找接收者 openid（精确匹配标准化后的手机号）
    const users = await query(
      'SELECT openid, nickname FROM users WHERE phone IS NOT NULL AND REPLACE(REPLACE(phone, "+86 ", ""), " ", "") = ? AND status = "active"',
      [normalizedPhone]
    );

    if (users.length === 0) {
      return error(res, '该手机号未注册亲途', 'USER_NOT_FOUND', 404);
    }

    const receiverOpenid = users[0].openid;

    if (senderOpenid === receiverOpenid) {
      return error(res, '不能绑定自己', 'SELF_BINDING', 400);
    }

    // 2. 检查绑定限制
    const senderBindingsCount = await query(
      `SELECT COUNT(*) as count FROM user_bindings WHERE sender_openid = ? AND status = 'active'`,
      [senderOpenid]
    );
    if (senderBindingsCount[0].count >= BINDING_LIMITS.MAX_RECEIVERS_PER_SENDER) {
      return error(res, '发送者绑定人数已达上限', 'BINDING_LIMIT_EXCEEDED', 409);
    }

    const receiverBindingsCount = await query(
      `SELECT COUNT(*) as count FROM user_bindings WHERE receiver_openid = ? AND status IN ('active', 'pending')`,
      [receiverOpenid]
    );
    if (receiverBindingsCount[0].count >= BINDING_LIMITS.MAX_SENDERS_PER_RECEIVER) {
      return error(res, '该接收者已被过多发送者绑定', 'RECEIVER_BINDING_FULL', 409);
    }

    // 3. 检查是否已存在
    const existingBindings = await query(
      `SELECT id, status FROM user_bindings WHERE sender_openid = ? AND receiver_openid = ?`,
      [senderOpenid, receiverOpenid]
    );

    if (existingBindings.length > 0) {
      const status = existingBindings[0].status;
      if (status === 'active') return error(res, '与该用户的绑定关系已生效', 'BINDING_EXISTS', 409);
      if (status === 'pending') return error(res, '已发送过绑定请求，请等待对方确认', 'PENDING_EXISTS', 409);
    }

    // 4. 创建 pending 记录（设置 7 天过期时间）
    const expireAt = new Date(Date.now() + PENDING_REQUEST_EXPIRE_HOURS * 60 * 60 * 1000);
    
    const result = await query(
      `INSERT INTO user_bindings (sender_openid, receiver_openid, status, remark, expired_at, created_at)
       VALUES (?, ?, 'pending', ?, ?, NOW())`,
      [senderOpenid, receiverOpenid, sender_name || '未命名发送者', expireAt]
    );

    // 记录操作日志
    await logOperation({
      userOpenid: senderOpenid,
      action: 'REQUEST_BINDING',
      targetType: 'binding',
      targetId: result.insertId.toString(),
      details: {
        receiver_openid: receiverOpenid,
        sender_name: sender_name || '未命名发送者'
      },
      ipAddress: req.ip
    });

    return success(res, { message: '绑定请求已发送' }, 201);

  } catch (err) {
    console.error('发送绑定请求失败:', err);
    return error(res, '请求失败', 'REQUEST_BINDING_FAILED', 500);
  }
});

/**
 * GET /api/bindings/pending
 * 获取接收者待确认的绑定请求（过滤已过期的）
 */
router.get('/pending', authMiddleware, async (req, res) => {
  try {
    const receiverOpenid = req.user.openid;

    // 先将已过期的 pending 请求标记为 expired
    await query(
      `UPDATE user_bindings 
       SET status = 'expired', updated_at = NOW()
       WHERE receiver_openid = ? AND status = 'pending' 
       AND expired_at IS NOT NULL AND expired_at < NOW()`,
      [receiverOpenid]
    );

    // 查询有效的 pending 请求
    const requests = await query(
      `SELECT b.id, b.remark as sender_name, b.created_at, b.expired_at,
              u.nickname as sender_nickname, u.phone as sender_phone
       FROM user_bindings b
       JOIN users u ON b.sender_openid = u.openid
       WHERE b.receiver_openid = ? AND b.status = 'pending'
       AND (b.expired_at IS NULL OR b.expired_at > NOW())
       ORDER BY b.created_at DESC`,
      [receiverOpenid]
    );

    // 手机号脱敏
    const maskedRequests = requests.map(r => ({
      ...r,
      sender_phone: r.sender_phone ? r.sender_phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2') : '未知'
    }));

    return success(res, maskedRequests);
  } catch (err) {
    console.error('获取待确认请求失败:', err);
    return error(res, '获取失败', 'GET_PENDING_FAILED', 500);
  }
});

/**
 * POST /api/bindings/confirm-request
 * 接收者确认绑定
 */
router.post('/confirm-request', authMiddleware, async (req, res) => {
  try {
    const receiverOpenid = req.user.openid;
    const { request_id } = req.body;

    if (!request_id) return validationError(res, 'request_id 是必填参数');

    // 查询绑定请求，检查是否有效
    const binding = await query(
      `SELECT sender_openid, expired_at 
       FROM user_bindings 
       WHERE id = ? AND receiver_openid = ? AND status = 'pending'
       AND (expired_at IS NULL OR expired_at > NOW())`,
      [request_id, receiverOpenid]
    );

    if (binding.length === 0) {
      return error(res, '请求不存在、已过期或已处理', 'REQUEST_INVALID', 404);
    }

    await query(
      `UPDATE user_bindings SET status = 'active', updated_at = NOW() WHERE id = ?`,
      [request_id]
    );

    // 记录操作日志
    await logOperation({
      userOpenid: receiverOpenid,
      action: 'CONFIRM_BINDING',
      targetType: 'binding',
      targetId: request_id.toString(),
      details: {
        sender_openid: binding[0].sender_openid
      },
      ipAddress: req.ip
    });

    return success(res, { message: '绑定成功' });
  } catch (err) {
    console.error('确认绑定失败:', err);
    return error(res, '确认失败', 'CONFIRM_REQUEST_FAILED', 500);
  }
});

/**
 * POST /api/bindings/reject-request
 * 接收者拒绝绑定
 */
router.post('/reject-request', authMiddleware, async (req, res) => {
  try {
    const receiverOpenid = req.user.openid;
    const { request_id } = req.body;

    if (!request_id) return validationError(res, 'request_id 是必填参数');

    const result = await query(
      `UPDATE user_bindings SET status = 'revoked', updated_at = NOW()
       WHERE id = ? AND receiver_openid = ? AND status = 'pending'`,
      [request_id, receiverOpenid]
    );

    // 记录操作日志
    if (result.affectedRows > 0) {
      await logOperation({
        userOpenid: receiverOpenid,
        action: 'REJECT_BINDING',
        targetType: 'binding',
        targetId: request_id.toString(),
        ipAddress: req.ip
      });
    }

    return success(res, { message: '已拒绝' });
  } catch (err) {
    console.error('拒绝绑定失败:', err);
    return error(res, '拒绝失败', 'REJECT_REQUEST_FAILED', 500);
  }
});

module.exports = router;
